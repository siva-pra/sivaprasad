# Ansible Offline Registry Builder
## Introduction
​
This Ansible playbook is designed to automate the process of building an offline registry for Kubernetes clusters. It installs necessary tools and copies relevant files to the designated location. The offline registry can be used to store Docker images and Helm charts, which can then be used by Kubernetes clusters that do not have access to the internet.
​
# Requirements
​
   1. Ansible installed on the control machine
  
   2. A target host where the offline registry will be built
  
   3. Internet access to download necessary files
​
# Usage
​
   1. Clone the repository to the control machine.
  
   2. Update the vars.yml file with the appropriate values for your environment.
  
   3. Run the Ansible playbook using the command ansible-playbook build-registry.yml -i hosts
​
# What It Does
​
The Ansible playbook performs the following tasks:
​
   1. Includes the necessary variables from vars.yml.
   
   2.   Retrieves the IP address of the target host.
   
   3.   Creates an Ansible temporary directory.
   
   4.   Creates a deployment directory for the offline registry files.
   
   5.  Checks if the cluster-node-init file exists and removes it if it does.
   
   6.  Installs Helm and k9s.
   
   7.    Copies the deployment-scripts archive to the temporary directory if it does not exist.
   
   8.  Extracts the deployment-scripts archive to the deployment directory.
   
   9.   Changes the ownership of the deployment directory to root.
  
  10.  Ensures that the chartmuseum-charts directory exists with appropriate permissions.
  
  11.    Removes self-signed certificates if selfsignedcerts is set to false.
  
  12.   Adds signed certificates if selfsignedcerts is set to false.
  
  13.    Executes the build-node-init.sh script on the target host.
  
  14.    Fetches the cluster-node-init file from the target host and saves it to the files directory.
  
  15.   Deletes the Ansible temporary directory.
​
# Conclusion
​
This Ansible playbook makes it easy to build an offline registry for Kubernetes clusters. By storing Docker images and Helm charts locally, clusters without internet access can still deploy applications and services without any issues.