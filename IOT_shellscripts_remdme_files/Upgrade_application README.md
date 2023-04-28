This shell script performs a series of tasks related to the deployment.
Here is a brief description of what the script does:

## Required Softwares to be installed
- kubectl
- ansible
- helm

## Instructions
1. Copy the tarfile and untar it.
2. Run the shell script

## Usage
The `deploy.sh` script will execute the following tasks:
1. Create a backup directory in /files/backup.
2. Check if the kubectl and Ansible are installed on the system. If not, the script exits with an error message.
3. If kubectl is installed, the script backs up the configuration files for the application.
4. If Ansible is installed, the script executes an Ansible playbook called "upgrade_application.yml".
5. If the playbook execution success, displays playbook execution succeeds.
6. Now change for dir /opt/iot/registry_files/deployment-scripts/cohesion-prerequisite. here chmod +X to cohesion-prerequisite.sh and executing the code.
7. Now with the help of Helm installing chartmuseum/cohesion by chnaging the cohesion-frontend.loadBalancerIP=cohesion_frontend_ip
5. Wait for the WSO2 pod to become running. If it is in a pending state, the script will scale down other pods to free up resources.
6. Once the WSO2 pod is running, the script will scale up other pods that were previously scaled down.

## Note
- If any of the pre-requisites are not installed, the script will exit with an error message.
- If any of the tasks fail, the script will exit with an error message.