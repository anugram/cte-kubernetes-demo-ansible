#!/bin/bash

source ./automation_modules/getToken.sh
function createKubernetesStorageGroup() {
    token=`getToken`

    header1="accept: application/json"
    header2="Authorization: Bearer ${token}"
    header3="Content-Type: application/json"
    cm_host=`cat ./automation_modules/vars/main.json | jq -r '.cm_host'`
    cm_kubernetes_policy_name=`cat ./automation_modules/vars/main.json | jq -r '.cm_kubernetes_policy_name'`
    cm_kubernetes_storage_group_name=`cat ./automation_modules/vars/main.json | jq -r '.cm_kubernetes_storage_group_name'`
    sc_name=`cat ./automation_modules/vars/main.json | jq -r '.cm_kubernetes_storage_class'`
    namespace=`cat ./automation_modules/vars/main.json | jq -r '.cm_kubernetes_namespace'`
    
    schema=`cat ./automation_modules/schema/createKubernetesStorageGroupSchema.json | jq -r '.'`
    payload=`jq -c --arg k8s_sg_name "$cm_kubernetes_storage_group_name" --arg k8s_sc_name "$sc_name" --arg k8s_namespace "$namespace" --arg profile "DefaultClientProfile" '.name = $k8s_sg_name | .k8s_storage_class = $k8s_sc_name | .k8s_namespace = $k8s_namespace | .client_profile = $profile' <<< "$schema"`
    __URL="https://${cm_host}/api/v1/transparent-encryption/csigroups/"
    
    response=`curl -k ${__URL} -H "${header1}" -H "${header2}" -H "${header3}" --data-binary "${payload}" --compressed`
    sgId=`echo ${response} | jq -r '.id'`

    cp ./automation_modules/schema/setSgPolicySchema.json /tmp/temp1.json
    sed -i "s/replaceIt!/$cm_kubernetes_policy_name/g" /tmp/temp1.json
    __Policy_URL="https://${cm_host}/api/v1/transparent-encryption/csigroups/${sgId}/guardpoints/"
    policySchema=`cat /tmp/temp1.json | jq -r '.'`
    payload=`jq -c <<< "$policySchema"`
    echo ${payload}
    __policy_response=`curl -k ${__Policy_URL} -H "${header1}" -H "${header2}" -H "${header3}" --data-binary "${payload}" --compressed`
    echo ${__policy_response}
    rm -f /tmp/temp1.json
    echo ${sgId};
}
