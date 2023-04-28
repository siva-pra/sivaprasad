#!/bin/bash

# Install Nginx
sudo apt-get update
sudo apt-get install nginx -y

# Start Nginx
sudo systemctl start nginx

# Enable Nginx to start automatically on boot
sudo systemctl enable nginx

# Allow HTTP AND HTTPS traffic through the firewall
sudo ufw allow 'Nginx HTTP'
sudo ufw allow 'Nginx HTTPS'
# Verify that Nginx is running
sudo systemctl status nginx

# copy contents of source file to destination file
source_dir="/root"
destination_dir="/etc/nginx/sites-enabled/default"

cp "$source_dir/sample.txt" "$destination_dir"

# print success message
echo "Contents of $src_file successfully copied to $dest_file."

# source file to append
src_file="/root/append.txt"

# destination file to append to
dest_file="/etc/nginx/sites-enabled/default"

# restart the ingix 
sudo systemctl restart nginx

# line number to start appending from
start_line=46

# insert contents of source file after start line in destination file
sed -i "${start_line}r ${src_file}" ${dest_file}

# print success message
echo "Contents of $src_file successfully appended to $dest_file starting from line $start_line."

#print the output and store the new file
 #./nginx.sh > /home/ubuntu/logs/mylog.log

# Replace the old IP address with the new IP address in the default file

old_ip="127.0.0.1"
new_ip="0.0.0.0"
sed -i "s/$old_ip/$new_ip/g" /etc/nginx/sites-enabled/default

echo "IP address replaced successfully" 

logfile="/home/ubuntu/logs/mylog.log"

# get the size of the log file in bytes
size=$(stat -c %s "$logfile")

# check if the size is greater than 10MB (10 * 1024 * 1024 bytes)
if [ $size -gt 10485760 ]; then
    # delete the log file
    rm "$logfile"
    # create a new empty log file
    touch "$logfile"
fi
