#!/bin/sh
{{ if eq .Values.bashDebug true }}
set -x
{{ end }}

#
# main run
#
if [ -f bin/farm-application.jar ]
then
{{ if eq .Values.bashDebug true }}
    sha256sum bin/farm-application.jar 
    cat farmservice.conf
{{ end }}
    echo
    echo "CENM: starting CENM Farm service ..."
    echo
    java -jar bin/farm-application.jar --config-file etc/farmservice.conf
    EXIT_CODE=${?}
else
    echo "Missing farm service jar file."
    EXIT_CODE=110
fi

if [ "${EXIT_CODE}" -ne "0" ]
then
    HOW_LONG={{ .Values.sleepTimeAfterError }}
    echo
    echo "Farm service failed - exit code: ${EXIT_CODE} (error)"
    echo
    echo "Going to sleep for requested ${HOW_LONG} seconds to let you login and investigate."
    echo
fi

sleep ${HOW_LONG}
echo