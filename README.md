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
- hosts: nfs-servers
  become: yes
  roles:
    - role: anuragjain_ca.nfs
      nfs_exports:
        - '/data/cte  *(rw,sync,no_subtree_check,no_root_squash,insecure)'
        - '/data  *(rw,sync,no_subtree_check,no_root_squash,insecure)'
```
/etc/ansible/hosts
```
[nfs-servers]
xxx.xxx.xxx.xxx     ansible_user=<username>
```
Execute Playbook
```
ansible-playbook nfs-playbook.yml -e "ansible_become_password=<root_password>"
```
* Install Docker
* Install Minikube
* Install PowerShell
```
# Applicable for a target machine with snap based Ubuntu distribution
- hosts: minikube-servers
  become: yes
  tasks:
  - name: install docker
    community.general.snap:
      name:
        - docker

  - name: install minikube
    community.general.snap:
      name:
        - minikube

  - name: install powershell
    community.general.snap:
      name: powershell
      classic: yes
```
/etc/ansible/hosts
```
[minikube-servers]
xxx.xxx.xxx.xxx     ansible_user=<username>
```
Execute Playbook
```
ansible-playbook minikube-playbook.yml -e "ansible_become_password=<root_password>"
```
#### 3) Update config.txt file
Variable Name | Description | Example Value
--- | --- | ---
username | Username for Ciphertrust Manager | admin
password | Password for Ciphertrust Manager | *********
cmip | FQDN/Host/IP of Ciphertrust Manager | 10.10.10.10
counter | Unique value to be appended to CM config parameters | demo
nfsServerIp | IP Address of an NFS server | 10.10.10.10
#### 4) Deploying Solution
```
ansible-playbook cte-deployment.yml  -e "ansible_become_password=<root_password>"
```
