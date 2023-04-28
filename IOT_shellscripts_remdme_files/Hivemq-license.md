# Bash Script: Applying Site Specific License to HiveMQ

This script applies a site-specific license to HiveMQ in a Kubernetes cluster.

# Prerequisites

   1. Kubernetes cluster
  
   2. kubectl command-line tool installed and configured to access the cluster
  
   3. Access to the TimescaleDB database in the Kubernetes cluster

# Instructions 
   1. Set the datadir variable to the directory where the MQTT licenses are stored.

   2. Retrieve the name of the current site from the TimescaleDB database using the kubectl command and store it in the site_name variable.

   3. Remove any whitespace characters from the site_name variable and store the result in the site variable.

   4. Check if the site_name variable is empty. If it is, print an error message and exit the script.

   5. Change the current directory to the mqtt-licenses directory.

   6. Create a configmap using the kubectl command with the --from-file flag pointing to the site-specific license file, and the --dry-run and -o yaml flags to output the configmap in YAML format. Replace the existing configmap with the new one using the replace subcommand.

   7. Scale down the phziot-hivemq-replica deployment to 0 replicas.

   8. Wait for 10 seconds to allow for the scaling down to complete.
   
   9. Scale up the phziot-hivemq-replica deployment to 2 replicas.

# Note
   1. Before executing this shell script please check the whatever require software packages and dependences.