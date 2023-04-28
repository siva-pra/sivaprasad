# Getting Started

These instructions will help you to get a copy of the script and to execute it on your local machine or Kubernetes cluster.

# Prerequisites

1. You need to have the following tools installed on your local machine or Kubernetes cluster to use this script

2.    kubectl: The Kubernetes   command-line tool

3.    patronictl: The command-line tool for managing TimescaleDB clusters using Patroni

# Options

1.     -h: Displays the usage message
2.    -n: Optional parameter to specify the namespace of phziot and cohesion

# Instructions

1. The script first checks if there are any arguments passed or not. If no arguments are passed, it displays the usage message and exits. 

2. Otherwise, it uses a while loop with the getopts command to parse the options passed to the script. It checks for the -n and -h options and handles them accordingly.

3. The script then sets the LEADER_POD variable to phziot-timescaledb-0. It then looks for the leader TimescaleDB pod name using the patronictl command by executing it inside the pod.

4. It searches for the leader pod by looking for the word "Leader" in the output of the command. If a leader is found, it sets the LEADER_POD variable to the name of the leader pod.

5. After finding the leader pod name, the script copies the migration script file into the pod using the kubectl cp command. It then runs the migration script by executing the psql command inside the pod.

# Licence

1. This project is licensed under the MIT License - see the LICENSE.md file for details.
