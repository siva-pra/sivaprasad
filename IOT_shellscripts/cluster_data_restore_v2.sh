#!/bin/bash

function usage(){

   echo -e "$(basename "$0") [-h] [-r RESTORE_MODE] [-n NAMESPACE]
   This script is used to restore data for merck IoT solucation timescaledb. It can be exuected again if fails.
where:
    -r Support two restore modes -- full or merck, represents full backup and only merck database.
    -n Namepsace of phziot and cohesion.  
    -h show usage
    "
}

if [ $# -eq 0 ];then
    usage;exit 0
fi

while getopts "r:n:h:" opt; do
    case "${opt}" in
        r ) RESTORE_MODE=$OPTARG ;;
        n ) NS=$OPTARG ;;
        h ) usage;exit ;;
        \?) echo "Invalid Option: -$OPTARG" 1>&2;exit 1;;
        : ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        * ) echo  "Unsupported option: -$OPTARG" >&2; exit 1;;
    esac
done

shift $((OPTIND-1))

if [[ "${RESTORE_MODE}" == "" ]];then
    echo "Missing mandantory option -r" >&2;exit 1
fi

datadir=$(grep -ioP "^datadir\s*:\s*\K(.*)" vars/vars.yml)
DATE=$(date +"%Y-%m-%d")
FULL_DB=${datadir}/cluster-data-backup/full-db-001.sql
MERCK_DB=${datadir}/cluster-data-backup/merck-db-001.sql

LEADER_POD=phziot-timescaledb-0

echo "Step 1: Get leader timescaledb pod name"
if [ -z "${NS}" ]; then
    LEADER_POD=`kubectl exec phziot-timescaledb-0 -- patronictl -c /etc/timescaledb/patroni.yaml list | grep -v "\-\-" | awk 'NR==1 { for (i=1;i<=NF;++i) if ($i=="Member") { n=i; break }} /Leader/ { print $n }'`
else
    LEADER_POD=`kubectl -n ${NS} exec phziot-timescaledb-0 -- patronictl -c /etc/timescaledb/patroni.yaml list | grep -v "\-\-" | awk 'NR==1 { for (i=1;i<=NF;++i) if ($i=="Member") { n=i; break }} /Leader/ { print $n }'`
fi

if [[ -z "${LEADER_POD}" ]]; then
    echo "Didn't find leader timescaledb pod name! Please check if the namespace is right or not!"
    exit 1
fi
echo "Leader timescaledb pod name is ${LEADER_POD}"

if [[ ${RESTORE_MODE} == "full" ]]; then
    if [[ ! -f ${FULL_DB} ]]; then
        echo "Cluster data backup file does not exist. Please take backup before restoring"
        exit 2
    fi
    echo "Full restore mode"
    echo -e "\nStep 2: Start to restore everything..." 
    if [ -z "${NS}" ]; then
        echo -e "\n\t Step 2.1: Copy full database backup file into leader timescaledb pod."
        kubectl cp ${FULL_DB} ${LEADER_POD}:/home/postgres/dump-001.sql
        if [[ $? -ne 0 ]]; then
            echo -e "\tFailed to copy the full backup file into leader timescaledb pod."
            exit 3
        fi
        echo -e "\n\t Step 2.2: Start to retore full database file"
        sleep 5s    
        kubectl exec ${LEADER_POD} -- bash -c "psql < /home/postgres/dump-001.sql"
        if [[ $? -ne 0 ]]; then
            echo -e "\tFailed to do full database restore."
            exit 4
        fi
        echo -e "\n\t Step 2.3: Delete the full database file inside leader timescaledb pod."
        kubectl exec ${LEADER_POD} -- bash -c "rm -f /home/postgres/dump-001.sql"
    else
        echo -e "\n\t Step 2.1: Copy full database backup file into leader timescaledb pod."
        kubectl -n ${NS} cp ${FULL_DB} ${LEADER_POD}:/home/postgres/dump-001.sql
        if [[ $? -ne 0 ]]; then
            echo -e "\tFailed to copy the full backup file into leader timescaledb pod."
            exit 3
        fi
        sleep 5s
        echo -e "\n\t Step 2.2: Start to retore full database file"
        kubectl -n ${NS} exec ${LEADER_POD} -- bash -c "psql < /home/postgres/dump-001.sql"
        if [[ $? -ne 0 ]]; then
            echo -e "\tFailed to do full database restore."
            exit 4
        fi
        echo -e "\n\t Step 2.3: Delete the full database file inside leader timescaledb pod."
        kubectl -n ${NS} exec ${LEADER_POD} -- bash -c "rm -f /home/postgres/dump-001.sql"
    fi
    echo -e "\n\t Did full restore successfully."
elif [[ ${RESTORE_MODE} == "merck" ]]; then
    if [[ ! -f ${MERCK_DB} ]]; then
        echo "Cluster data backup file does not exist. Please take backup before restoring"
        exit 2
    fi
    
    echo "Only restore merck database"
    echo -e "\nStep 2: Start to restore only merck database..." 
    if [ -z "${NS}" ]; then
        echo -e "\n\t Step 2.1: Copy merck database backup file into leader timescaledb pod."
        kubectl cp ${MERCK_DB} ${LEADER_POD}:/home/postgres/dump-001.sql
        if [[ $? -ne 0 ]]; then
            echo -e "\tFailed to copy the merck backup file into leader timescaledb pod."
            exit 3
        fi
        sleep 5s
        echo -e "\n\t Step 2.2: Copy drop-merck-db.sql file into leader timescaledb pod."
        kubectl cp ${datadir}/Merck-Packaging/files/db-restore-utilities/drop-merck-db.sql ${LEADER_POD}:/home/postgres/drop-merck-db.sql

        if [[ $? -ne 0 ]]; then
            echo -e "\tFailed to copy drop-merck-db.sql file into leader timescaledb pod."
            exit 4
        fi
        echo -e "\n\t Step 2.3: Drop and re-create merck database before importing the backup data file"
        kubectl exec ${LEADER_POD} -- bash -c "psql < /home/postgres/drop-merck-db.sql"
        if [[ $? -ne 0 ]]; then
            echo -e "\tFailed to drop and re-create merck database. Please check timescaledb log for details."
            exit 5
        fi
        sleep 5s
        echo -e "\n\t Step 2.4: Start to restore merck database from backup file ${MERCK_DB}"
        kubectl exec ${LEADER_POD} -- bash -c "psql -d merck < /home/postgres/dump-001.sql"
        if [[ $? -ne 0 ]]; then
            echo -e "\tFailed to restore merck database. Please check timescaledb log for details."
            exit 6
        fi
    else
        echo -e "\n\t Step 2.1: Copy merck database backup file into leader timescaledb pod."
        kubectl -n ${NS} cp ${MERCK_DB} ${LEADER_POD}:/home/postgres/dump-001.sql
        if [[ $? -ne 0 ]]; then
            echo -e "\tFailed to copy the merck backup file into leader timescaledb pod."
            exit 3
        fi
        sleep 5s
        echo -e "\n\t Step 2.2: Copy drop-merck-db.sql file into leader timescaledb pod."
        kubectl -n ${NS} cp ${datadir}/Merck-Packaging/files/db-restore-utilities/drop-merck-db.sql ${LEADER_POD}:/home/postgres/drop-merck-db.sql

        if [[ $? -ne 0 ]]; then
            echo -e "\tFailed to copy drop-merck-db.sql file into leader timescaledb pod."
            exit 4
        fi
        echo -e "\n\t Step 2.3: Drop and re-create merck database before importing the backup data file"
        kubectl -n ${NS} exec ${LEADER_POD} -- bash -c "psql < /home/postgres/drop-merck-db.sql"
        if [[ $? -ne 0 ]]; then
            echo -e "\tFailed to drop and re-create merck database. Please check timescaledb log for details."
            exit 5
        fi
        sleep 5s
        echo -e "\n\t Step 2.4: Start to restore merck database from backup file ${MERCK_DB}"
        kubectl -n ${NS} exec ${LEADER_POD} -- bash -c "psql -d merck < /home/postgres/dump-001.sql"
        if [[ $? -ne 0 ]]; then
            echo -e "\tFailed to restore merck database. Please check timescaledb log for details."
            exit 6
        fi
    fi
    echo -e "\n\t Restored merck database data successfully."
    
    echo "Step 3: Grant privileges for application users."
    if [ -z "${NS}" ]; then
        echo -e "\n\t Step 3.1: Copy grant-privilege-for-app-users.sql file into leader timescaledb pod."
        kubectl cp ${datadir}/Merck-Packaging/files/db-restore-utilities/grant-privilege-for-app-users.sql ${LEADER_POD}:/home/postgres/grant-privilege-for-app-users.sql
        if [[ $? -ne 0 ]]; then
            echo -e "\tFailed to copy grant-privilege-for-app-users.sql file into leader timescaledb pod."
            exit 7
        fi
        echo -e "\n\t Step 3.2: Execute grant-privilege-for-app-users.sql to grant privilege for application users."
        kubectl exec ${LEADER_POD} -- bash -c "psql -d merck < /home/postgres/grant-privilege-for-app-users.sql"
        if [[ $? -ne 0 ]]; then
            echo -e "\tFailed to execute grant-privilege-for-app-users.sql file. Please check timescaledb log for details."
            exit 8
        fi
        echo -e "\n\t Step 3.3: Delete the backup files inside the leader timescaledb pod."
        kubectl exec ${LEADER_POD} -- bash -c "rm -f /home/postgres/{drop-merck-db.sql,grant-privilege-for-app-users.sql,dump-001.sql}"
    else
        echo -e "\n\t Step 3.1: Copy grant-privilege-for-app-users.sql file into leader timescaledb pod."
        kubectl -n ${NS} cp ${datadir}/Merck-Packaging/files/db-restore-utilities/grant-privilege-for-app-users.sql ${LEADER_POD}:/home/postgres/grant-privilege-for-app-users.sql
        if [[ $? -ne 0 ]]; then
            echo -e "\tFailed to copy grant-privilege-for-app-users.sql file. Please check timescaledb log for details."
            exit 7
        fi
        echo -e "\n\t Step 3.2: Execute grant-privilege-for-app-users.sql to grant privilege for application users."
        kubectl -n ${NS} exec ${LEADER_POD} -- bash -c "psql -d merck < /home/postgres/grant-privilege-for-app-users.sql"
        if [[ $? -ne 0 ]]; then
            echo -e "\tFailed to execute grant-privilege-for-app-users.sql file. Please check timescaledb log for details."
            exit 8
        fi
        echo -e "\n\t Step 3.3: Delete the backup files inside the leader timescaledb pod."
        kubectl -n ${NS} exec ${LEADER_POD} -- bash -c " rm -f /home/postgres/{drop-merck-db.sql,grant-privilege-for-app-users.sql,dump-001.sql}"      
    fi
    echo "Granted privileges for application users successfully."
    
fi

echo -e "\n======== Done restoring successfully =============="
