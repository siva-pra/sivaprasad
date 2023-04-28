# BUILD OFFLINE WEBSERVER

## Prerequisites

This playbook requires the following:

1. Ansible should be installed on the control node.
   
2. The target host should have Python installed and should be reachable through SSH.
   
3. The vars.yml file should contain the following variables:
    datadir: (Optional) The base directory where data will be stored. Defaults to /opt if not set.
    ntp_server: The NTP server to use for time synchronization.

## Use Case

This Ansible playbook can be used to build an offline webserver. The playbook performs the following tasks:

1. Creates a data directory if datadir is specified in vars.yml.
   
2. Creates a directory for the repository and copies the repository archive to the ansible_tmp directory.
   
3. Untars the repository archive and sets up a yum repository for it.
   
4. Stops the firewalld service and starts the chronyd service.(The chronyd service continuously adjusts the system clock to keep it synchronized with the configured N)
   
5. Adds an NTP server and checks if the time is synchronized.
   
6. Installs the required packages (httpd, docker-ce, python3, and kubectl) from the offline repository.
   
7. Starts the docker service and modifies the storage location if datadir is specified in vars.yml.
   
8. Creates a new .ansible directory and installs the Paramiko and Kubernetes client libraries.