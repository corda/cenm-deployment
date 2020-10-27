#!/bin/sh
{{ if eq .Values.bashDebug true }}
set -x
pwd
cat -n etc/notary.conf
{{ end }}

NETWORK_ROOT_TRUSTSTORE=DATA/trust-stores/network-root-truststore.jks

#
# either download network-root-truststore.jks from specified URL ...
#
{{ if .Values.jksSource }}
curl {{ .Values.jksSource }} -o ${NETWORK_ROOT_TRUSTSTORE}
{{ end }}

#
# ... or wait for network-root-truststore.jks to be available
#
while true
do
    if [ ! -f ${NETWORK_ROOT_TRUSTSTORE} ]
    then
        sleep 10
    else
        echo
        echo "md5/sha256 of ${NETWORK_ROOT_TRUSTSTORE}: "
        md5sum ${NETWORK_ROOT_TRUSTSTORE}    | awk '{print $1}' | xargs printf "   md5sum: %65s\n"
        sha256sum ${NETWORK_ROOT_TRUSTSTORE} | awk '{print $1}' | xargs printf "sha256sum: %65s\n"
        echo
        echo
        break
    fi
done

#
# we start CENM services up almost in parallel so wait until idman port is open
#
server=$(echo {{ .Values.prefix }}-{{ .Values.networkServices.doormanURL }} | sed 's/\(.*\):\(.*\)/\1/' )
port=$(echo {{ .Values.networkServices.doormanURL }} | sed 's/\(.*\):\(.*\)/\2/' )
printf "Identity Manager server:%s\n" "${server}"
printf "  Identity Manager port:%s\n" "${port}"
timeout 10m bash -c 'until printf "" 2>>/dev/null >>/dev/tcp/$0/$1; do echo "Waiting for Identity Manager to be accessible ..."; sleep 5; done' ${server} ${port}

# two main reason for endless loop:
#   - repeat in case IdMan is temporarily not available (real life experience ...)
#   - kubernetes monitoring: pod stuck in initContainer stage - helps with monitoring
while true
do
    if [ ! -f certificates/nodekeystore.jks ] || [ ! -f certificates/sslkeystore.jks ] || [ ! -f certificates/truststore.jks ]
    then
        sleep 30 # guards against "Failed to find the request with id: ... in approved or done requests. This might happen when the Identity Manager was restarted during the approval process."
        echo
        echo "Notary: running initial registration ..."
        echo
        java -Dcapsule.jvm.args='-Xmx{{ .Values.cordaJarMx }}G' -jar {{ .Values.jarPath }}/corda.jar \
          initial-registration \
        --config-file={{ .Values.configPath }}/notary.conf \
        --log-to-console \
        --network-root-truststore ${NETWORK_ROOT_TRUSTSTORE}  \
        --network-root-truststore-password trust-store-password
        EXIT_CODE=${?}
        echo
        echo "Initial registration exit code: ${EXIT_CODE}"
        echo
    else
        echo
        echo "Notary: already registered to Identity Manager - skipping initial registration."
        echo
        EXIT_CODE="0"
        break
    fi
done

if [ "${EXIT_CODE}" -ne "0" ]
then
    echo
    echo "Notary initial registration failed - exit code: ${EXIT_CODE} (error)"
    echo
    echo "Going to sleep for the requested {{ .Values.sleepTimeAfterError }} seconds to let you log in and investigate."
    echo
    sleep {{ .Values.sleepTimeAfterError }}
fi
echo
