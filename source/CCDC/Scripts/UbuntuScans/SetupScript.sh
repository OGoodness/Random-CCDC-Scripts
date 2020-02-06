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

read -p "What is the IP Address of the Splunk Indexer? " indexerip
echo

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
sudo apt-get install -y lsof nmap clamav debsums fail2ban git | tee -a 'install.file'
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

download_splunk(){
 cd /tmp
 echo
 echo -e "\e[93m[*] Downloading Splunk Universal Forwarder.....\e[0m"
 wget -O splunkforwarder-8.tgz 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.1&product=universalforwarder&filename=splunkforwarder-8.0.1-6db836e2fb9e-Linux-x86_64.tgz&wget=true'
 echo
 echo -e "\e[93m[*] Splunk UFW Downloaded.\e[0m"
 echo
 }

install_splunk(){
 echo -e "\e[93m[*] Installing Splunk Universal Forwarder.....\e[0m"
 sudo tar -xzvf /tmp/splunkforwarder-8.tgz -C /opt
 echo
 echo -e "\e[93m[*] Splunk UFW Installed.\e[0m"
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
 sudo /opt/splunkforwarder/bin/splunk start --accept-license
 sleep 2
 sudo /opt/splunkforwarder/bin/splunk stop | tee -a 'install.file'
 echo
 echo "[*] Complete."
 echo
 echo "[*] Enabling Splunk to start at boot....."
 echo
 sudo /opt/splunkforwarder/bin/splunk enable boot-start
 echo
 echo "[*] Complete."
 echo
}

#                           EDIT SPLUNK INPUTS
# ---------------------------------------------------------------------

edit_inputs(){
 echo "[*] Editing Splunk's input file...."

 cd /opt/splunkforwarder/etc/system/local

 echo -e "[monitor:///var/log/osquery/osqueryd.results.log]\nindex = osquery\nsourcetype = osquery:results\n\n" >> inputs.conf
 echo -e "[monitor:///var/log/osquery/osqueryd.*ERROR*]\nindex = osquery\nsourcetype = osquery:error\n\n" >> inputs.conf
 echo -e "[monitor:///var/log/osquery/osqueryd.*WARNING*]\nindex = osquery\nsourcetype = osquery:warning\n\n" >> inputs.conf
 echo -e "[monitor:///var/log/osquery/osqueryd.snapshot.log\nindex = osquery\nsourcetype = osquery:snapshots\n\n" >> inputs.conf

 echo "[*] Complete."
 echo "[*] Adding directories to monitor..."
 echo
 cd /opt/splunkforwarder/bin/

 # sudo ./splunk add monitor /var/log
 # sudo ./splunk add monitor /etc/

 echo "[*] Complete."
 echo
 echo "[*] Adding forward-server..."
 echo
 sudo ./splunk add forward-server "$indexerip":9997
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

download_splunk
sleep 2
install_splunk
sleep 2
add_user
sleep 2
initial_run
sleep 2
download_osquery
sleep 2
install_osquery
sleep 2
config_osquery
sleep 2
edit_inputs
