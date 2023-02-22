# Ciphertrust Transparent Encryption for Kubernetes deployment automation
This script leverages Minikube along with teh CipherTrust Transparent Encryption tool for Kubernetes to demonstrate the transparent encryption capabilities offered by the CipherTrust Manager, all using the free-forever community edition of CipherTrust Manager from Thales.

This project will let you
* Configure Ciphertrust Manager's Container Storage Interface policy based on variables provided as part of PowerShell script execution

## Getting Started

### Prerequisites
* Host machine with Ansible installed

### Quickstart
#### 1) Deploy Ciphertrust Manager (CM) community edition (Always Free)
To deploy Ciphertrust Manager, follow the link https://ciphertrust.io/ 
You can deploy Ciphertrust Manager in you favorite cloud environment or on local server/virtual machine
Detailed steps are available on CM web page above.

#### 2) Clone the repo 
Clone this repo
```
git clone https://github.com/anugram/cte-kubernetes-demo-ansible.git
```

#### 3) Deploy required softwares on target machines
* Install NFS Server
```
ansible-playbook nfs-setup-playbook.yml -e "ansible_become_password=<root_password>"
```
/etc/ansible/hosts
```
[nfs-servers]
xxx.xxx.xxx.xxx     ansible_user=<username>
```
Installing infrastructure components required ro run CTE for Minikube in another VM
* Install Docker
* Install Minikube
* Install PowerShell
* Install Kubectl
* Install helm
* Install cri-docker
* Install jq (json parser for linux)
```
ansible-playbook cte-infra-setup-playbook.yml -e "ansible_become_password=<root_password>"
```
/etc/ansible/hosts
```
[minikube-servers]
xxx.xxx.xxx.xxx     ansible_user=<username>
```
#### 3) Update config file
filename: ./automation_modules/vars/main.json

Variable Name | Description | Example Value
--- | --- | ---
cm_username | Username for Ciphertrust Manager | admin
cm_password | Password for Ciphertrust Manager | *********
cm_host | FQDN/Host/IP of Ciphertrust Manager | 10.10.10.10
nfs_server_host | IP Address of an NFS server | nfs-server
cm_kubernetes_policy_name | desired CSI policy name on CM | cte-csi-policy
cm_kubernetes_policy_key_name | desired key name on CM | cte-key
cm_kubernetes_storage_group_name | desired k8s storage group name on CM | cte-csi-sg
cm_kubernetes_storage_class | desired storage class name on CM | cte-csi-sc
cm_kubernetes_namespace | kubernetes namespace defined on CM | cte
#### 4) Putting everything together
```
ansible-playbook cte-config-deployment-playbook.yml  -e "ansible_become_password=<root_password>"
```
