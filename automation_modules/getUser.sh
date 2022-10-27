#!/bin/bash

source ./automation_modules/getToken.sh
function getUser() {
    token=`getToken`  
    cm_host=`cat ./automation_modules/vars/main.json | jq -r '.cm_host'`
    header1="accept: application/json"
    header2="Authorization: Bearer ${token}"

    __URL="https://${cm_host}/api/v1/auth/self/user/"
    
    response=`curl -s -k ${__URL} -H "${header1}" -H "${header2}" --compressed`
    userId=`echo ${response} | jq -r '.user_id'`
    echo ${userId};
}
