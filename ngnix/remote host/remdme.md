# Ansible Playbook: Install Nginx and Copy Files

This Ansible playbook is used to install Nginx web server and copy files to the server.
Requirements

    Ansible installed on the control machine
    Target machine with SSH access and a sudo user
    Nginx installation files
    HTML and CSS files to copy to the Nginx server

## Usage

    Clone the repository:

    bash

git clone https://github.com/your-username/your-repository.git

Navigate to the project directory:

bash

cd your-repository

Edit the nginx.yml file and update the hosts, src, and dest variables as per your requirements.

Run the playbook:

css

    ansible-playbook nginx.yml -i inventory

    Note: -i inventory specifies the inventory file to use for the target hosts.

## Playbook

The playbook nginx.yml contains the following tasks:

    Add the EPEL-release repository to the target machine.
    Install Nginx web server on the target machine.
    Copy the index.html file to the default HTML directory of Nginx.
    Copy the styles directory to the default HTML directory of Nginx.
    Copy the custom nginx.config file to the Nginx configuration directory.
    Restart the Nginx service.

yaml

---
- name: Install Nginx and copy files
  hosts: node
  become: true

  tasks:
    - name: Add epel-release repo
      ansible.builtin.yum:
        name: epel-release
        state: present

    - name: Install Nginx
      ansible.builtin.yum:
        name: nginx
        state: present

    - name: Insert Index Page
      ansible.builtin.copy:
        src: /home/devops/ansible/index.html
        dest: /usr/share/nginx/html/index.html
    
    - name:
      ansible.builtin.copy: 
        src: /home/devops/ansible/styles
        dest: /usr/share/nginx/html/
   
    - name: Copy custom config file
      ansible.builtin.copy: 
        src: /home/devops/ansible/nginx.config
        dest: /etc/nginx/nginx.config
      notify:
        - Restart Nginx
        
  handlers:
    - name: Restart Nginx
      ansible.builtin.service:
        name: nginx
        state: restarted

## License

This project is licensed under the MIT License - see the LICENSE file for details.