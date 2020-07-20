#!/bin/sh
{{ if eq .Values.bashDebug true }}
set -x
{{ end }}

#
# main run
#
if [ -f {{ .Values.nmapJar.path }}/networkmap.jar ]
then
{{ if eq .Values.bashDebug true }}
    sha256sum {{ .Values.nmapJar.path }}/networkmap.jar 
    cat {{ .Values.nmapJar.configPath }}/networkmap-init.conf
{{ end }}
    echo
    echo "CENM: starting Network Map process ..."
    echo
    TOKEN=$(cat {{ .Values.nmapJar.configPath }}/token)
    ls -alR
    set -x
    java -jar {{ .Values.nmapJar.path }}/angel.jar \
    --jar-name={{ .Values.nmapJar.path }}/networkmap.jar \
    --zone-host={{ .Values.prefix }}-zone \
    --zone-port=25000 \
    --token=${TOKEN} \
    --service=NETWORK_MAP \
    --polling-interval=10 \
    --working-dir=etc/ \
    --network-truststore=/opt/cenm/{{ .Values.networkRootTruststore.path }} \
    --truststore-password={{ .Values.networkRootTruststore.password }} \
    --root-alias={{ .Values.rootAlias }} \
    --network-parameters-file={{ .Values.nmapJar.configPath }}/network-parameters.conf \
    --tls=true \
    --tls-keystore=/opt/cenm/DATA/key-stores/corda-ssl-network-map-keys.jks \
    --tls-keystore-password=password \
    --tls-truststore=/opt/cenm/DATA/trust-stores/corda-ssl-trust-store.jks \
    --tls-truststore-password=trust-store-password \
    --verbose
    EXIT_CODE=${?}
else
    echo "Missing Network Map jar file in {{ .Values.nmapJar.path }}/ directory:"
    ls -al {{ .Values.nmapJar.path }}
    EXIT_CODE=110
fi

if [ "${EXIT_CODE}" -ne "0" ]
then
    HOW_LONG={{ .Values.sleepTimeAfterError }}
    echo
    echo "Network Map failed - exit code: ${EXIT_CODE} (error)"
    echo
    echo "Going to sleep for requested ${HOW_LONG} seconds to let you login and investigate."
    echo
fi

sleep ${HOW_LONG}
echo
