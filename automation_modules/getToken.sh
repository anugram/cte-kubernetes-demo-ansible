#!/bin/bash

function getToken() {
    cm_username=`cat ./automation_modules/vars/main.json | jq -r '.cm_username'`
    cm_password=`cat ./automation_modules/vars/main.json | jq -r '.cm_password'`
    cm_host=`cat ./automation_modules/vars/main.json | jq -r '.cm_host'`
    schema=`cat ./automation_modules/schema/getTokenSchema.json | jq -r '.'`

    payload=`jq -c --arg password "$cm_password" --arg username "$cm_username" '.password = $password | .username = $username' <<< "$schema"`

    __URL="https://${cm_host}/api/v1/auth/tokens/"

    response=`curl -s -k ${__URL} -H 'Content-Type: application/json' -H 'accept: application/json' --data-binary ${payload} --compressed`
    token=`echo ${response} | jq -r '.jwt'`
    echo ${token};
}
