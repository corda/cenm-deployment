#!/bin/sh
{{ if eq .Values.bashDebug true }}
set -x
{{ end }}

#
# main run
#
if [ -f {{ .Values.idmanJar.path }}/identitymanager.jar ]
then
{{ if eq .Values.bashDebug true }}
    sha256sum {{ .Values.idmanJar.path }}/identitymanager.jar
    sha256sum {{ .Values.idmanJar.path }}/angel.jar
    cat {{ .Values.idmanJar.configPath }}/identitymanager.conf
{{ end }}
    echo
    echo "CENM: starting Identity Manager process ..."
    echo
    TOKEN=$(cat {{ .Values.idmanJar.configPath }}/token)
    ls -alR
    java -jar -Dlog4j.configurationFile=log4j2.xml {{ .Values.idmanJar.path }}/angel.jar \
    --jar-name={{ .Values.idmanJar.path }}/identitymanager.jar \
    --zone-host={{ .Values.prefix }}-zone \
    --zone-port=25000 \
    --token=${TOKEN} \
    --service=IDENTITY_MANAGER \
    --working-dir=etc/ \
    --polling-interval=10 \
    --tls=true \
    --tls-keystore=/opt/cenm/DATA/key-stores/corda-ssl-identity-manager-keys.jks \
    --tls-keystore-password=password \
    --tls-truststore=/opt/cenm/DATA/trust-stores/corda-ssl-trust-store.jks \
    --tls-truststore-password=trust-store-password \
    --verbose
    EXIT_CODE=${?}
else
    echo "Missing Identity Manager jar file in {{ .Values.idmanJar.path }} directory:"
    ls -al {{ .Values.idmanJar.path }}
    EXIT_CODE=110
fi

if [ "${EXIT_CODE}" -ne "0" ]
then
    echo
    echo "Identity manager failed - exit code: ${EXIT_CODE} (error)"
    echo
    echo "Going to sleep for the requested {{ .Values.sleepTimeAfterError }} seconds to let you log in and investigate."
    echo
    sleep {{ .Values.sleepTimeAfterError }}
fi

echo