

# Deployment Automation Script 

This script can used for automating the deployment of a softwares. It performs the following tasks:

1. Executes deployment pre-requisite script
2. Sets values of datadir and homepath
3. Creates a .ansible directory in the specified datadir directory
4. Deletes the existing .ansible directory (if any) from homepath directory
5. Creates a symbolic link between datadir/.ansible and homepath/.ansible
6. Runs the main playbook
7. Executes the Cohesion pre-requisite script
8. Install the Cohesion-prereuisite 
9. Applies HiveMQ License 

## Prerequisites

Before running this script, know the following are already installed:

1. Ansible
2. Helm
3. Cohision-prerequisite file
4. HiveMQ license file

Also, know the following files and directories exist in the specified locations:

1. vars/vars.yml - contains variables used in the script
2. $datadir/registry_files/deployment-scripts/cohesion-prerequisite - contains the Cohesion pre-requisite script
3. hivemq-license.sh - contains the HiveMQ License script

## Use Cases

This script can be used to automate the deployment of a software  It is particularly useful in the following scenarios:

1. When deploying to multiple environments (e.g., development, testing, production)


To use this script, simply modify the variables in vars/vars.yml to suit your environment, then run the script with the command:

```
./install_solution.sh
```

If the script executes successfully, it will output the message "DEPLOYMENT AUTOMATION STATUS: SUCCESS". Otherwise, it will output an error message and exit with a non-zero status code.