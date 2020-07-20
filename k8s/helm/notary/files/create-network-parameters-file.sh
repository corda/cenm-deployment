#!/bin/sh
{{ if eq .Values.bashDebug true }}
set -x
pwd
cat -n etc/notary.conf
{{ end }}

# we need just the filename without full path as this is going to be mounted under different directory in NM
nodeInfoFile=$(basename $(ls additional-node-infos/nodeInfo*))
export nodeInfoFile
echo ${nodeInfoFile}

# we create temp file and rename it to prevent race condition between Notary and Networkmap (case when this file got created but still was empty)
envsubst <<"EOF" > additional-node-infos/network-parameters-initial.conf.tmp
notaries : [
  {
    notaryNodeInfoFile: "notary-nodeinfo/${nodeInfoFile}"
    validating = false
  }
]
minimumPlatformVersion = {{ .Values.mpv }}
maxMessageSize = 10485760
maxTransactionSize = 10485760
eventHorizonDays = 1
EOF

mv additional-node-infos/network-parameters-initial.conf.tmp additional-node-infos/network-parameters-initial.conf
cat additional-node-infos/network-parameters-initial.conf
echo