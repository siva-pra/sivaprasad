
#!/bin/bash

# connetcton between client and remote sever
read -p "enter the usrname :" user
read -p "enter the ip: " remote_ip
#ssh $username@$remote_ip

# copy public key to target machine
ssh-copy-id "$user@$remote_ip" 

# update, upgrade and install nginx SSH into the remote host and install Nginx
ssh $user@$remote_ip << EOF
sudo yum update -y
sudo yum install epel-release -y
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
EOF

# stop http and https firewall in CentOS
sudo systemctl enable firewalld
sudo firewall-cmd --add-port=80/tcp --permanent
sudo firewall-cmd --add-port=443/tcp --permanent
sudo systemctl disable firewalld

#copy the index in remote host
scp /root/index.html $user@$remote_ip:/usr/share/nginx/html/

scp /root/nginx.config $user@$remote_ip:/etc/nginx/

# copy the css file
mkdir -p /root/styles
cp -r /root/styles.css /root/styles/
scp -r /root/styles $user@$remote_ip:/usr/share/nginx/html/

# Restart Nginx
sudo systemctl restart nginx
