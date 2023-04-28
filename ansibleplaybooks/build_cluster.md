# Kubernetes Production Setup

This Ansible playbook automates the setup of a Kubernetes cluster in production. It automates the installation of packages like docker, kubeadm, kubelet, and kubectl. This playbook also disables SELinux, stops firewalld, and configures the sysctl parameters needed for Kubernetes.

## Prerequisites

1. Ansible should be installed on the machine from where you want to execute this playbook

2. The target hosts should be accessible via SSH and passwordless authentication should be configured.
   
3.  The target hosts should be running CentOS 7 or later.

## Usage

- This is an Ansible playbook for setting up a Kubernetes production environment. The playbook is designed to run on three master nodes and one build node.

- The playbook starts by including variables from a vars.yml file. It then sets facts for the IP address and hostname of each master node and the build node.

- Next, the playbook disables SELinux, stops the firewall, and configures the sysctl settings. It also disables swap, configures the hostname, and modifies the hosts file to include the IP address and hostname of each master node.

- The playbook then adds an offline repository, updates the Yum cache, and checks if Docker is installed. If Docker is installed, it removes any existing Docker packages and installs several packages including Docker, kubelet, kubeadm, and kubectl.

- After installing the packages, the playbook starts the Docker service and modifies the Docker storage location if a datadir is defined. It then creates the Docker storage location and reloads the system daemon if a datadir is defined. Finally, the playbook restarts the Docker service if a datadir is defined.

- Overall, this playbook automates the setup of a Kubernetes production environment on three master nodes and one build node, making it easier to manage and maintain the environment.

This Ansible playbook appears to be creating an etcd cluster with three master nodes and configuring Keepalived to manage VIPs. Here is a high-level overview of the tasks in each play:

# MASTER01

- Load variables from vars.yml file.
- Set facts to store the hostname and IP address of each master node and the build node.
- Download the cfssl_linux-amd64 and cfssljson_linux-amd64 binaries to the /usr/bin directory of the build node.
- Make the cfssl commands executable.
- Copy three JSON files that contain configuration details for the CA, etcd and the cluster to /opt/ssl directory of the build node.
- Generate a CA certificate and etcd server certificate using the JSON files in /opt/ssl directory.
- Fetch SSL certificates from MASTER01 and store them in the certs directory.
- Copy the SSL certificates from the certs directory to the /etc/etcd/ssl/ directory of MASTER01.
- Copy the etcd01.service template to /etc/systemd/system/etcd.service on MASTER01.
- Set a fact to store the name of the interface with the default IPv4 address of the host.
- Copy the keepalived01.j2 template to /etc/keepalived/keepalived.conf on MASTER01.
- 
# MASTER02

- Load variables from vars.yml file.
- Set facts to store the IP address of each master node.
- Copy SSL certificates from MASTER01 to /etc/etcd/ssl/ directory of MASTER02.
- Copy the etcd02.service template to /etc/systemd/system/etcd.service on MASTER02.
- Set a fact to store the name of the interface with the default IPv4 address of the host.
- Copy the keepalived02.j2 template to /etc/keepalived/keepalived.conf on MASTER02.

# MASTER03

- Load variables from vars.yml file.
- Set facts to store the IP address of each master node.
- Copy SSL certificates from MASTER01 to /etc/etcd/ssl/ directory of MASTER03.
- Copy the etcd03.service template to /etc/systemd/system/etcd.service on MASTER03.
- Set a fact to store the name of the interface with the default IPv4 address of the host.
- Copy the keepalived03.j2 template to /etc/keepalived/keepalived.conf on MASTER03.
- In summary, this playbook automates the creation of an etcd cluster with three master nodes, generates SSL certificates and keys for secure c         communication between the etcd nodes, and configures Keepalived to manage virtual IP addresses for high availability.


- INCLUDE VARIABLES: includes variables from a file called vars.yml
- PAUSE: waits for 15 seconds
- KUBEADM INIT: initializes the Kubernetes cluster using the configuration file /root/kubeadm-config.yaml
- CREATE .kube: creates a .kube directory with the correct permissions and ownership
- REMOVE OLD CONFIG FILE: removes the old Kubernetes configuration file if it exists
- COPY KUBERNETES CONFIG FILE TO HOME: copies the Kubernetes configuration file from /etc/kubernetes/admin.conf to /home/troot/.kube/config with the correct permissions and ownership
- FETCH KUBE CONFIG FILE: fetches the Kubernetes configuration file from /home/troot/.kube/config to files/config
- 
- Next, the playbook includes a variables file called "vars.yml", 
- which presumably contains additional variables that are used elsewhere in the playbook.
- The playbook then creates a directory called ".kube" in the home directory of a user called "troot" (or in the root directory, depending on which path is uncommented), removes an old configuration file (if it exists), and copies a new configuration file called "config" to the ".kube" directory.
- 
- The playbook then replaces a string in the configuration file with the IP address of the load balancer. 
- Finally, the playbook copies a template file called "infrastructure_test.j2" to a file called "infrastructure_test.py" in the root directory.



## License

This playbook is licensed under the MIT License. See the LICENSE file for details.