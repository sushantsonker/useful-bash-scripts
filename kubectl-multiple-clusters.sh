#!/bin/bash
kubectl config get-contexts | awk '{print $1}' > contexts.txt
awk '!/*/' contexts.txt > temp && mv temp contexts.txt
awk '!/CURRENT/' contexts.txt > temp && mv temp contexts.txt

manifest=manifest.yaml

# command to delete specific manifest from all clusters"
cmd1="kubectl --cluster=$LINE delete -f $manifest"

# command to retrieve a resource from all clusters
cmd2="kubectl get cm -n tigera-operator"

# command to patch a resource
cmd3="kubectl  patch <resource> <resource_name>  -p '{\"spec\": {\"<attribute>\": [\"<value>\"]}}'"

# command to apply a manifest
cmd4="kubectl apply -f $manifest"

# cmd6
cmd5="kubectl get clusterinformations.projectcalico.org default -o yaml | grep -i "cnxVersion" | awk '{print $2}'"


while IFS= read -r LINE; do
    kubectl config use-context $LINE
    version=$cmd 2>&1
    version=$(kubectl get clusterinformations.projectcalico.org default -o yaml | grep -i "cnxVersion" | awk '{print $2}' 2>&1)
    echo "$LINE - " + $version >> version-info.txt
done < contexts.txt
