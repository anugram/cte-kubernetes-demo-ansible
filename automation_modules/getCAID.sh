#!/bin/bash

source ./automation_modules/getToken.sh
function getCAID() {
    token=`getToken`

    header1="accept: application/json"
    header2="Authorization: Bearer ${token}"
    header3="Content-Type: application/json"

    cm_host=`cat ./automation_modules/vars/main.json | jq -r '.cm_host'`

    __URL="https://${cm_host}/api/v1/ca/local-cas?skip=0&limit=10"

    response=`curl -s -k ${__URL} -H "${header1}" -H "${header2}" -H "${header3}" -H 'Content-Type: application/json' -H 'accept: application/json' --compressed`
    caid=`echo ${response} | jq -r '.resources[0].id'`
    echo ${caid};
}
