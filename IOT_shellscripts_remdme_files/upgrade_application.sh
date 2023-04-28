#!/bin/bash
# Create the backup dir under files 
mkdir -p files/backup
# Find the kubectl file present or not in under /usr/bin/
# If present backup the phziot-glims config fiel to  files/backup/glims-config-backup.yaml
# Not presnet print kubectl is not installed yet!!!
# eixt 1 means first step sucess move to next step
if [ -f /usr/bin/kubectl ]
then
    kubectl get configmap $(kubectl get configmap -n phziot | grep glims | awk '{ print $1 }') -n phziot -o yaml > files/backup/glims-config-backup.yaml
else
    echo "kubectl is not installed yet!!!"
    exit 1
fi
# Find the ansible-playbook file present or not in under /usr/bin/ansible-playbook
# If present the ansible-playbook install thid  upgrade_application.yml playbook
# Not presnet print nsible is not installed yet!!!
if [ -f /usr/bin/ansible-playbook ]
then
    ansible-playbook upgrade_application.yml
else
    echo "Ansible is not installed yet!!!"
    exit 2
fi
# $? equal to 0  cmd sucess
if [[ $? -eq 0 ]]
then
    echo "ansible playbook Executed Successfully..." 
else
    echo "ansible playbook upgrade_application.yml failed..."
    exit 3 #goto next stage
fi

#Setting value of datadir and run cohesion-prerequisite.sh
datadir=$(grep -ioP "^datadir\s*:\s*\K(.*)" vars/vars.yml) # find the datadir = /opt/ioT/

if [[ $datadir == "" ]] ## empty 
then
    datadir=/opt # go to /opt
fi

workdir=$(pwd) #go to workdir and goto cohesion-prerequisite

cd $datadir/registry_files/deployment-scripts/cohesion-prerequisite && chmod +x cohesion-prerequisite.sh && chmod +x utils && ./cohesion-prerequisite.sh -n phziot

if [[ $? -eq 0 ]]
then
    echo "Cohesion pre-requisite script was successfully executed..."
else
    echo "Cohesion pre-requisite script execution failed..."
    exit 4
fi

cd $workdir

cohesion_frontend_ip=$(grep -ioP "^cohesion_frontend_ip\s*:\s*\K(.*)" vars/vars.yml)

if [ ! -z "$cohesion_frontend_ip" ]
then
    helm install cohesion chartmuseum/cohesion -n phziot --timeout 30m --set cohesion-frontend.loadBalancerIP=$cohesion_frontend_ip
else
    helm install cohesion chartmuseum/cohesion -n phziot --timeout 30m
fi

if [[ $? -eq 0 ]]
then
    echo $'Successfully Installed Cohesion...\n\n'
    sleep 3s
else
    echo "Cohesion installation failed..."
    exit 5
fi

echo "Waiting for 30 seconds"
sleep 30s

lookuptable=$(kubectl get pods -n phziot -o wide | awk '{print $1,$3}')
state=$(echo "$lookuptable" | grep wso2 | awk '{print $2}')
count=0;
flag=0;

until [[ "$state" == "Running" ]]
do
  if [[ "$state" == "Pending" ]]; then
    if [ $flag = 0 ]; then
      echo "wso2 pod is in Pending state and lacks resources"
      echo
      echo "Freeing up resources by scaling down pods"
      echo
      kubectl scale deployment/cohesion-backend -n phziot --current-replicas=1 --replicas=0
      kubectl scale deployment/cohesion-frontend -n phziot --current-replicas=1 --replicas=0
      kubectl scale deployment/phziot-actionmanager -n phziot --current-replicas=1 --replicas=0
      kubectl scale deployment/phziot-discovery -n phziot --current-replicas=1 --replicas=0
      kubectl scale deployment/phziot-pharmaapi -n phziot --current-replicas=1 --replicas=0
      kubectl scale deployment/phziot-hivemq-replica -n phziot --current-replicas=2 --replicas=1
      echo "waiting for one Minute"
      flag=$(( $flag +  1 ))
    fi
   sleep 60s
   lookuptable=$(kubectl get pods -n phziot -o wide | awk '{print $1,$3}')
   state=$(echo "$lookuptable" | grep wso2 | awk '{print $2}')
  else
    if [ $count = 0 ]; then
       echo "wso2 pod is still coming up"
       echo
       count=$(( $count + 1 ))
    fi
   sleep 10s
   lookuptable=$(kubectl get pods -n phziot -o wide | awk '{print $1,$3}')
   state=$(echo "$lookuptable" | grep wso2 | awk '{print $2}')
  fi
done

if [ $flag = 1 ]; then
  echo "wso2 pod has successfully come up. Now, scaling up pods"
  kubectl scale deployment/cohesion-backend -n phziot --current-replicas=0 --replicas=1
  kubectl scale deployment/cohesion-frontend -n phziot --current-replicas=0 --replicas=1
  kubectl scale deployment/phziot-actionmanager -n phziot --current-replicas=0 --replicas=1
  kubectl scale deployment/phziot-discovery -n phziot --current-replicas=0 --replicas=1
  kubectl scale deployment/phziot-pharmaapi -n phziot --current-replicas=0 --replicas=1
  kubectl scale deployment/phziot-hivemq-replica -n phziot --current-replicas=1 --replicas=2
else
  echo "wso2 pod has successfully come up"
fi


if [ -f /usr/bin/kubectl ]
then
    kubectl delete configmap $(kubectl get configmap -n phziot | grep glims | awk '{ print $1 }') -n phziot
    delcfgmpstatus=$?
    sleep 15s
    kubectl create -f files/backup/glims-config-backup.yaml
    restcfgmpstatus=$?
    kubectl delete pod $(kubectl get pods -n phziot | grep glims | awk '{ print $1 }') -n phziot
    poddelstatus=$?
else
    echo "kubectl is not installed yet!!!"
    exit 6
fi

if [[ $delcfgmpstatus -eq 0 && $restcfgmpstatus -eq 0 && $poddelstatus -eq 0 ]]
then
    sleep 3s
else
    echo "Retoring GLIMS config failed..."
    exit 7
fi

cd $workdir && chmod +x hivemq-license.sh && ./hivemq-license.sh

if [[ $? -eq 0 ]]
then
    echo "HiveMQ License applied successfully"
else
    echo "HiveMQ License apply failed"
    exit 8
fi

echo "Waiting for 90 seconds"
sleep 90s 

# if [[ -f /usr/bin/helm ]]
# then
#    helm upgrade --install phziot chartmuseum/phziot -f /opt/iot/registry_files/deployment-scripts/phziot/values-prod.yaml --version 1.10.5 -n phziot
# else
#    echo "helm is not present in the system"
#    exit 7
# fi

# if [[ $? -eq 0 ]]
# then
#     echo "Writing 256 to wal keep segments in timescaledb"
# else
#     echo "Writing 256 to timescaledb Failed"
#     exit 8
# fi

# tdbwalzero=$(kubectl exec -it -n phziot phziot-timescaledb-0 -- bash -c "PGPASSWORD=mjGTt7cmFdhydsER psql -h localhost -U postgres -d merck -t -c 'show wal_keep_segments'")
# tdbwalone=$(kubectl exec -it -n phziot phziot-timescaledb-1 -- bash -c "PGPASSWORD=mjGTt7cmFdhydsER psql -h localhost -U postgres -d merck -t -c 'show wal_keep_segments'")
# tdbwaltwo=$(kubectl exec -it -n phziot phziot-timescaledb-2 -- bash -c "PGPASSWORD=mjGTt7cmFdhydsER psql -h localhost -U postgres -d merck -t -c 'show wal_keep_segments'")

# tdbwalzero="$(echo -e "${tdbwalzero}" | tr -d '[[:space:]]')"
# tdbwalone="$(echo -e "${tdbwalone}" | tr -d '[[:space:]]')"
# tdbwaltwo="$(echo -e "${tdbwaltwo}" | tr -d '[[:space:]]')"

# if [[ "$tdbwalzero" == "256" && "$tdbwalone" == "256" && "$tdbwaltwo" == "256" ]]
# then
#    echo "Timescaledb wal segments updated to 256"
#    echo
# else
#    echo "ERROR: Timescaledb wal segments are not 256 in Database"
#    exit 9
# fi

echo "UPGRADE APPLICATION SCRIPT SUCCESSFULLY EXECUTED"
