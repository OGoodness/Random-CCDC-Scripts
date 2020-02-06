#!/bin/bash
# Bash install script for Pace CCDC Team CentOS Splunk Indexer
# Version 1.2.5
# Written by Daniel Barr
#
# ---------------------------------------------------------------------
# Free to use by all teams. Please realize you are using this script
# at your own risk. The author holds no liability and will not be held
# responsible for any damages done to systems or system configurations.
# ---------------------------------------------------------------------
# This script will install OSQUERY 4.1.1 endpoint visibility agent,
# and SPLUNK INDEXER and other dependencies. In addition it will download
# the predetermined configuration files.
# ---------------------------------------------------------------------
# Take note these configurations may need to be adjusted by the user as
# needed. Every environment is different and should be treated as such.
# ---------------------------------------------------------------------
# The goal of this install script is to efficiently deploy the necessary
# tool-sets for effective system monitoring during the Collegiate Cyber
# Defense Competition. This tool-set represents a larger overall strategy
# and should be tailored to your specific team.

#                             Go Home
# ---------------------------------------------------------------------
cd ~/

#                         INITIAL UPDATE
# ---------------------------------------------------------------------
#
# Install GITHUB, WGET, LSB_RELEASE, NMAP
echo -e "\e[92mDate Run: $(date)"
echo
echo -e "This script will install OSQUERY 4.1.1 endpoint visibility agent,"
echo -e "and SPLUNK INDEXER and other dependencies. In addition it will download"
echo -e "the predetermined configuration files.\e[0m "
echo
echo -e "\e[95mUpdating System..."
echo -e "This may take some time..."
sudo yum clean all | tee 'install.file'
echo "..................."
sudo yum -y update | tee -a 'install.file'
echo "[*] Complete."
echo
sleep 5
#                         YUM PACKAGES INSTALL
# ---------------------------------------------------------------------
echo "Installing Dependencies..."
echo
sudo yum -y install git wget redhat-lsb-core nmap yum-utils lsof epel-release | tee -a 'install.file'
echo
echo -e "[*] Complete.\e[0m"
echo
sleep 5
#                         CONFIG DOWNLOADS
# ---------------------------------------------------------------------

#mkdir /tmp/CCDC-Setup/
#cd /tmp/CCDC-Setup/
#git clone https://github.com/dbarr914/CCDC.git

#
#                         SPLUNK INDEXER INSTALL
# ---------------------------------------------------------------------

disable_hugh_pages(){
 echo "never" > /sys/kernel/mm/transparent_hugepage/enabled
 echo "never" > /sys/kernel/mm/transparent_hugepage/defrag
 echo "[Unit]" > /etc/systemd/system/disable-thp.service
 echo "Description=Disable Transparent Huge Pages" >> /etc/systemd/system/disable-thp.service
 echo "" >> /etc/systemd/system/disable-thp.service
 echo "[Service]" >> /etc/systemd/system/disable-thp.service
 echo "Type=simple" >> /etc/systemd/system/disable-thp.service
 echo 'ExecStart=/bin/sh -c "echo never > /sys/kernel/mm/transparent_hugepage/enabled && echo never > /sys/kernel/mm/transparent_hugepage/defrag"' >> /etc/systemd/system/disable-thp.service
 echo "Type=simple" >> /etc/systemd/system/disable-thp.service
 echo "" >> /etc/systemd/system/disable-thp.service
 echo "[Install]" >> /etc/systemd/system/disable-thp.service
 echo "WantedBy=multi-user.target" >> /etc/systemd/system/disable-thp.service
 systemctl daemon-reload
 systemctl start disable-thp
 systemctl enable disable-thp
 echo
 echo "[*] Transparent Huge Pages (THP) Disabled."
 echo
}

increase_ulimit(){
 echo "[*] Increasing ulimit..."
 ulimit -n 64000
 ulimit -u 20480
 echo "DefaultLimitFSIZE=-1" >> /etc/systemd/system.conf
 echo "DefaultLimitNOFILE=64000" >> /etc/systemd/system.conf
 echo "DefaultLimitNPROC=20480" >> /etc/systemd/system.conf
 echo
 echo "[*] ulimit Increased."
 echo
}

download_splunk(){
 cd /tmp
 echo
 echo  "[*] Downloading Splunk....."
 wget -O splunk-8.tgz 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.1&product=splunk&filename=splunk-8.0.1-6db836e2fb9e-Linux-x86_64.tgz&wget=true'
 echo
 echo "[*] Splunk Downloaded."
 echo
 }

install_splunk(){
 echo "[*] Installing Splunk....."
 tar -xzvf /tmp/splunk-8.tgz -C /opt | tee -a 'install.file'
 echo
 echo "[*] Splunk Enterprise Installed."
 echo
 rm -f /tmp/splunk-8.tgz
}

add_user(){
 echo "[*] Creating Splunk User....."
 useradd splunk
 chown -R splunk:splunk /opt/splunk
 echo
 echo "[*] Splunk User Created."
 echo
}

initial_run(){
 echo
 echo "[*] Running initial start....."
 echo
 sudo /opt/splunk/bin/splunk start --accept-license
 sudo /opt/splunk/bin/splunk stop | tee -a 'install.file'
 echo
 echo "[*] Complete."
 echo
 echo "[*] Enabling Splunk to start at boot....."
 echo
 sudo /opt/splunk/bin/splunk enable boot-start
 echo
 echo "[*] Complete."
 echo
}

enable_ssl(){
 echo "[*] Enabling SSL....."
 echo
 echo "[settings]" > /opt/splunk/etc/system/local/web.conf
 echo "enableSplunkWebSSL = true" >> /opt/splunk/etc/system/local/web.conf
 echo
 echo "[*] SSL enabled for Splunk Web using self-signed certificate."
 echo
}

firewall_rules(){
 echo -e "\e[92m[*] Opening Splunk firewall ports....."
 echo
 afz=`firewall-cmd --get-active-zone | head -1`
 echo "[*] Opening port 8000..."
 echo
 firewall-cmd --zone=$afz --add-port=8000/tcp --permanent
 echo
 echo "[*] Opening port 8065..."
 echo
 firewall-cmd --zone=$afz --add-port=8065/tcp --permanent
 echo
 echo "[*] Opening port 8089..."
 echo
 firewall-cmd --zone=$afz --add-port=8089/tcp --permanent
 echo
 echo "[*] Opening port 8191..."
 echo
 firewall-cmd --zone=$afz --add-port=8191/tcp --permanent
 echo
 echo "[*] Opening port 9997..."
 echo
 firewall-cmd --zone=$afz --add-port=9997/tcp --permanent
 echo
 echo "[*] Opening port 8080..."
 echo
 firewall-cmd --zone=$afz --add-port=8080/tcp --permanent
 echo
 echo "[*] Reloading Firewall..."
 echo
 firewall-cmd --reload
 echo
 echo -e "[*] Firewall ports opened.\e[0m"
 echo
}

adjust_inputs(){
 echo
 echo "[*] Adding receiver to configuration files....."
 echo
 echo "[splunktcp]" > /opt/splunk/etc/system/local/inputs.conf
 echo "[splunktcp://9997]" >> /opt/splunk/etc/system/local/inputs.conf
 echo "index = main" >> /opt/splunk/etc/system/local/inputs.conf
 echo "disabled = 0" >> /opt/splunk/etc/system/local/inputs.conf
 echo "" >> /opt/splunk/etc/system/local/inputs.conf
 echo
 echo "[*] Enabled Splunk TCP input over 9997."
 echo
}

splunk_check(){
 if [[ -f /opt/splunk/bin/splunk ]]
         then
                 echo "Splunk Enterprise $(cat /opt/splunk/etc/splunk.version | head -1) has been installed, configured, and started!"
                 echo
                 echo "Visit the Splunk server using https://hostNameORip:8000 as mentioned above."
                 echo
                 echo "                        HAPPY SPLUNKING!!!"
                 echo
         else
                 echo -e "\e[91m[!]Splunk Enterprise has FAILED install!\e[0m"
 fi
}

#                           EDIT SPLUNK INPUTS
# ---------------------------------------------------------------------

edit_inputs(){
 echo "[*] Editing Splunk's input file...."

 cd /opt/splunk/etc/system/local

 echo -e "[monitor:///var/log/osquery/osqueryd.results.log]\nindex = osquery\nsourcetype = osquery:results\n\n" >> inputs.conf
 echo -e "[monitor:///var/log/osquery/osqueryd.*ERROR*]\nindex = osquery\nsourcetype = osquery:error\n\n" >> inputs.conf
 echo -e "[monitor:///var/log/osquery/osqueryd.*WARNING*]\nindex = osquery\nsourcetype = osquery:warning\n\n" >> inputs.conf
 echo -e "[monitor:///var/log/osquery/osqueryd.snapshot.log\nindex = osquery\nsourcetype = osquery:snapshots\n\n" >> inputs.conf

 echo "[*] Complete."
 echo "[*] Adding directories to monitor..."
 echo
 cd /opt/splunk/bin/

 # sudo ./splunk add monitor /var/log
 # sudo ./splunk add monitor /etc/

 echo "[*] Complete."
 echo
 echo "[*] Adding indexes..."
 echo
 sudo ./splunk add index osquery
 sudo ./splunk add index threathunting
 sudo ./splunk add index windows
 sudo ./splunk add index bro
 echo
 echo "[*] Complete."
 echo
 echo "[*] Restarting Splunk..."
 echo
 sudo ./splunk restart | tee -a 'install.file'
 sleep 5
 echo
 sudo ./splunk status
 echo "[*] Complete."
 echo
}


#                          OSQUERY INSTALL
# ---------------------------------------------------------------------

download_osquery(){
 cd /tmp
 echo
 echo -e "\e[95m[*] Downloading Osquery Agent......"
 echo
 wget https://pkg.osquery.io/rpm/osquery-4.1.1-1.linux.x86_64.rpm
 echo
 echo "[*] Osquery Agent Downloaded."
 echo
 }

install_osquery(){
 echo -e "[*] Installing Osquery User Agent....."
 echo
 sudo rpm -i osquery-4.1.1-1.linux.x86_64.rpm | tee -a 'install.file'
 echo
 echo -e "[*] Osquery Agent Installed.\e[0m"
 echo
 rm -f /tmp/osquery-4.1.1-1.linux.x86_64.rpm
}



#                    MOVE CONFIGS TO CORRECT LOCATIONS
# ---------------------------------------------------------------------

config_osquery(){

 cp "/tmp/CCDC-Setup/CCDC/osquery/1.Linux/osquery.conf" /etc/osquery/osquery.conf
 cp "/tmp/CCDC-Setup/CCDC/osquery/1.Linux/osquery.flags" /etc/osquery/osquery.flags
 cp -rf "/tmp/CCDC-Setup/CCDC/osquery/1.Linux/packs/" /etc/osquery/
 cp -rf "/tmp/CCDC-Setup/CCDC/osquery/1.Linux/packs/" /usr/share/osquery/

 osqueryctl config-check
 osqueryctl start --flagfile /etc/osquery/osquery.flags --disable_events=false
}

disable_hugh_pages
sleep 1
increase_ulimit
sleep 1
download_splunk
sleep 1
install_splunk
sleep 1
# add_user
# sleep 1
initial_run
sleep 1
splunk_check
# enable_ssl
sleep 1
firewall_rules
sleep 1
adjust_inputs
sleep 1
#mitigate_privs
#sleep 1
edit_inputs
sleep 1
download_osquery
sleep 1
install_osquery
sleep 1
config_osquery
