#!/usr/bin/env bash

# Script variables
JENKINS_DOMAIN="jenkins.lc"


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
