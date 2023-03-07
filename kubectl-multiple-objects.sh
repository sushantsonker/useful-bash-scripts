#!/bin/bash
#kubectl get pods -n kube-system | grep Evicted | awk '{print $1}' | xargs kubectl delete pod -n kube-system
kubectl get ns | grep appname | awk '{print $1}' > namespaces.txt


#cmd1="kubectl --cluster=$LINE delete -f $manifest"
#cmd2="kubectl get cm -n tigera-operator"

while IFS= read -r LINE; do
    kubectl  label ns $LINE app-id=test
done < namespaces.txt > output.txt
