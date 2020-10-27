#!/bin/sh

set -x
if [ ! -f {{ .Values.idmanJar.configPath }}/token ]
then
    EXIT_CODE=1
    until [ "${EXIT_CODE}" -eq "0" ]
    do
        echo "CENM: Attempting to login to {{ .Values.prefix }}-gateway:8080 ..."
        java -jar bin/cenm-tool.jar context login -s http://{{ .Values.prefix }}-gateway:8080 -u jenny-editor -p password
        EXIT_CODE=${?}
        if [ "${EXIT_CODE}" -ne "0" ]
        then
            echo "EXIT_CODE=${EXIT_CODE}"
            sleep 5
        else
            break
        fi
    done
    EXIT_CODE=1
    {{ if eq .Values.bashDebug true }}
    cat {{ .Values.idmanJar.configPath }}/identitymanager-init.conf
    {{ end }}
    until [ "${EXIT_CODE}" -eq "0" ]
    do
        ZONE_TOKEN=$(java -jar bin/cenm-tool.jar identity-manager config set -f={{ .Values.idmanJar.configPath }}/identitymanager-init.conf --zone-token)
        EXIT_CODE=${?}
        if [ "${EXIT_CODE}" -ne "0" ]
        then
            echo "EXIT_CODE=${EXIT_CODE}"
            sleep 5
        else
            break
        fi
    done
    echo ${ZONE_TOKEN}
    echo ${ZONE_TOKEN} > {{ .Values.idmanJar.configPath }}/token
    {{ if eq .Values.bashDebug true }}
    cat {{ .Values.idmanJar.configPath }}/token
    {{ end }}
    java -jar bin/cenm-tool.jar identity-manager config set-admin-address -a={{ .Values.prefix }}-idman-internal:{{ .Values.adminListener.port }}
fi
