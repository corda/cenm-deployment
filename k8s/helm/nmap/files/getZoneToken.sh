#!/bin/sh

set -x

echo "Waiting for notary-nodeinfo/network-parameters-initial.conf ..."
until [ -f notary-nodeinfo/network-parameters-initial.conf ]
do
    sleep 10
done
echo "Waiting for notary-nodeinfo/network-parameters-initial.conf ... done."

ls -al notary-nodeinfo/network-parameters-initial.conf
cp notary-nodeinfo/network-parameters-initial.conf {{ .Values.nmapJar.configPath }}/
cat {{ .Values.nmapJar.configPath }}/network-parameters-initial.conf

cat {{ .Values.nmapJar.configPath }}/networkmap-init.conf

if [ ! -f {{ .Values.nmapJar.configPath }}/token ]
then
    EXIT_CODE=1
    until [ "${EXIT_CODE}" -eq "0" ]
    do
        echo "Trying to login to {{ .Values.prefix }}-gateway:8080 ..."
        java -jar bin/cenm-tool.jar context login -s http://{{ .Values.prefix }}-gateway:8080 -u network-maintainer -p p4ssWord
        EXIT_CODE=${?}
        if [ "${EXIT_CODE}" -ne "0" ]
        then
            echo "EXIT_CODE=${EXIT_CODE}"
            sleep 5
        else
            break
        fi
    done
    cat ./notary-nodeinfo/network-parameters-initial.conf
    ZONE_TOKEN=$(java -jar bin/cenm-tool.jar zone create-subzone \
        --config-file={{ .Values.nmapJar.configPath }}/networkmap-init.conf --network-map-address={{ .Values.prefix }}-nmap-internal:{{ .Values.adminListener.port }} \
        --network-parameters=./notary-nodeinfo/network-parameters-initial.conf --label=Main --label-color='#941213' --zone-token)
    echo ${ZONE_TOKEN}
    echo ${ZONE_TOKEN} > {{ .Values.nmapJar.configPath }}/token
    {{ if eq .Values.bashDebug true }}
    cat {{ .Values.nmapJar.configPath }}/token
    {{ end }}
fi
