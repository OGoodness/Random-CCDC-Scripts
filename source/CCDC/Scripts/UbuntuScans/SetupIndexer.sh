#!/bin/bash
# Bash Install script for Pace CCDC Team Linux Environment
# Version 1.0.8
# Written by Daniel Barr
#
# ---------------------------------------------------------------------
# Free to use by all teams. Please realize you are using this script
# at your own risk. The author holds no liability and will not be held
# responsible for any damages done to systems or system configurations.
# ---------------------------------------------------------------------
# This script should be used on any Ubuntu Linux system. It will update,
# upgrade, and install the necessary components that we have outlined as
# a team.
# ---------------------------------------------------------------------
# The goal of this install script is to efficiently install relavant
# system tools quickly for effective system monitoring during the Collegiate Cyber
# Defense Competition. This tool-set represents a larger overall strategy
# and should be tailored to your specific team.

#                             Go Home
# ---------------------------------------------------------------------
cd ~/

#                            VARIABLES
# ---------------------------------------------------------------------


#                         INITIAL UPDATE
# ---------------------------------------------------------------------
#
# Install GIT, WGET, NMAP, Fail2Ban, etc.

echo -e "\e[92mDate Run: $(date)"
echo
echo -e "This script will install OSQUERY 4.1.1 endpoint visibility agent,"
echo -e "and Splunk Universal Forwarder and other dependencies. In addition"
echo -e "it will download the predetermined configuration files.\e[0m "
echo
echo -e "\e[95mUpdating System..."
echo -e "This may take some time..."
sudo apt-get update | tee 'install.file'
sleep 5
echo "..................."
sudo apt-get -y upgrade | tee -a 'install.file'
sleep 5
echo "[*] Complete."
echo

#                       APT PACKAGES INSTALL
# ---------------------------------------------------------------------

echo "Installing Dependencies..."
echo
sudo apt-get install -y lsof nmap clamav debsums fail2ban git unzip | tee -a 'install.file'
sleep 5
echo
echo -e "[*] Complete.\e[0m"
echo
#                         CONFIG DOWNLOADS
# ---------------------------------------------------------------------

mkdir /tmp/CCDC-Setup/
cd /tmp/CCDC-Setup/


#                           LYNIS INSTALL
# ---------------------------------------------------------------------


# Uncomment and run the following commands to install lynis system audit
# sudo apt install apt-listchanges
# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C80E383C3DE9F082E01391A0366C67DE91CA5D5F
# sudo apt install -y apt-transport-https
# echo 'Acquire::Languages "none";' | sudo tee /etc/apt/apt.conf.d/99disable-translations
# echo "deb https://packages.cisofy.com/community/lynis/deb/ stable main" | sudo tee /etc/apt/sources.list.d/cisofy-lynis.list
# sudo apt update
# sudo apt install lynis


#                           SPLUNK FORWARDER INSTALL
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
}

add_user(){
 echo "[*] Creating Splunk User....."
 useradd splunk
 chown -R splunk:splunk /opt/splunkforwarder
 echo
 echo "[*] Splunk User Created."
 echo
}

initial_run(){
 echo
 echo "[*] Running initial start....."
 echo
 sudo /opt/splunk/bin/splunk start --accept-license
 sleep 2
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
firewall_rules(){
 echo -e "\e[92m[*] Opening Splunk firewall ports....."
 echo
 sudo ufw default allow outgoing
 echo "[*] Opening port 8000..."
 echo
 sudo ufw allow 8000
 echo
 echo "[*] Opening port 8065..."
 echo
 sudo ufw allow 8065
 echo
 echo "[*] Opening port 8089..."
 echo
 sudo ufw allow 8089
 echo
 echo "[*] Opening port 8191..."
 echo
 sudo ufw allow 8191
 echo
 echo "[*] Opening port 9997..."
 echo
 sudo ufw allow 9997
 echo
 echo "[*] Opening port 8080..."
 echo
 sudo ufw allow 8080
 echo
 echo "[*] Reloading Firewall..."
 echo
 echo "[*] Opening port 514..."
 echo
 sudo ufw allow 514
 echo
 echo
 echo -e "[*] Firewall ports opened.\e[0m"
 echo
 sudo ufw enable
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
 echo -e "\e[93m[*] Downloading Osquery Agent.....\e[0m"
 wget https://pkg.osquery.io/deb/osquery_4.1.1_1.linux.amd64.deb
 echo
 echo -e "\e[93m[*] Osquery Agent Downloaded.\e[0m"
 echo
 }

install_osquery(){
 echo -e "\e[93m[*] Installing Osquery User Agent.....\e[0m"
 sudo dpkg -i osquery_4.1.1_1.linux.amd64.deb
 echo
 echo -e "\e[93m[*] Osquery Agent Installed.\e[0m"
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
deployment_apps
sleep 1
download_osquery
sleep 1
install_osquery
sleep 1
config_osquery
