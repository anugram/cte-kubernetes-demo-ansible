#!/bin/bash

source ./automation_modules/getToken.sh
source ./automation_modules/getUser.sh
function createKubernetesPolicy() {
    token=`getToken`
    user=`getUser`
    
    header1="accept: application/json"
    header2="Authorization: Bearer ${token}"
    header3="Content-Type: application/json"
    cm_host=`cat ./automation_modules/vars/main.json | jq -r '.cm_host'`
    cm_kubernetes_policy_name=`cat ./automation_modules/vars/main.json | jq -r '.cm_kubernetes_policy_name'`
    cm_kubernetes_policy_key_name=`cat ./automation_modules/vars/main.json | jq -r '.cm_kubernetes_policy_key_name'`

    #Create Resource Set for tmp-data
    __URL_RS="https://${cm_host}/api/v1/transparent-encryption/resourcesets/"
    schema_RS=`cat ./automation_modules/schema/createResourceSetSchema.json | jq -r '.'`
    payload_RS=`jq -r <<< "$schema_RS"`
    echo "curl -k ${__URL_RS} -H "${header1}" -H "${header2}" -H "${header3}" --data-binary "${payload_RS}" --compressed"
    response_RS=`curl -k ${__URL_RS} -H "${header1}" -H "${header2}" -H "${header3}" --data-binary "${payload_RS}" --compressed`
    echo ${response_RS}
    rsID=`echo ${response_RS} | jq -r '.id'`
    
    cp ./automation_modules/schema/createKubernetesPolicySchema.json ./automation_modules/schema/temp.json
    sed -i "s/replaceIt/$cm_kubernetes_policy_key_name/g" ./automation_modules/schema/temp.json
    sed -i "s/RESOURCE_SET_ID/$rsID/g" ./automation_modules/schema/temp.json
    cat ./automation_modules/schema/temp.json
    schema=`cat ./automation_modules/schema/temp.json | jq -r '.'`
    
    payload=`jq -r --arg policyName "$cm_kubernetes_policy_name" '.name = $policyName' <<< "$schema"`
    __URL="https://${cm_host}/api/v1/transparent-encryption/policies/"
    response=`curl -s -k ${__URL} -H "${header1}" -H "${header2}" -H "${header3}" --data-binary "${payload}" --compressed`
    rm -f /automation_modules/schema/temp.json 
    policyName=`echo ${response} | jq -r '.name'`
    echo ${policyName};
}
