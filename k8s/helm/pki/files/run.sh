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

if [ -f {{ .Values.pkiJar.path }}/pkitool.jar ]
then
{{ if eq .Values.bashDebug true }}
    sha256sum {{ .Values.pkiJar.path }}/pkitool.jar
    cat {{ .Values.pkiJar.configPath }}/{{ .Values.pkiJar.configFile }}
{{ end }}
    echo
    echo "CENM: starting PKI Tool process ..."
    echo
    echo "time java -Xmx{{ .Values.pkiJar.xmx }} -jar {{ .Values.pkiJar.path }}/pkitool.jar --config-file {{ .Values.pkiJar.configPath }}/{{ .Values.pkiJar.configFile }}"
    time java -Xmx{{ .Values.pkiJar.xmx }} -jar {{ .Values.pkiJar.path }}/pkitool.jar --config-file {{ .Values.pkiJar.configPath }}/{{ .Values.pkiJar.configFile }}
    EXIT_CODE=${?}
else
    echo "Missing PKI Tool jar file in {{ .Values.pkiJar.path }} directory:"
    ls -al {{ .Values.pkiJar.path }}
    EXIT_CODE=110
fi

if [ "${EXIT_CODE}" -ne "0" ]
then
    HOW_LONG={{ .Values.sleepTimeAfterError }}
    echo
    echo "PKI Tool failed - exit code: ${EXIT_CODE} (error)"
    echo
    echo "Going to sleep for requested ${HOW_LONG} seconds to let you login and investigate."
    echo
else
    touch ./DATA/PKITOOL-DONE
    ls -al ./DATA/
    HOW_LONG=0
fi

sleep ${HOW_LONG}
echo