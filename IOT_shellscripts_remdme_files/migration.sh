#!/bin/bash

function usage(){

    echo "$(basename "$0") [-h] [-n NAMESPACE]
    This script is used for migartion of data for merck solution timescaledb from 1.5.11 -> 1.7.5. It can be exeucted again if fails.
where:
    -n Optional parameter. Namepsace of phziot and cohesion.
    -h show usage
    "
}
if [ $# -eq 0 ];then
    usage;exit 0
fi

while getopts "n:h:" opt; do
    case "${opt}" in
        n ) NS=$OPTARG ;;
        h ) usage;exit ;;
        \?) echo "Invalid Option: -$OPTARG" 1>&2;exit 1;;
        : ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        * ) echo  "Unsupported option: -$OPTARG" >&2; exit 1;;
    esac
done

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

echo "Step 2: Copy the db migration file into the pod"
kubectl cp /opt/iot/Merck-Packaging/migration-script-1.5.11-to-1.7.5.sql -n ${NS} $LEADER_POD:/home/postgres/migration-script-1.5.11-to-1.7.5.sql

echo "Step 3: Run the Migration Script"
kubectl -n ${NS} exec ${LEADER_POD} -- bash -c "psql -d merck < migration-script-1.5.11-to-1.7.5.sql"

echo -e "\n======== Done Migration successfully =============="
