# Ansible playbook for enable firewall and configure etcd and keepalived on master node

This playbook is intended to configure firewall, etcd and keepalived services on Master Nodes.

## Prerequisites

  1. Ansible installed on the Control Node.
   
  2.  Passwordless SSH connectivity established between Control Node and Master Nodes.
   
  3. firewalld service installed on Master Nodes.
1. 
## Usage

1. Modify vars.yml file with the homepath and siteid (optional) variables.

2.  Set selfsignedcerts variable to false in vars.yml if you have cert and key files in the files folder.
3.  
4.  Run the playbook using the following command:
    css
      ansible-playbook -i inventory.ini playbook.yml

## Playbook Tasks

Task 1: Enable Firewall and Configure Changes for etcd and keepalived

This task enables the firewalld service and adds the IP addresses of Master and Build nodes to the firewall rule. It also adds the port 2022 to the public zone and reloads the firewall.

Task 2: Create Logs Folder and Files

This task creates a logs folder for etcd and keepalived services and creates log files for etcd.log and keepalived.log.

Task 3: Add Configuration Line to rsyslog.conf

# Second play book part:

1. Include variables from a vars.yml file.
   
2. Start the firewalld service and add IP addresses to trusted zones.
   
3. Delete specific directories to upgrade the registry.
   
4. Extract the deployment-scripts.tgz file.
   
5. Change the ownership of the registry directory to root.
   
6. Copy the templates for the upgrade.
   
7. Ensure the chartmuseum-charts directory exists.
   
8.  Check if the cohesion-prerequisite file exists and move it outside the templates directory if it does.
   
# third palybook part :

1. Overall, this playbook automates the deployment process and ensures that the old versions of the applications are removed before the new versions are installed.
2. It also includes several checks and wait times to ensure that the deployment process is smooth and error-free.