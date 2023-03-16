#!/bin/bash

# Define the output file name
output_file="cluster_stats.csv"

# Remove the output file if it already exists
if [ -f "$output_file" ]; then
  rm "$output_file"
fi

# Add the header to the output file
echo "Cluster, Disk Used (bytes), Retention Flows" >> "$output_file"

# Get the list of available cluster names from kubectl
clusters=($(kubectl config get-contexts -o=name | awk -F/ '{print $NF}'))

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
  
  # Curl the _cat/allocation endpoint using the elastic password and grep the disk used value
  disk_used=$(curl -s -u "elastic:$elastic_password" "http://localhost:9200/_cat/allocation" | awk '{sum += $6} END {print sum}')
  
  # Get the retention:flows value from the logstorage object
  retention_flows=$(kubectl get logstorage -n tigera-secure | grep retention:flows | awk '{print $2}')
  
  # Print the disk used and retention:flows values for the current cluster, and append to the output file
  echo "$cluster, $disk_used, $retention_flows" >> "$output_file"
  
  # Kill the port forward process
  kill $(jobs -p)
  
done
