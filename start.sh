#!/usr/bin/env bash

# Script variables
JENKINS_DOMAIN="jenkins.lc"
PWD=$(pwd)

# Script functions
usage() {
	echo "Use the following options to start deployment:"
	echo " For Helm deploying: sh $0 helm"
	echo " For Terraform deploing: sh $0 terraform"
}

k8s_prepair() {
	if ! [[ -d "/usr/local/bin/"]]
	then
		sudo mkdir -p /usr/local/bin/
	fi

	if [[ $(minikube version) ]]
	then
		echo "Minikube is installed in system"
	else
		echo "Minikube is not present in system. Installing"
		curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
		chmod +x minikube
		sudo mv minikube /usr/local/bin/
	fi

	if [[ $(kubectl version --short) ]]
	then
		echo "Kubectl is installed in system"
	else
		echo "Kubectl is not installed in system. Installing"
		curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
		chmod +x ./kubectl
		sudo mv ./kubectl /usr/local/bin/kubectl
	fi

	if [[ $(terraform version) ]]
	then
		echo "Terraform is installed in system"
	else
		echo "Terraform is not installed in system. Installing"
		wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
		echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
		sudo apt update && sudo apt install terraform
	fi


	echo "Start minikube cluster"
	minikube start --vm-driver='docker' --cpus='4' --memory='8g'
	minikube addons enable ingress

	echo "Preparing minikube cluster for jenkins server"
	minikube ssh -- "sudo mkdir /data/jenkins-volume"
	minikube ssh -- "sudo chown -R 1000:1000 /data/jenkins-volume"
	minikube ssh -- "sudo chmod 666 /var/run/docker.sock"

	if [[ $(cat /etc/hosts | grep "$JENKINS_DOMAIN" | awk '{print $2}') == "$JENKINS_DOMAIN" ]]
	then
		IP=$(minikube ip)
		echo "Add minikube ip-address: $IP to /etc/hosts, for associate IP with INGRESS DOMAIN"
		cat <<EOF | sudo tee -a /etc/hosts
${IP} ${JENKINS_DOMAIN}
EOF
	fi
}

deploy_helm() {
	echo "Install Jenkins to kubernetes with helm chart"
	k8s_prepair
	kubectl create namespace jenkins
	kubectl apply -f $PWD/k8s/jenkins-volume.yaml
	kubectl apply -f $PWD/k8s/jenkins-sa.yaml

	if [[ $(helm version) ]]; then
		echo "Helm is installed in system"
	else
		echo "Helm is not installed in system. Installing"
		curl -L https://get.helm.sh/helm-v3.9.2-linux-amd64.tar.gz -o helm.tar.gz
		tar xf helm.tar.gz
		sudo mv linux-amd64/helm /usr/local/bin/
	fi


	helm repo add jenkinsci https://charts.jenkins.io
	helm repo update
	helm install jenkins -n jenkins -f $PWD/k8s/values.yaml jenkinsci/jenkins --wait

	kubectl apply -f $PWD/k8s/jenkins-ingress.yaml --wait

	sleep 5

	JEN_PASS=$(kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo)
	JEN_USER=$(kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-username && echo)
	IP=$(minikube ip)

	echo "Deploy jenkins job to server with terraform"
	terraform -chdir=$PWD/terraform/jenkins init
	terraform -chdir=$PWD/terraform/jenkins apply -var "jenkins_url=http://$JENKINS_DOMAIN" -var "jen_user=$JEN_USER" -var "jen_pass=$JEN_PASS" -auto-approve

	echo ""
	echo "Ingress URL: http://$JENKINS_DOMAIN"
	echo "NodePort URL: http://$IP:30088"
	echo "Uername: $JEN_USER"
	echo "Password: $JEN_PASS"
}

deploy_terraform() {
	echo "Install Jenkins to kubernetes with terraform"
	k8s_prepair
	terraform -chdir=$PWD/terraform/k8s init
	terraform -chdir=$PWD/terraform/k8s apply -var "ingress_domain=$JENKINS_DOMAIN" -auto-approve

	sleep 5

	terraform -chdir=$PWD/terraform/k8s apply -auto-approve
	JEN_URL=$(terraform -chdir=$PWD/terraform/k8s output -raw jenkins_url)
	JEN_USER=$(terraform -chdir=$PWD/terraform/k8s output jenkins_user)
	JEN_PASS=$(terraform -chdir=$PWD/terraform/k8s output jenkins_password)

	terraform -chdir=$PWD/terraform/jenkins init
	terraform -chdir=$PWD/terraform/jenkins apply -var "jenkins_url=$JEN_URL" -var "jen_user=$JEN_USER" -var "jen_pass=$JEN_PASS" -auto-approve

	echo ""
	echo "Ingress URL: http://$JENKINS_DOMAIN"
	echo "NodePort URL: $JEN_URL"
	echo "Uername: $JEN_USER"
	echo "Password: $JEN_PASS"
}


case $1 in
	helm ) deploy_helm;;
	terraform ) deploy_terraform;;
	* ) usage;;
esac

if [ "$#" -eq 0 ]
  then
    usage
fi
