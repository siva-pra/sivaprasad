#!/bin/bash
datadir=/opt/iot
site_name=$(kubectl exec -it -n phziot phziot-timescaledb-0 -- bash -c "psql merck -t -c 'select name from site where is_current=true'")
echo
site="$(echo -e "${site_name}" | tr -d '[[:space:]]')"
echo "The site chosen in this deployment is $site"
sleep 5s

if [[ -z "$site_name" ]]; then
   echo "Retrieval of site information from DB failed"
fi

echo
cd $datadir/mqtt-licences/
echo "Applying Site specific License to hivemq"
kubectl create configmap phziot-hivemq-config -n phziot --from-file=${site} --dry-run=client -o yaml | kubectl replace -f -
echo
echo "License to hivemq has been applied"
echo 

echo "Scaling down hivemq deployment to 0"
kubectl scale -n phziot --current-replicas=2 --replicas=0 deployment/phziot-hivemq-replica
echo "Waiting for Scale up procedure"
sleep 10s
echo 
echo "Scaling up hivemq deployment to 2"
kubectl scale -n phziot --current-replicas=0 --replicas=2 deployment/phziot-hivemq-replica

