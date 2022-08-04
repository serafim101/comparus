#!/usr/bin/env bash

# Script variables
JENKINS_DOMAIN="jenkins.lc"


echo "Upgrade system packages & install docker"
sudo apt update -y
sudo apt dist-upgrade -y
sudo apt install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker $USER && newgrp docker

if ![[ -d "/usr/local/bin/"]]; then
	sudo mkdir -p /usr/local/bin/
fi

echo "Minikube is not present in system. Installing"
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/


echo "Kubectl is not installed in system. Installing"
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

echo "Helm is not installed in system. Installing"
curl -L https://get.helm.sh/helm-v3.9.2-linux-amd64.tar.gz -o helm.tar.gz
tar xf helm.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/

echo "Terraform is not installed in system. Installing"
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform


echo "Start minikube cluster"
minikube start --vm-driver='docker' --cpus='4' --memory='8g'
minikube addons enable ingress

echo "Preparing minikube cluster for jenkins server"
minikube ssh -- "sudo mkdir /data/jenkins-volume"
minikube ssh -- "sudo chown -R 1000:1000 /data/jenkins-volume"
minikube ssh -- "sudo chmod 666 /var/run/docker.sock"

echo "Install Jenkins to kubernetes"
kubectl create namespace jenkins
kubectl apply -f $PWD/jenkins-volume.yaml
kubectl apply -f $PWD/jenkins-sa.yaml

helm repo add jenkinsci https://charts.jenkins.io
helm repo update
helm install jenkins -n jenkins -f $PWD/values.yaml jenkinsci/jenkins --wait

kubectl apply -f $PWD/jenkins-ingress.yaml --wait

JEN_PASS=$(kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo)
JEN_USER=$(kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-username && echo)
IP=$(minikube ip)

cat <<EOF | sudo tee -a /etc/hosts
${IP} ${JENKINS_DOMAIN}
EOF

sleep 5

echo "Deploy jenkins job to server with terraform"
terraform -chdir=$PWD/terraform/jenkins init
terraform -chdir=$PWD/terraform/jenkins apply -var "jenkins_url=http://$JENKINS_DOMAIN" -var "jen_user=$JEN_USER" -var "jen_pass=$JEN_PASS" -auto-approve

echo ""
echo "Ingress URL: http://$JENKINS_DOMAIN"
echo "NodePort URL: http://$IP:30080"
echo "Uername: $USER"
echo "Password: $PASS"
