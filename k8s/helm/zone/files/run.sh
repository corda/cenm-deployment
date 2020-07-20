#!/bin/sh

#
# main run
#
if [ -f {{ .Values.zoneJar.path }}/zone.jar ]
then
    echo
    echo "CENM: starting up zone process ..."
    echo
    set -x
    java -jar {{ .Values.zoneJar.path }}/zone.jar \
    --user "{{ .Values.database.user }}" \
    --password "{{ .Values.database.password }}" \
    --url "{{ .Values.database.url }}" \
    --driver-class-name "{{ .Values.database.driverClassName }}" \
    --jdbc-driver "{{ .Values.database.jdbcDriver }}" \
    --enm-listener-port "{{ .Values.listenerPort.enm }}" \
    --admin-listener-port "{{ .Values.listenerPort.admin }}" \
    --auth-host "{{ .Values.prefix }}-{{ .Values.authService.host }}" \
    --auth-port "{{ .Values.authService.port }}" \
    --auth-trust-store-location ./DATA/trust-stores/corda-ssl-trust-store.jks \
    --auth-trust-store-password trust-store-password \
    --auth-issuer "http://test" \
    --auth-leeway 5 \
    --run-migration="{{ .Values.database.runMigration }}" \
    --tls=true \
    --tls-keystore=./DATA/key-stores/corda-ssl-identity-manager-keys.jks \
    --tls-keystore-password=password \
    --tls-truststore=./DATA/trust-stores/corda-ssl-trust-store.jks \
    --tls-truststore-password=trust-store-password \
    --verbose
    EXIT_CODE=${?}
else
    echo "Missing zone jar file in {{ .Values.zoneJar.path }} directory:"
    ls -al {{ .Values.zoneJar.path }}
    EXIT_CODE=110
fi
