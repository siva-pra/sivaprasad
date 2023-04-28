# Redeploy Helm charts

1. This script that redeploy a Helm chart for a platform solution
2. which includes two microservices, phziot and cohesion, in a Kubernetes cluster
3. The script also provides options to retain or delete the database, and install and configure cohesion after the deployment of the platform solution.

## Prerequisites

Before running this script, make sure that the following requirements are met:

- kubectlis installed and configured to connect to the target Kubernetes cluster.
- helm is installed.
- ansible is installed.
- cohesion-prerequisite.sh
- hivemq-license.sh

## Instuctions

This script is useful for deploying a platform solution that includes two microservices in a Kubernetes cluster. It provides the following options:

- Take a backup of GLIMS configuration before deploying the configmap.
- Check the current version of the deployed solution.
- Run an Ansible playbook for application breakdown.
- Provide an option to retain or delete the database.
- we need  Deploying the solution with Old Data wait for 30 sec
- If in case unble to retrive the data delete the pvc and create new pvc and wait few sec
- Next find the cohesion ip and atteched to loadbalancer
- Install and configure cohesion after the deployment of the platform solution.
- Need to check the pod state is running or not
- If the  pod not running reduce the pods replicas and next increment the pods replicas finally it pods are up 
- Delete the backup Glims configuration after deploying 
- Excute HiveMQ License file

