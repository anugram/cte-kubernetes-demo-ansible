#!/bin/bash

source ./automation_modules/getToken.sh
source ./automation_modules/getCAID.sh
source ./automation_modules/getUser.sh
source ./automation_modules/createKubernetesPolicyKey.sh
source ./automation_modules/createKubernetesPolicy.sh
source ./automation_modules/createKubernetesStorageGroup.sh
source ./automation_modules/createRegistrationToken.sh

policyName=`cat ./automation_modules/vars/main.json | jq -r '.cm_kubernetes_policy_name'`
keyName=`cat ./automation_modules/vars/main.json | jq -r '.cm_kubernetes_policy_key_name'`
sgName=`cat ./automation_modules/vars/main.json | jq -r '.cm_kubernetes_storage_group_name'`
scName=`cat ./automation_modules/vars/main.json | jq -r '.cm_kubernetes_storage_class'`
nsName=`cat ./automation_modules/vars/main.json | jq -r '.cm_kubernetes_namespace'`
regToken=`cat ./automation_modules/vars/main.json | jq -r '.cm_reg_token'`
cmIP=`cat ./automation_modules/vars/main.json | jq -r '.cm_host'`
nfsServerIp=`cat ./automation_modules/vars/main.json | jq -r '.nfs_server_host'`

token=`getToken`
caId=`getCAID`
user=`getUser`
keyName=`createKubernetesPolicyKey`
policy=`createKubernetesPolicy`
echo "**********Policy Created on Ciphertrust Manager**********"
echo "CTE for K8s Policy Name: ${policy}"
sgId=`createKubernetesStorageGroup`
echo "**********Security Group Created on Ciphertrust Manager**********"
echo "CTE for K8s Group Id: ${sgId}"
regToken=`createRegistrationToken`

#regTokenEnc=`echo ${regToken} | base64 -w 0`
cp -rf ./templates/nfs/*.* ./example/
sed -i "s/CM_TOKEN_ENC/$regTokenEnc/g" ./example/cmtoken.yaml
sed -i "s/VAR_NS/$nsName/g" ./example/cmtoken.yaml
sed -i "s/VAR_NS/$nsName/g" ./example/local-pv.yaml
sed -i "s/VAR_NFS_SERVER_IP/$nfsServerIp/g" ./example/local-pv.yaml
sed -i "s/VAR_NS/$nsName/g" ./example/local-pv.yaml
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

#git clone https://github.com/thalescpl-io/ciphertrust-transparent-encryption-kubernetes.git
sudo apt-get install -y nfs-common
sudo systemctl start nfs-utils
sudo systemctl enable nfs-utils
sudo mkdir -p /data/cte
sudo chmod 777 /data/cte
sudo systemctl enable nfs-utils

cd /tmp/ciphertrust-transparent-encryption-kubernetes && ./deploy.sh

kubectl apply -f ./example/createNamespace.yaml
kubectl apply -f ./example/createStorageClass.yaml
kubectl apply -f ./example/cmtoken.yaml
kubectl apply -f ./example/storage.yaml
kubectl apply -f ./example/local-pv.yaml
kubectl apply -f ./example/local-pvc.yaml
kubectl apply -f ./example/pvc.yaml
kubectl apply -f ./example/demo.yaml