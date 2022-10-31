#!/bin/bash

source ./automation_modules/getToken.sh
#source ./automation_modules/createRegToken.sh
source ./automation_modules/getUser.sh
source ./automation_modules/createKubernetesPolicyKey.sh
source ./automation_modules/createKubernetesPolicy.sh
source ./automation_modules/createKubernetesStorageGroup.sh

policyName=`cat ./automation_modules/vars/main.json | jq -r '.cm_kubernetes_policy_name'`
keyName=`cat ./automation_modules/vars/main.json | jq -r '.cm_kubernetes_policy_key_name'`
sgName=`cat ./automation_modules/vars/main.json | jq -r '.cm_kubernetes_storage_group_name'`
scName=`cat ./automation_modules/vars/main.json | jq -r '.cm_kubernetes_storage_class'`
nsName=`cat ./automation_modules/vars/main.json | jq -r '.cm_kubernetes_namespace'`
regToken=`cat ./automation_modules/vars/main.json | jq -r '.cm_reg_token'`
cmIP=`cat ./automation_modules/vars/main.json | jq -r '.cm_host'`

token=`getToken`
user=`getUser`
keyName=`createKubernetesPolicyKey`
policy=`createKubernetesPolicy`
echo "**********Policy Created on Ciphertrust Manager**********"
echo "CTE for K8s Policy Name: ${policy}"
sgId=`createKubernetesStorageGroup`
echo "**********Security Group Created on Ciphertrust Manager**********"
echo "CTE for K8s Group Id: ${sgId}"

regTokenEnc=`echo ${regToken} | base64 -w 0`
cp -rf ./templates/*.* ./example/
sed -i "s/CM_TOKEN_ENC/$regTokenEnc/g" ./example/cmtoken.yaml
sed -i "s/VAR_NS/$nsName/g" ./example/cmtoken.yaml
sed -i "s/CM_STORAGE_CLASS/$scName/g" ./example/local-pv.yaml
sed -i "s/VAR_NS/$nsName/g" ./example/local-pv.yaml
sed -i "s/CM_STORAGE_CLASS/$scName/g" ./example/local-pvc.yaml
sed -i "s/VAR_NS/$nsName/g" ./example/local-pvc.yaml
sed -i "s/CM_STORAGE_CLASS/$scName/g" ./example/storage.yaml
sed -i "s/CM_STORAGE_GROUP/$sgName/g" ./example/storage.yaml
sed -i "s/CM_IP/$cmIP/g" ./example/storage.yaml
sed -i "s/VAR_NS/$nsName/g" ./example/storage.yaml
sed -i "s/CM_CTE_POLICY/$policyName/g" ./example/pvc.yaml
sed -i "s/CM_STORAGE_CLASS/$scName/g" ./example/pvc.yaml
sed -i "s/VAR_NS/$nsName/g" ./example/pvc.yaml
sed -i "s/VAR_NS/$nsName/g" ./example/createNamespace.yaml
sed -i "s/VAR_NS/$nsName/g" ./example/demo.yaml
sed -i "s/VAR_NS/$nsName/g" ./example/createStorageClass.yaml

git clone https://github.com/thalescpl-io/ciphertrust-transparent-encryption-kubernetes.git
vagrant up
vagrant ssh -c 'sudo apt-get install -y nfs-common'
vagrant ssh -c 'sudo systemctl start nfs-utils'
vagrant ssh -c 'sudo systemctl enable nfs-utils'
vagrant ssh -c 'mkdir -p /tmp/data'
vagrant ssh -c 'sudo chmod 777 /tmp/data'
vagrant ssh -c 'sudo systemctl enable nfs-utils'
vagrant ssh -c 'cd /vagrant/ciphertrust-transparent-encryption-kubernetes && ./deploy.sh'
vagrant ssh -c 'sudo cp ~/.kube/config /vagrant/'
vagrant ssh -c 'kubectl taint nodes --all node-role.kubernetes.io/control-plane-'
vagrant ssh -c 'kubectl apply -f /vagrant/example/createNamespace.yaml'
vagrant ssh -c 'kubectl apply -f /vagrant/example/createStorageClass.yaml'
vagrant ssh -c 'kubectl apply -f /vagrant/example/cmtoken.yaml'
vagrant ssh -c 'kubectl apply -f /vagrant/example/storage.yaml'
vagrant ssh -c 'kubectl apply -f /vagrant/example/local-pv.yaml'
vagrant ssh -c 'kubectl apply -f /vagrant/example/local-pvc.yaml'
vagrant ssh -c 'kubectl apply -f /vagrant/example/pvc.yaml'
vagrant ssh -c 'kubectl apply -f /vagrant/example/demo.yaml'
