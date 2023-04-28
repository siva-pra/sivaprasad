# SHELL SCRIPT TO MONITOR TIMESCALE_DB CLUSTER WITH KUBERNETES AND PARTONI.

This is a bash script that checks the status of a distributed database system using Kubernetes and Patroni.

# Prerequisites
In order to run this script, you will need the following:

    1. A running Kubernetes cluster with the necessary permissions to run kubectl commands.
    
    2. The kubectl command-line tool installed on your machine.
    
    3. The bash shell installed on your machine.
    
    4. Access to the PATRONI_SUPERUSER_PASSWORD environment variable, which appears to be used to authenticate against the PostgreSQL instances running in the cluster.
    
    5. The curl and pg_isready utilities installed in the containers running the PostgreSQL and Patroni instances.
    
    6. The psql utility installed in the containers running the PostgreSQL instances.

# What it does

This is a bash script that checks the status of a distributed database system using Kubernetes and Patroni. The script performs the following tasks:

    1. Sets some variables related to indentation and spaces.
    
    2. Runs pg_isready to check the connection status for each of the three nodes in the system (ts0, ts1, and ts2) and stores the results in ts0conn, ts1conn, and ts2conn, respectively.
    
    3. Runs curl to get the status information for each of the three nodes using the Patroni API and stores the results in ts0patrA, ts1patrA, and ts2patrA, respectively.
    
    4. Extracts the role and state information from the Patroni status information for each node and stores it in ts0patrRole, ts0patrState, ts1patrRole, ts1patrState, ts2patrRole, and ts2patrState.
    
    5. Prints out the basic connection information for each node and the Patroni status information for each node.
    
    6. Runs a loop over each table in the database and gets the row count for each table on each node using psql. 
    
    7. The script checks if the row counts match for all three nodes and sets the sync_status variable accordingly. 
    
    8. The script then prints out the sync status for each table on each node.

Overall, this script is useful for checking the status of a distributed database system.