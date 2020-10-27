#!/bin/sh
# log in and cache access token
set -x
ACCESS_TOKEN=""
while [ -z "${ACCESS_TOKEN}" ]
do
    TOKEN_RESPONSE="$(curl -X POST --data "grant_type=password" --data "username=admin" --data "password=password" http://${1}:${2}/api/v1/authentication/authenticate)"
    ACCESS_TOKEN="$(echo ${TOKEN_RESPONSE} | jq -r '.access_token')"
    sleep 5
done

pwd
ls -alR

echo
echo "========================= Creating users ========================="
for i in u/*.json
do
    echo ">>>>>>>> User: ${i}"
    cat ${i}; echo
    curl -X POST -H "Authorization: Bearer $ACCESS_TOKEN" -H "Content-Type: application/json" --data-binary "@${i}" http://${1}:${2}/api/v1/admin/users
done

echo
echo "========================= Creating groups ========================="
for i in g/*.json
do
    echo ">>>>>>>> Group: ${i}"
    cat ${i}; echo
    curl -X POST -H "Authorization: Bearer $ACCESS_TOKEN" -H "Content-Type: application/json" --data-binary "@${i}" http://${1}:${2}/api/v1/admin/groups
done

echo
echo "========================= Creating roles ========================="
for i in r/*.json
do
    echo ">>>>>>>> Role: ${i}"
    cat ${i}; echo
    curl -X POST -H "Authorization: Bearer $ACCESS_TOKEN" -H "Content-Type: application/json" --data-binary "@${i}" http://${1}:${2}/api/v1/admin/roles
done