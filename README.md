# Comparus test work

Test task from COMPARUS. The solution consists of the following set of components:
1. There are 2 ways to install jenkins server to choose from, use helm chart and an additional set of manifests, or use terraform which will deploy the entire k8s infrastructure
2. A set of manifests for kubernetes with a description of roles and pv, when installing jenkins using helm
3. terraform to create a task in jenkins

### Instruction for use

Working tested on clean ubuntu 20.04

* First you need to download the git repo: `git clone https://github.com/serafim101/comparus.git`
* Next, you need to go to the directory with the repository: `cd comparus`
* Then you need to execute the script that prepares VM for the deployment of the cluster and all its components: `sh vm_prepair.sh`
* After the preparation of the VM is completed, you need to run a script that will install all the necessary dependencies for deployment and perform the process of deploying the cluster and all its components. To install, you must use one of the methods: `sh start.sh helm` or `sh start.sh terraform`
* An important note, at the end, a jenkins job is created, which does not start automatically. I, unfortunately, did not find a workable way to run it from terraform
