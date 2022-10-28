#!/bin/bash

source ./automation_modules/getToken.sh
source ./automation_modules/getUser.sh
source ./automation_modules/createKubernetesPolicyKey.sh
source ./automation_modules/createKubernetesPolicy.sh
source ./automation_modules/createKubernetesStorageGroup.sh

token=`getToken`
user=`getUser`
keyName=`createKubernetesPolicyKey`
policy=`createKubernetesPolicy`
echo "**********Policy Created on Ciphertrust Manager**********"
echo "CTE for K8s Policy Name: ${policy}"
sgId=`createKubernetesStorageGroup`
echo "**********Security Group Created on Ciphertrust Manager**********"
echo "CTE for K8s Group Id: ${sgId}"
#echo ${token}
#echo ${user}
#echo ${keyName}
#echo ${policy}
