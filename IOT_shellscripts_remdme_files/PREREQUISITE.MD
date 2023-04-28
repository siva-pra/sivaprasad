# BASH SCRIPT TO INSTALL ANSIBLE OFFLINE

This bash script is designed to fetch a solution tarball from a specified link and store it under /opt/iot/tarballs directory. It also installs Ansible offline on the system.

# Prerequisites

The following prerequisites should be met before running this script:

- The system should have curl installed.
- The system should have tar installed.
- The system should have sudo access.


# HOW TO USE

To use this script, follow the steps below:

    1. Download the script and save it as prerequisite.sh on your system.
    
    2. Open a terminal and navigate to the directory where the script is saved.
    
    3. Run the command sudo chmod +x prerequisite.sh to make the script executable.

    4. Run the command ./prequisite.sh to start the script.
    
    5. Follow the prompts to provide the link from which the solution tarball has to be fetched and the name of the tarball with version to be stored under /opt/iot/tarballs directory.

# What the Script Does

The script performs the following actions:

    1. Creates a tarballs directory under /opt/iot.
    
    2. Creates a proxy.sh file and sets the environment variables for the proxy server.
    
    3. Checks if the environment variables are properly set.
    
    4. Fetches the solution tarball from the specified link and stores it under /opt/iot/tarballs directory.
    
    5. Creates an unset.sh file to disable the proxy.
    
    6. Checks if the proxy is disabled properly.
    
    7. Extracts the tarball under /opt/iot directory.
    
    8. Installs Ansible offline on the system.
   
   # Note

The script assumes that the solution tarball is a .tar.gz file. If the tarball is in a different format, modify the tar command accordingly.