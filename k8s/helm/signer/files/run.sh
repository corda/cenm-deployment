#!/bin/sh
{{ if eq .Values.bashDebug true }}
set -x
{{ end }}

#
# main run
#
echo "Waiting for /opt/cenm/HSM/HSM-LOAD-DONE ..."
until [ -f /opt/cenm/HSM/HSM-LOAD-DONE ]
do
  sleep 2
done

if [ -f {{ .Values.signerJar.path }}/signer.jar ]
then
{{ if eq .Values.bashDebug true }}
    sha256sum {{ .Values.signerJar.path }}/signer.jar
    cat {{ .Values.signerJar.configPath }}/{{ .Values.signerJar.configFile }}
{{ end }}
    echo
    echo "CENM: starting Signer process ..."
    echo
    java -Xmx{{ .Values.signerJar.xmx }} -jar {{ .Values.signerJar.path }}/signer.jar --config-file {{ .Values.signerJar.configPath }}/{{ .Values.signerJar.configFile }}
    EXIT_CODE=${?}
else
    echo "Missing Signer jar file in {{ .Values.signerJar.path }} directory:"
    ls -al {{ .Values.signerJar.path }}
    EXIT_CODE=110
fi

if [ "${EXIT_CODE}" -ne "0" ]
then
    HOW_LONG={{ .Values.sleepTimeAfterError }}
    echo
    echo "Signer failed - exit code: ${EXIT_CODE} (error)"
    echo
    echo "Going to sleep for requested ${HOW_LONG} seconds to let you login and investigate."
    echo
fi

sleep ${HOW_LONG}
echo