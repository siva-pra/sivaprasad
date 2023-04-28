# Ansible Playbook to Delete Solution Applications

This Ansible playbook is used to delete solution applications from a specified host.

# Requirements

   -  Ansible installed on the local machine.
   -  Access to the target host(s) via SSH.
   -  Helm and kubectl tools installed on the target host(s).
  
# Usage

  -  Clone this repository to your local machine.
  -  Edit the vars.yml file to set the appropriate values for your environment.
  -  Run the Ansible playbook using the command ansible-playbook application-breakdown.yml -i hosts.
  