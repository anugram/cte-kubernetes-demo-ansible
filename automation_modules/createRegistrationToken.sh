#!/bin/bash

source ./automation_modules/getToken.sh
function createRegistrationToken() {
    token=`getToken`

    header1="accept: application/json"
    header2="Authorization: Bearer ${token}"
    header3="Content-Type: application/json"
    cm_host=`cat ./automation_modules/vars/main.json | jq -r '.cm_host'`
    
    
    __URL="https://${cm_host}/api/v1/client-management/regtokens/"
    
    response=`curl -k ${__URL} -X POST -H "${header1}" -H "${header2}" -H "${header3}" --compressed`
    token=`echo ${response} | jq -r '.token'`

    echo ${token};
}
