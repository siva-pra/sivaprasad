#!/bin/bash

#Setting value of datadir and run cohesion-prerequisite.sh
datadir=$(grep -ioP "^datadir\s*:\s*\K(.*)" vars/vars.yml)

mkdir -p files/backup

echo "Taking backup of GLIMS configuration"
kubectl get configmap $(kubectl get configmap -n phziot | grep glims | awk '{ print $1 }') -n phziot -o yaml > files/backup/glims-config-backup.yaml

if [[ $? -eq 0 ]]
then
    echo "Taking backup of glims config Successfully Done"
else
    echo "Taking glims config backup failed"
    exit 8
fi

str1=$( helm list -n phziot | awk '{print $1,$10}' | grep phziot)
str2=$( helm list -n phziot | awk '{print $1,$10}' | grep cohesion)
phz_ver=$(echo "${str1/phziot/}")
coh_ver=$(echo "${str2/cohesion/}")
echo "The Current deployment is running Platform version$phz_ver and Cohesion version$coh_ver"

sleep 10s

if [ -f /usr/bin/ansible-playbook ]
then
    ansible-playbook application-breakdown.yml
else
    echo "Ansible is not installed yet!!!"
    exit 1
fi

if [[ $? -eq 0 ]]
then
    echo "ansible playbook Executed Successfully..."
else
    echo "ansible playbook application-breakdown.yml failed..."
    exit 2
fi

if (whiptail --title "Database Parameter" --yesno "Do you want to retain data in DB?" 8 78); then
    echo "User Wants to Retain Data"
    echo
    echo "Deploying the solution with Old Data"
    helm install phziot chartmuseum/phziot -n phziot -f $datadir/registry_files/deployment-scripts/phziot/values-prod.yaml -f $datadir/Merck-Packaging/retain-db.yaml --timeout 30m
    if [[ $? -eq 0 ]]; then
      tmp=0;
      echo "The Solution Platform was successfully Deployed with Old Data"
      echo
      echo "Waiting for all pods to come up"
      sleep 360s
    else
      echo "Helm Install Failed"
    fi
else
    echo "User Does not want to Retain Data"
    echo 
    echo "Deleting TimescaleDB PVC's"
    kubectl delete pvc $(kubectl get pvc -n phziot | grep timescale | awk '{print $1}') -n phziot
    echo
    echo "Deploying the solution with Fresh DB"
    helm install phziot chartmuseum/phziot -n phziot -f $datadir/registry_files/deployment-scripts/phziot/values-prod.yaml -f $datadir/Merck-Packaging/fresh-db.yaml --timeout 30m
    if [[ $? -eq 0 ]]; then
      tmp=1;
      echo "The Solution Platform was successfully Deployed with New Database"
      echo
      echo "Waiting for all pods to come up"
      sleep 360s
    else
      echo "Helm Install Failed"
    fi        
fi

cd $datadir/Merck-Packaging
cohesion_frontend_ip=$(grep -ioP "^cohesion_frontend_ip\s*:\s*\K(.*)" vars/vars.yml)

if [ $tmp = 0 ]; then
  if [ ! -z "$cohesion_frontend_ip" ]; then
    helm install cohesion chartmuseum/cohesion -n phziot --timeout 30m --set cohesion-frontend.loadBalancerIP=$cohesion_frontend_ip
  else
    helm install cohesion chartmuseum/cohesion -n phziot --timeout 30m
  fi

  if [[ $? -eq 0 ]]; then
    echo $'Successfully Installed Cohesion...\n\n'
    sleep 30s
  else
    echo "Cohesion installation failed..."
    exit 3
  fi
fi

if [ $tmp = 1 ]; then
  cd $datadir/registry_files/deployment-scripts/cohesion-prerequisite && chmod +x cohesion-prerequisite.sh && chmod +x utils && ./cohesion-prerequisite.sh -n phziot
  if [[ $? -eq 0 ]]
  then
    echo "Cohesion pre-requisite script was successfully executed..."
  else
    echo "Cohesion pre-requisite script execution failed..."
    exit 4
  fi

  if [ ! -z "$cohesion_frontend_ip" ]; then
    helm install cohesion chartmuseum/cohesion -n phziot --timeout 30m --set cohesion-frontend.loadBalancerIP=$cohesion_frontend_ip
  else
    helm install cohesion chartmuseum/cohesion -n phziot --timeout 30m
  fi

  if [[ $? -eq 0 ]]; then
    echo $'Successfully Installed Cohesion...\n\n'
    sleep 30s
  else
    echo "Cohesion installation failed..."
    exit 5
  fi
fi  

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

cd $datadir/Merck-Packaging
if [ -f /usr/bin/kubectl ]
then
    kubectl delete configmap $(kubectl get configmap -n phziot | grep glims | awk '{ print $1 }') -n phziot
    delcfgmpstatus=$?
    sleep 15s
    kubectl apply -f files/backup/glims-config-backup.yaml
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

cd $datadir/Merck-Packaging && chmod +x hivemq-license.sh && ./hivemq-license.sh

if [[ $? -eq 0 ]]
then
    echo "HiveMQ License applied successfully"
else
    echo "HiveMQ License apply failed"
    exit 8
fi

echo "REDEPLOYMENT IS SUCCESSFULLY EXECUTED"

