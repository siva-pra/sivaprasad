#!/bin/bash

function usage(){

    echo "$(basename "$0") [-h] <-m BACKUP_MODE> [-n NAMESPACE] [-p REPLICA_DB_POD_NAME]
    This script is used to backup data for merck solution timescaledb. It can be exeucted again if fails.
where:
    -m Mandatory parameter. Support two backup modes -- full backup and only merck database. Valid values: full|merck
    -n Optional parameter. Namepsace of phziot and cohesion.
    -p Optional parameter. One timescaledb replica pod name. If provided this option, data will be backup from this replica timescaledb pod. If not provided, data will be backup from timescaledb leader pod by default.
    -h show usage
    "
}

if [ $# -eq 0 ];then
    usage;exit 0
fi

while getopts "m:n:p:h:" opt; do
    case "${opt}" in
        m ) BACKUP_MODE=$OPTARG ;;
        n ) NS=$OPTARG ;;
	p ) POD=$OPTARG ;;
        h ) usage;exit ;;
        \?) echo "Invalid Option: -$OPTARG" 1>&2;exit 1;;
        : ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        * ) echo  "Unsupported option: -$OPTARG" >&2; exit 1;;
    esac
done

shift $((OPTIND-1))

if [[ "${BACKUP_MODE}" == "" ]];then
    echo "Missing mandantory option -m" >&2;exit 1
fi

datadir=$(grep -ioP "^datadir\s*:\s*\K(.*)" vars/vars.yml)
DATE=$(date +"%Y-%m-%d")
FULL_DB=${datadir}/cluster-data-backup/full-db-001.sql
MERCK_DB=${datadir}/cluster-data-backup/merck-db-001.sql
LEADER_POD=phziot-timescaledb-0

if [[ ! -d "${datadir}/cluster-data-backup" ]]; then
    mkdir -p ${datadir}/cluster-data-backup
fi

if [ -f "${FULL_DB}.${DATE}" ]; then
    mv ${FULL_DB} ${FULL_DB}.${DATE}
fi

if [ -f "${MERCK_DB}.${DATE}" ]; then
    mv ${MERCK_DB} ${MERCK_DB}.${DATE}
fi

if [[ ! -z $POD  ]];then
    echo "Step 1: Timescaledb pod name is $POD."
    LEADER_POD=$POD
else
    echo "Step 1: Get leader timescaledb pod name"
    if [ -z "${NS}" ]; then
        LEADER_POD=`kubectl exec phziot-timescaledb-0 -- patronictl -c /etc/timescaledb/patroni.yaml list | grep -v "\-\-" | awk 'NR==1 { for (i=1;i<=NF;++i) if ($i=="Member") { n=i; break }} /Leader/ { print $n }'`
    else
        LEADER_POD=`kubectl -n ${NS} exec phziot-timescaledb-0 -- patronictl -c /etc/timescaledb/patroni.yaml list | grep -v "\-\-" | awk 'NR==1 { for (i=1;i<=NF;++i) if ($i=="Member") { n=i; break }} /Leader/ { print $n }'`
    fi
fi

if [[ -z "${LEADER_POD}" || ("${LEADER_POD}" != "phziot-timescaledb-0" && "${LEADER_POD}" != "phziot-timescaledb-1" && "${LEADER_POD}" != "phziot-timescaledb-2") ]]; then
    echo "Didn't find leader timescaledb pod name or wrong replica timescaledb pod name. Please check the parameters again."
    exit 1
fi

echo "Backup data from timescaledb pod ${LEADER_POD}..."

case ${BACKUP_MODE} in
    "full")
    echo "Full backup mode"
    echo -e "\nStep 2: Start to backup everything..."
    if [ -z "${NS}" ]; then
        echo -e "\n\tStep 2.1: Delete the backup file if it exists."
        kubectl exec ${LEADER_POD} -- bash -c "rm -f /home/postgres/dump-001.sql"
        if [[ $? -ne 0 ]]; then
            echo -e "\tFailed to delete old backup file inside leader timescaledb pod."
            exit 2
        fi
        echo -e "\n\tStep 2.2: Do full backup and this will take a long time if there are a lot of data."
        kubectl exec ${LEADER_POD} -- bash -c "/usr/bin/pg_dumpall > /home/postgres/dump-001.sql"
        if [[ $? -ne 0  ]]; then
            echo -e "\tFailed to do full database backup. Please check timescaledb logs for detail."
            exit 3
        fi
        sleep 5s
        echo -e "\n\tStep 2.3: Get the backup file from leader timescale pod. This may take a long time."
        kubectl cp ${LEADER_POD}:/home/postgres/dump-001.sql ${FULL_DB}
        if [[ $? -ne 0  ]]; then
            echo -e "\tFailed to copy the full database backup file from leader timescaledb pod to local."
            echo -e "Please try command `kubectl cp ${LEADER_POD}:/home/postgres/dump-001.sql ${FULL_DB}` manually."
            exit 4
        fi
    else
	    echo -e "\n\tStep 2.1: Delete the backup file if it exists."
        kubectl -n ${NS} exec ${LEADER_POD} -- bash -c "rm -f /home/postgres/dump-001.sql"
        if [[ $? -ne 0  ]]; then
            echo -e "\tFailed to delete old backup file inside leader timescaledb pod."
            exit 2
        fi
        
        echo -e "\n\tStep 2.2: Do full backup and this will take a long time if there are a lot of data."
        kubectl -n ${NS} exec ${LEADER_POD} -- bash -c "/usr/bin/pg_dumpall > /home/postgres/dump-001.sql"
        if [[ $? -ne 0  ]]; then
            echo -e "\tFailed to do full database backup. Please check timescaledb logs for detail."
            exit 3
        fi
        echo "Did full database successfully inside leader timescaledb pod."
        echo -e "\n\tStep 2.3: Get the backup file from leader timescale pod. This may take a long time."
        sleep 5s
        kubectl -n ${NS} cp ${LEADER_POD}:/home/postgres/dump-001.sql ${FULL_DB}
        if [[ $? -ne 0  ]]; then
            echo -e "\tFailed to copy the full database backup file from leader timescaledb pod to local."
            echo -e "Please try command `kubectl cp ${LEADER_POD}:/home/postgres/dump-001.sql ${FULL_DB}` manually."
            exit 4
        fi
    fi
    echo -e "\nFull database backup has done successfully. The backup file is ${FULL_DB}."
    ;;
    "merck")
    echo "Only backup merck database"
    echo -e "\nStep 2: Start to backup merck database..."
    if [ -z "${NS}" ]; then
        echo -e "\n\tStep 2.1: Delete the backup file if it exists."
        kubectl exec ${LEADER_POD} -- bash -c "rm -f /home/postgres/dump-001.sql"
        if [[ $? -ne 0  ]]; then
            echo -e "\tFailed to delete old backup file inside leader timescaledb pod."
            exit 2        
        fi
        
        echo -e "\n\tStep 2.2: Do merck database backup and this will take a long time if there are a lot of data."
        kubectl exec ${LEADER_POD} -- bash -c "pg_dump -d merck > /home/postgres/dump-001.sql"
        if [[ $? -ne 0  ]]; then
            echo -e "\tFailed to do merck database backup. Please check timescaledb log for details."
            exit 3
        fi
        echo -e "\n\tStep 2.3: Get the backup file from leader timescale pod. This may take a long time."
        sleep 5s
        kubectl cp ${LEADER_POD}:/home/postgres/dump-001.sql ${MERCK_DB}
        if [[ $? -ne 0  ]]; then
            echo -e "\tFailed to copy the merck database backup file from leader timescaledb pod to local."
            echo -e "Please try command `kubectl -n ${NS} cp ${LEADER_POD}:/home/postgres/dump-001.sql ${MERCK_DB}` manually."
            exit 4
        fi
    else
        echo -e "\n\tStep 2.1: Delete the backup file if it exists."
        kubectl -n ${NS} exec ${LEADER_POD} -- bash -c "rm -f /home/postgres/dump-001.sql"
        if [[ $? -ne 0  ]]; then
            echo -e "\tFailed to delete old backup file inside leader timescaledb pod."
            exit 2
        fi
        
        echo -e "\n\tStep 2.2: Do merck database backup and this will take a long time if there are a lot of data."
        kubectl -n ${NS} exec ${LEADER_POD} -- bash -c "pg_dump -d merck > /home/postgres/dump-001.sql"
        if [[ $? -ne 0  ]]; then
            echo -e "\tFailed to do merck database backup. Please check timescaledb log for details."
            exit 3
        fi
        echo -e "\n\tStep 2.3: Get the backup file from leader timescale pod. This may take a long time."
        sleep 5s
        kubectl -n ${NS} cp ${LEADER_POD}:/home/postgres/dump-001.sql ${MERCK_DB}
        if [[ $? -ne 0  ]]; then
            echo -e "\tFailed to copy the merck database backup file from leader timescaledb pod to local."
            echo -e "Please try command `kubectl -n ${NS} cp ${LEADER_POD}:/home/postgres/dump-001.sql ${MERCK_DB}` manually."
            exit 4
        fi
    fi
    echo -e "\nMerck database backup has done successfully. The backup file is ${MERCK_DB}."
    ;;
    *)
    echo "This backup mode is NOT supported!"
    exit -1
    ;;
esac

echo -e "\nStep 3: Delete the backup file inside the leader timescaledb pod."
if [ -z "${NS}" ]; then
    kubectl exec ${LEADER_POD} -- bash -c "rm -f /home/postgres/dump-001.sql"
else
    kubectl -n ${NS} exec ${LEADER_POD} -- bash -c "rm -f /home/postgres/dump-001.sql"
fi

echo -e "\n======== Done backup successfully =============="

ls -l ${datadir}/cluster-data-backup

