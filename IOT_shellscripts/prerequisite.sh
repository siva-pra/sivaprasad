#!/bin/bash

read -p "Enter the link from which solution tarball has to be fetched : " link
read -p "Enter the name of the tarball with version to be stored under /opt/iot/tarballs directory : " outputfile_name

echo "Creating tarballs directory under /opt/iot"
cd /opt/iot/ && sudo mkdir -p tarballs

echo

echo "Creating proxy.sh file"
cd ~
cat <<EOF >proxy.sh
#!/bin/bash
export http_proxy=webproxy.merck.com:8080
export https_proxy=webproxy.merck.com:8080
export HTTP_PROXY=webproxy.merck.com:8080
export HTTPS_PROXY=webproxy.merck.com:8080
EOF

echo

echo "Executable permissions to proxy.sh"
chmod +x proxy.sh
echo
echo "Enabling proxy to pull solution tarball"
source proxy.sh

proxy="webproxy.merck.com:8080"
var1=$(printenv http_proxy)
var2=$(printenv https_proxy)
var3=$(printenv HTTP_PROXY)
var4=$(printenv HTTPS_PROXY)

if [ "$var1" == "$proxy" ] && [ "$var2" == "$proxy" ] && [ "$var3" == "$proxy" ] && [ "$var4" == "$proxy" ]
 then
   echo "The Environment variables are properly set"
else
   echo "Check the Environment variables"
   exit
fi

echo
echo "Pulling solution tarball under /opt/iot/tarballs directory"
cd /opt/iot/tarballs && curl -L link -o outputfile_name
cd ~
echo

echo "Creating unset.sh file"
cat <<EOF >unset.sh
#!/bin/bash
unset http_proxy
unset https_proxy
unset HTTP_PROXY
unset HTTPS_PROXY
EOF
echo

echo "Execeutable permissions to unset.sh"
chmod +x unset.sh
echo
echo "Disabling proxy"
source unset.sh

if env | grep -q webproxy; then
    echo "Proxy is not disabled properly, please check Environment variables"
    exit
else
    echo "Proxy is Disabled"
fi

echo
echo "Exracting the tarball under /opt/iot directory"
cd /opt/iot/tarballs && tar -xvfz outputfile_name --directory /opt/iot
echo

echo "Installing ansible offline"
sudo mkdir -p /opt/iot/linux_packages
tar -xzvf /opt/iot/Merck-Packaging/files/merck_repo.tgz --directory /opt/iot/linux_packages
cd /opt/iot/linux_packages/bin && ./ansible_install.sh
cd .. && rm -rf /opt/iot/linux_packages/bin /opt/iot/linux_packages/packages/ /opt/iot/linux_packages/py /opt/iot/linux_packages/repodata/

