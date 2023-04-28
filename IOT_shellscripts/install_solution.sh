#!/bin/bash

#Deployment pre-requisite script will come here below
#if [[ $? -eq 1 ]]
#then
    #echo "Deployment pre-requisites script executed Successfully..."
#else
    #echo "Deployment pre-requisites script failed..."
    #exit 2
#fi

#Setting value of datadir
datadir=$(grep -ioP "^datadir\s*:\s*\K(.*)" vars/vars.yml)

# Setting value of homepath
homepath=$(grep -ioP "^homepath\s*:\s*\K(.*)" vars/vars.yml)

if [[ $datadir == "" ]]
then
    datadir=/opt
fi

mkdir -p $datadir/.ansible

if [ -d $homepath/.ansible ]
then
    rm -rf $homepath/.ansible
else
    echo " "
fi

ln -s $datadir/.ansible $homepath/.ansible

#Run the main playbook until phziot only! --> below
ansible-playbook main.yml

if [[ $? -eq 0 ]]
then
    echo "ansible playbook Executed Successfully..."
else
    echo "ansible playbook main.yml failed..."
    exit 5
fi

workdir=$(pwd)

cd $datadir/registry_files/deployment-scripts/cohesion-prerequisite && chmod +x cohesion-prerequisite.sh && chmod +x utils && ./cohesion-prerequisite.sh -n phziot

if [[ $? -eq 0 ]]
then
    echo "Cohesion pre-requisite script was successfully executed..."
else
    echo "Cohesion pre-requisite script execution failed..."
    exit 6
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
else
    echo "Cohesion installation failed..."
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

echo "DEPLOYMENT AUTOMATION STATUS: SUCCESS"
