#!/usr/bin/env bash

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

if [[ $(minikube version) ]]; then
	echo "Minikube is installed in system"
else
	echo "Minikube is not present in system. Installing"
	curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
	chmod +x minikube
	sudo mv minikube /usr/local/bin/
fi

if [[ $(kubectl version --short) ]]; then
	echo "Kubectl is installed in system"
else
	echo "Kubectl is not installed in system. Installing"
	curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
	chmod +x ./kubectl
	sudo mv ./kubectl /usr/local/bin/kubectl
fi

if [[ $(helm version) ]]; then
	echo "Helm is installed in system"
else
	echo "Helm is not installed in system. Installing"
	curl -L https://get.helm.sh/helm-v3.9.2-linux-amd64.tar.gz -o helm.tar.gz
	tar xf helm.tar.gz
	sudo mv linux-amd64/helm /usr/local/bin/
fi

if [[ $(terraform version) ]]; then
	echo "Terraform is installed in system"
else
	echo "Terraform is not installed in system. Installing"
	wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
	sudo apt update && sudo apt install terraform
fi
