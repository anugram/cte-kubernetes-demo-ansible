#!/bin/bash

source ./automation_modules/getToken.sh
source ./automation_modules/getUser.sh

token=`getToken`
user=`getUser`
echo ${token}
echo ${user}
