#!/bin/bash

source ./automation_modules/getToken.sh
source ./automation_modules/getUser.sh
source ./automation_modules/createKubernetesPolicyKey.sh
source ./automation_modules/createKubernetesPolicy.sh

token=`getToken`
user=`getUser`
keyName=`createKubernetesPolicyKey`
policy=`createKubernetesPolicy`
echo ${token}
echo ${user}
echo ${keyName}
echo ${policy}
