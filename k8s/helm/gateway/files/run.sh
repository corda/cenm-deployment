#!/bin/sh
{{ if eq .Values.bashDebug true }}
set -x
{{ end }}

#
# main run
#
if [ -f bin/gateway.jar ]
then
{{ if eq .Values.bashDebug true }}
    sha256sum bin/gateway.jar 
    cat gateway.conf
{{ end }}
    echo
    echo "CENM: starting CENM Gateway service ..."
    echo
    java -jar bin/gateway.jar --config-file etc/gateway.conf
    EXIT_CODE=${?}
else
    echo "Missing gateway service jar file."
    EXIT_CODE=110
fi

if [ "${EXIT_CODE}" -ne "0" ]
then
    HOW_LONG={{ .Values.sleepTimeAfterError }}
    echo
    echo "Gateway service failed - exit code: ${EXIT_CODE} (error)"
    echo
    echo "Going to sleep for requested ${HOW_LONG} seconds to let you login and investigate."
    echo
fi

sleep ${HOW_LONG}
echo