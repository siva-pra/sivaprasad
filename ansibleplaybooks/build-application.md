# Connected Pharma Application Deployment Playbook

This playbook is used to deploy the Connected Pharma Application on a Kubernetes cluster. It installs and configures the necessary components for the application to function correctly.
Requirements

# To use this playbook, you need:

   - A Kubernetes cluster set up and running
  
   - The kubectl command-line tool installed and configured
  
   - The helm command-line tool installed and configured
  
   - Access to a private Docker registry that contains the necessary application images
  
   - An SSL certificate to secure the Docker registry

# Installation and Deployment

## To use this playbook, follow these steps:

  - Clone this repository to your local machine.
  
  - Update the vars.yml file with your environment-specific variables.
  
  - Copy the metallb.yaml and metallbL2-config.j2 files to your build node.

  - Run the playbook using the command: ansible-playbook -i inventory.ini deploy.yml

# The playbook will perform the following actions:

 - Copies the metallb.yaml and metallbL2-config.j2 files to the build node.
 
 - Applies the Metallb configuration to enable load balancing.
 
 - Loads the SSL certificate from the Docker registry.
 
 - Adds the Docker registry as a chart repository in Helm.
 
 - Creates the phziot and monitoring namespaces in Kubernetes.
 
 - Installs the Strimzi Kafka operator in the phziot namespace using Helm.
 
 - Installs the Loki monitoring stack in the monitoring namespace using Helm.
 
 - Installs the Connected Pharma Application in the phziot namespace using Helm.
 
 - Installs the Cohesion frontend in the phziot namespace using Helm, either with a manual load balancer IP or a dynamic load balancer IP.

Once the playbook has completed successfully, you can access the Connected Pharma Application by visiting the IP address of the Cohesion frontend.

# Conclusion

This playbook provides a streamlined way to deploy the Connected Pharma Application on a Kubernetes cluster. By following the steps outlined in this readme file, you can quickly and easily deploy the application and start using it to manage your pharmaceutical supply chain.