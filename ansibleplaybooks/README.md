# Ansible Playbooks for Kubernetes-based Connected-Pharma Solution

## Directory Explanation:
**File/Directory Name**    | **Description**
:--------------------------|:----------------------------------------------------------------------------------------------------------------------------
 ansible.cfg               | Configuration file for tuning Ansible and setting directives 
 build_application.yml     | Standalone playbook for deploying the Kuberenetes applications (Run after build_webserver, build_registry, and build_cluster.yml)
 build_cluster.yml         | Standalone playbook for deploying the tri-master Kubernetes cluster (Run after build_webserver and build_registry) 
 build_registry.yml        | Standalone playbook for deploying the local Docker registry and Chartmuseum (Run after build_webserver)
 build_tar.sh              | Shell script for pulling required Docker images and building the solution tarball from within the Cisco network
 build_webserver.yml       | Standalone playbook for deploying the local RPM repository
 buildnode/                | Directory containing tasks to be executed by the buildnode
 certs/                    | Directory for storing Kubernetes certification gathered during initialization
 deployment-scripts/       | Directory containing necessary files for building the local Docker registry and Chartmuseum
 files/                    | Directory containing files required for the deployment such as manifests and python packages
 inventory                 | File defining systems to be used as buildnode and combo hosts
 main.yml                  | Solution playbook that will execute build_webserver, build_registry, build_cluster and build_application in tandem
 master01/                 | Directory containing tasks to be executed by master01
 master02/                 | Directory containing tasks to be executed by master02
 master03/                 | Directory containing tasks to be executed by master03
 masters/                  | Directory containing tasks to be executed by all masters
 pki/                      | Directory for storing certificate information used by etcd
 templates/                | Jinja2 templates used during deployment
 upgrade_application.yml   | Playbook to upgrade the phziot and cohesion charts
 vars/                     | Directory containing file where variables are defined 

