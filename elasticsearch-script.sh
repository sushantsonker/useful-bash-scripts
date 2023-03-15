#!/bin/bash

# Define the list of cluster names to iterate through
clusters=("cluster-1" "cluster-2" "cluster-3")

# Loop through each cluster
for cluster in "${clusters[@]}"
do
  echo "Working on cluster: $cluster"
  
  # Set the current context to the cluster
  kubectl config use-context $cluster
  
  # Get the elastic password from the tigera-elasticsearch pod
  elastic_password=$(kubectl get secret tigera-elasticsearch-credentials -n tigera-operator -o=jsonpath='{.data.elastic}' | base64 -d)
  
  # Port forward the Elasticsearch service in tigera-elasticsearch to localhost
  kubectl port-forward service/tigera-elasticsearch 9200:9200 -n tigera-elasticsearch &
  
  # Wait for the port forward to be established
  sleep 5
  
  # Curl the _cat/allocation endpoint using the elastic password
  curl -u "elastic:$elastic_password" "http://localhost:9200/_cat/allocation"
  
  # Kill the port forward process
  kill $(jobs -p)
  
done
