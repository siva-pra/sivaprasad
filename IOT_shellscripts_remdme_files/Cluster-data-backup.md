# SHELL SCRIPT to TAKE BACKUP FOR TIMESCALE DATABASE .

This bash script is used to backup data for Merck Solution's TimescaleDB. It supports two backup modes: full backup and only Merck database backup. The script can be executed again if it fails.

# Prerequisites

   1. Kubernetes cluster
   2. kubectl installed
   3. Access to the cluster's TimescaleDB pods

# Usage

./cluste_data_backup.sh [-h] <-m BACKUP_MODE> [-n NAMESPACE] [-p REPLICA_DB_POD_NAME]

where:

    -h shows usage
    -m (mandatory parameter) specifies the backup mode. Valid values are: full for full backup or merck for only Merck database backup.
    -n (optional parameter) specifies the namespace of phziot and cohesion.
    -p (optional parameter) specifies one TimescaleDB replica pod name. If provided, data will be backed up from this replica TimescaleDB pod. If not provided, data will be backed up from the TimescaleDB leader pod by default.

# How to use

To use this Script, Download the script in your local machine cluster_data_backup.sh
    
    1. Give execution permission chmod u+x cluster_data_backup.sh
    
    2. Run ./cluster_data_backup.sh

# What the Script Does

This Script Perform the following actions,

    1.  First it checks the condition if command line arrgument is mentioned or not 
    
    2. Then it uses while and case statement to perform the option

    3. And check for cluster directory in Datadir variable.
    
    4. It will check the pod is available or not .
    
    5. Then it takes backup of the database cluster.
    
   # Examples

    1. To display usage information:

        ./cluster_data_backup.sh -h

    2. To perform a full backup without specifying a namespace or replica pod:
    
        ./cluster_data_backup.sh-m full

    3. To perform a backup of only the Merck database without specifying a namespace or replica pod:
    
        ./cluster_data_backup.sh -m merck

    4. To perform a full backup and specify a namespace:
        
        ./cluster_data_backup.sh -m full -n mynamespace
    
    5. To perform a full backup and specify a replica pod:
        
        ./cluster_data_backup.sh -m full -p mypod
    
    6. To perform a backup of only the Merck database and specify both a namespace and replica pod:
        
        ./cluster_data_backup.sh -m merck -n mynamespace -p mypod
