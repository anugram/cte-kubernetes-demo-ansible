# Ciphertrust Transparent Encryption for Kubernetes deployment automation
This is a easy to deploy "bash based" script to automate configuration and deployment of Ciphertrust Transparent Encryption module for Kuberenetes and Ciphetrust Manager.
This project will let you
* Configure Ciphertrust Manager's Container Storage Interface policy based on variables
* Configure Ciphertrust Manager's Storage Group based on variables

## Getting Started
### Prerequisites
* Host machine with Ansible installed
* Host machine with Vagrant installed
### Quickstart
#### 1) Deploy Ciphertrust Manager (CM) community edition (Always Free)
To deploy Ciphertrust Manager, follow the link https://ciphertrust.io/ 
You can deploy Ciphertrust Manager in you favorite cloud environment or on local server/virtual machine
Detailed steps are available on CM web page above.
#### 2) Clone the repo 
Clone this repo on your Windows workstation
```
git clone https://github.com/anugram/cte-kubernetes-demo-ansible.git
```
#### 3) Configure variables
Variable Name | Description | Example Value
--- | --- | ---
cm_username | Username for Ciphertrust Manager | admin
cm_password | Password for Ciphertrust Manager | *********
cm_host | FQDN/Host/IP of Ciphertrust Manager | 10.10.10.10
cm_kubernetes_policy_name | Policy for Kubernetes Container Storage Interface | cte-csi-policy
cm_kubernetes_policy_key_name | Key associated with Policy | clear_key
cm_kubernetes_storage_group_name | Kubernetes Storage Group Name | cte-csi-sg
cm_kubernetes_storage_class | Kubernetes Storage Class | cte-csi-sc
cm_kubernetes_namespace | Kubernetes Namespace | default
cm_reg_token | Ciphertrust Manager Registration Token | <Base64 Encoded Registration token from CM>
#### 4) Deploying Solution
```
./deploy.sh
```
#### 5) Accessing the setup
```
vagrant ssh
```
```
kubectl exec -it cte-csi-demo /bin/bash
```
