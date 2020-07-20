#!/bin/sh

if [ ! -f {{ .Values.signerJar.configPath }}/token ]
then
    EXIT_CODE=1
    until [ "${EXIT_CODE}" -eq "0" ]
    do
        echo "Trying to login to {{ .Values.prefix }}-farm:8080 ..."
        java -jar bin/cenm-tool.jar context login -s http://{{ .Values.prefix }}-farm:8080 -u jenny-editor -p password
        EXIT_CODE=${?}
        echo "EXIT_CODE=${EXIT_CODE}"
        sleep 5
    done
    
    java -jar bin/cenm-tool.jar signer config set-admin-address -a={{ .Values.prefix }}-signer:{{ .Values.adminListener.port }}
fi
