#!/bin/bash

source ./automation_modules/getToken.sh
source ./automation_modules/getUser.sh
function createKubernetesPolicyKey() {
    token=`getToken`
    user=`getUser`

    header1="accept: application/json"
    header2="Authorization: Bearer ${token}"
    header3="Content-Type: application/json"
    cm_host=`cat ./automation_modules/vars/main.json | jq -r '.cm_host'`
    cm_kubernetes_policy_key_name=`cat ./automation_modules/vars/main.json | jq -r '.cm_kubernetes_policy_key_name'`
    
    schema=`cat ./automation_modules/schema/createKubernetesPolicyKeySchema.json | jq -r '.'`
    payload=`jq -c --arg keyName "$cm_kubernetes_policy_key_name" --arg ownerId "${user}" '.name = $keyName | .meta.ownerId = $ownerId' <<< "$schema"`
    __URL="https://${cm_host}/api/v1/vault/keys2/"
    
    response=`curl -s -k ${__URL} -H "${header1}" -H "${header2}" -H "${header3}" --data-binary "${payload}" --compressed`

    keyName=`echo ${response} | jq -r '.name'`
    echo ${keyName};
}
