#!/bin/bash
# Bash Inventory script for Pace CCDC Team Linux Environment
# Version 1.0.0
# Written by Daniel Barr
# 
# ---------------------------------------------------------------------
# Free to use by all teams. Please realize you are using this script
# at your own risk. The author holds no liability and will not be held
# responsible for any damages done to systems or system configurations.
# ---------------------------------------------------------------------
# This script will query various system resources in an effort to gain 
# a clearer picture of what is taking place on the system. This should 
# be used as a starting point/cheatsheet for team members. Ongoing 
# monitoring will be necessary to ensure effective measures are being
# taken.
# ---------------------------------------------------------------------
# The goal of this inventory script is to efficiently gather relavant
# information quickly for effective system monitoring during the Collegiate Cyber
# Defense Competition. This tool-set represents a larger overall strategy
# and should be tailored to your specific team.


#        VARIABLES SECTION
# ----------------------------------

user='PaceCCDCTeam'
today="$(date)"                                                                        
hostname=$(hostname)                                                                             # Get the system hostname
operatingSystem=$(lsb_release -d | awk -F' ' '{ print $2,$3 }')                                  # Get operating system type & version information
services=$(systemctl list-units --type=service --state=running --all)                            # List all running services on the system
service_files=$(systemctl list-unit-files --type=service)                                        # List all services on the system
yumrepos=$(yum repolist enabled |sed 1,5d)                                                       # List of all repositories installed on the system
yuminstalled=$(yum list installed |sed 1,2d)                                                     # List all installed packeges on the system
process_tree=$(pstree -pnh)                                                                      # Create a process tree of all currently running processes
users=$(getent passwd |awk -F':' '{ print $1 }')                                                 # Get a list of all Users on the system
systemUsers=$(getent passwd | grep -vwFf /etc/shells |awk -F: '{printf("%s:%s\n",$1,$3)}')       # Categorize  System/Service Users on the system
standardUsers=$(getent passwd | grep -wFf /etc/shells |awk -F: '{printf("%s:%s\n",$1,$3)}')      # Categorize  Standard Users on the system
shellsCount=$(getent passwd | grep -vwFf /etc/shells|wc -l)                                      # Count the System/Service users on the system
totalStandard=$(echo "$standardUsers" | wc -l)                                                   # Count the Standard users on the system
totalUsers=$(echo "$users" | wc -l)                                                              # Count the total users on the system
groupMembership=$(cat /etc/passwd | awk -F':' '{ print $1}' | xargs -n1 groups)                  # Get a list of all users categorized by group membership
loggedInUsers=$(w)                                                                               # List all currently logged in users
lastloggon=$(lastlog)                                                                            # Pull last logon information from system
adapterName=$(sudo /sbin/ip route get 8.8.8.8 | awk '{ print $5; exit }')                        # Get the current network adapter 
longIPAddress=$(sudo /sbin/ip route get 8.8.8.8 | awk '{ print $7 }') 	                         # Find internal IPAddress
_ipAddress=$(echo "$longIPAddress" | awk '{$1=$1};1')                 	                         # Remove trailing space from longIPAddress
ipAddress=$(hostname -I)													                     # Confirm internal IP Address
extipAddress=$(curl -s ifconfig.me/ip)									                         # Pull external IP Address from website
dfGateway=$(sudo /sbin/ip route get 8.8.8.8 | awk '{ print $3; exit }')	                         # Find the default gateway
macAddress=$(ip link show "$adapterName"|sed 1d |awk '{print $2}')                               # Get active network interface MAC address
routingtable=$(ip route show all)				  							                     # Get the routing table
interface_list=$(nmap --iflist |sed 1,2d)                                                        # List all network interfaces on the system
interface_stats=$(ip -s link)                      		  							             # Get interface statistics
ports=$(nmap -p 1-65535 -sV "$longIPAddress"|sed 1,3d)                                           # Get a list of all ports on the system
listening_ports=$(ss -taulpe)												                   	 # Get tcp,udp,listening,process id's,numeric ports
socket_files=$(lsof -i)                                                                          # Get a list of all files with network connections
protocol_stats=$(ss -s)                                                                          # Get network statistics by protocol type
firewall_rules=$(iptables -L)													                 # List all firewall rules
etc_hosts=$(cat /etc/hosts)												                         # Read the /etc/hosts file

#         FUNCTIONS SECTION
# ----------------------------------

users(){
  echo -e "\e[93m   User Account Information  "
  echo -e "-----------------------------\e[0m"
  echo -e "Total Users:                     \e[92m$totalUsers\e[0m"
  echo -e "Total System User Accounts:      \e[92m$shellsCount\e[0m"
  echo -e "Total Standard User Accounts:    \e[92m$totalStandard\e[0m"
  echo 
  echo -e "\e[93m         Users  List         "   
  echo -e "-----------------------------\e[0m"
  echo -e "\e[95m$users\e[0m"
  echo
  echo -e "\e[93m        System  Users        "
  echo -e "-----------------------------\e[0m"
  echo "System User Accounts List (Username:UID)"
  echo
  echo -e "\e[95m$systemUsers\e[0m"
  echo
  echo
  echo -e "\e[93m       Standard Users        "
  echo -e  "-----------------------------\e[0m"
  echo "Standard User Account List (Username:UID)"
  echo
  echo -e "\e[95m$standardUsers\e[0m"
  echo
  echo -e "\e[93m  Group Memberships by User  "
  echo -e "-----------------------------\e[0m"
  echo
  echo -e "\e[95m$groupMembership\e[0m"
  echo
  echo -e "\e[93m       Logged In Users       "
  echo -e "-----------------------------\e[0m"
  echo
  echo -e "\e[91m$loggedInUsers\e[0m"
  echo
  echo -e "\e[93m   Last Login of Each User   "
  echo -e "-----------------------------\e[0m"
  echo
  echo -e "\e[95m$lastloggon\e[0m"
  echo
}
 
ipAddress(){

  echo -e "Adapter Name:        \e[92m$adapterName\e[0m"
  echo -e "Default Gateway:     \e[92m$dfGateway\e[0m"
  echo -e "IP Address:          \e[92m$_ipAddress\e[0m"
  echo -e "Internal IP Address: \e[92m$longIPAddress\e[0m"
  echo -e "External IP Address: \e[92m$extipAddress\e[0m"
  echo -e "MAC Address:         \e[92m$macAddress\e[0m"
  echo
}
networking(){
  echo -e "\e[93m    Network Interfaces    "
  echo -e "-----------------------------\e[0m"
  echo
  echo -e "\e[96m$interface_list\e[0m"
  echo
  echo -e "\e[93m        Routing Table        "
  echo -e "-----------------------------\e[0m"
  echo
  echo -e "\e[96m$routingtable\e[0m"
  echo
  echo -e "\e[93m       Ports & Services       "
  echo -e "------------------------------\e[0m"
  echo
  echo -e "\e[96m$ports\e[0m"
  echo
  echo -e "\e[93m        Listening Ports       "
  echo -e "------------------------------\e[0m"
  echo
  echo -e "\e[96m$listening_ports\e[0m"
  echo
  echo -e "\e[93m     Open Network Sockets     "
  echo -e "------------------------------\e[0m"
  echo -e "\e[96m$socket_files\e[0m"					  									
  echo
  echo -e "\e[93m     Interface Statistics     "
  echo -e "------------------------------\e[0m"
  echo
  echo -e "\e[96m$interface_stats\e[0m"
  echo
  echo -e "\e[93m  Network Stat's by Protocol  "
  echo -e "------------------------------\e[0m"
  echo
  echo -e "\e[96m$protocol_stats\e[0m"				  										
  echo
  echo -e "\e[93m        Firewall Rules        "
  echo -e "------------------------------\e[0m"
  echo
  echo -e "\e[91m$firewall_rules\e[0m"
  echo
  echo -e "\e[93m  '/etc/hosts' File Contents  "
  echo -e "------------------------------\e[0m"
  echo
  echo -e "\e[91m$etc_hosts\e[0m"
  echo
}

services(){
    
  echo -e "\e[93m      Running  Services      "
  echo -e "-----------------------------\e[0m" 
  echo
  echo -e "\e[92m$services\e[0m"
  echo
  echo -e "\e[93m     Installed  Services     "
  echo -e "-----------------------------\e[0m"
  echo
  echo -e "\e[92m$service_files\e[0m"
  echo
  echo -e "\e[93m   Software  Repositories   "
  echo -e "-----------------------------\e[0m"
  echo
  echo -e "\e[92m$yumrepos\e[0m"
  echo
  echo -e "\e[93m Installed Software Packages "
  echo -e "-----------------------------\e[0m"
  echo
  echo -e "\e[92m$yuminstalled\e[0m"
  echo
  echo -e "\e[93m      Running Processes      "
  echo -e "-----------------------------\e[0m"
  echo
  echo -e "\e[92m$process_tree\e[0m"
  echo
}

#   REPORT SECTION
# ---------------------

echo -e "\e[93m--------------------------------------------------------"
echo "-                  System Inventory                    -"   		  	#print title
echo -e "--------------------------------------------------------\e[0m"
echo
echo -e "Date Created: \e[92m$today\e[0m"
echo -e "Created By: \e[92m$user\e[0m"
echo
echo -e "\e[93m--------------------------------------------------------"
echo "-            Operating System Information              -"
echo -e "--------------------------------------------------------\e[0m"
echo 
echo -e "\e[97mHostname:\e[0m            \e[92m$hostname\e[0m"
echo -e "Operating System:    \e[92m$operatingSystem\e[0m"
echo
ipAddress
users

echo -e "\e[93m--------------------------------------------------------"
echo "-               Networking  Information                -"
echo -e "--------------------------------------------------------\e[0m"
echo

networking

echo -e "\e[93m--------------------------------------------------------"
echo "-            Services & Process Information             -"
echo -e "--------------------------------------------------------\e[0m"
echo

services
