#!/bin/bash

'''
  UCI CCDC Hardening 2020
        _________ ______
    ___/   \     V      \
   /  ^    |\    |\      \
  /_O_/\  / /    | ‾‾‾\  |
 //     \ |‾‾‾\_ |     ‾‾
//      _\|    _\|

      zot zot, thots.
'''

if [[ $EUID -ne 0 ]]; then
	printf 'Must be run as root, exiting!'
	exit 1
fi

# Variables

## Files to backup
declare -a backup=(/etc/sysctl.conf /etc/pam.conf /etc/host.conf /etc/sysconfig /etc/ssh/sshd_config)

#log () { printf "\033[01;30m$(date)\033[0m: %s\n" }

# Install & Configure

## Setup logging
mkdir -p ~/logs/initial
cd ~/logs
cp -R /var/log/ .s
mv log initial
cd ~

## Backup important files
mkdir -p ~/backup/etc/ssh
for file in ${backup[@]}; do 
	[[ -e $file ]] && cp $file ~/backup$file
done
chattr -R +i ~/backup # Make backup folder readonly

## SSH shit
if [ -f "/etc/ssh/sshd_config" ]; then
	sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
	[ ! $(grep 'PermitRootLogin' /etc/ssh/sshd_config) ] && echo 'PermiRootLogin no' >> /etc/ssh/sshd_config
	sed -i 's/PermitEmptyPasswords yes/PermitEmptyPasswords no/' /etc/ssh/sshd_config
	[ ! $(grep 'PermitEmptyPasswords' /etc/ssh/sshd_config) ] && echo 'PermitEmptyPasswords no' >> /etc/ssh/sshd_config
	 
	printf "\033[01;30m$(date)\033[0m: %s\n" "Modified sshd_config, restarting"
   service sshd restart
fi

## This was for CyberPatriot but might still apply
[[ -e /etc/lightdm/lightdm.conf ]] && echo "allow-guest=false" >> /etc/lightdm/lightdm.conf && sudo restart lightdm

## Modify /etc/sysctl.conf
wget https://raw.githubusercontent.com/UCI-CCDC/CCDC2020/master/configs/sctlconf
sysctl -p sctlconf
printf "\033[01;30m$(date)\033[0m: %s\n" "Configured /etc/sysctl.conf"

## IPv6 is the future but I ain't ready for it
if [ -f "/etc/modprobe.d/aliases" ]; then
	cp /etc/modprobe.d/aliases /etc/modprobe.d/aliases.old #make a backup just in case
	sed -i 's/alias net-pf-10 ipv6/alias net-pf-10 off\nalias ipv6 off/' /etc/modprobe.d/aliases
	printf "\033[01;30m$(date)\033[0m: %s\n" "Disabled IPv6"
fi

## Enable Firewall
which ufw && sudo ufw enable

## Disable IP Forwarding
echo 0 | sudo tee /proc/sys/net/ipv4/ip_forward

## Disable IP Spoofing
echo "nospoof on" | sudo tee -a /etc/host.conf

## Remove anything world-readable from home directories
sudo chmod 0750 /home/


## Install & update utilities
if [ $(which apt-get) ]; then # Debian based
	apt-get update -y -q
	apt-get upgrade -y -q
	#apt-get install snoopy vim auditd -y -q
	#auditctl –e 1
elif [ $(which yum) ]; then
	yum update
elif [ $(which pacman) ]; then 
	pacman -Syy
	pacman -Su
elif [ $(which apk) ]; then # Alpine
	apk update
	apk upgrade
fi

chattr +i /etc/passwd /etc/shadow # oof

tar -czvf webstuff.tar.gz /var/www/

if [ $(which apache2) ]; then
	wget -O /etc/apache2/zot.conf https://raw.githubusercontent.com/UCI-CCDC/CCDC2020/master/configs/zot.conf 
	sudo a2enmod headers
	sudo a2enmod rewrite
	sudo a2enmod ratelimit
	sudo a2enmod security
	service apache2 restart
	cp /etc/apache2/apache2.conf /etc/apache2/apache.conf.old
	sudo echo "Include zot.conf" >> /etc/apache2/apache2.conf
	sudo echo "<html><h1>Error 403. File access forbidden.</h1><br/><h1>Loading debug info, please wait...</h1><!-- Debug info inserted at runtime --><img src=https://www.apache.org/foundation/press/kit/asf_logo.png></html>" > /etc/apache2/error.html
fi

if [ $(which nginx) ]; then
	git config --file=/etc/php5/fpm/php.ini expose_php 'Off'
cat > /etc/nginx/zot.conf << EOF
add_header X-Frame-Options "SAMEORIGIN";
add_header X-XSS-Protection "1; mode=block";
http {
	server_tokens off;
}
server {
	error_page 401 403 404 /404.html;
	location /wp-admin/ {
		allow $(hostname -I);
		deny all;
	}
}
if ($request_method !~ ^(GET|HEAD|POST)$ ) {
       return 405;
}
EOF
	echo "include /etc/nginx/zot.conf" >> /etc/nginx/nginx.conf
	/etc/init.d/nginx restart
fi
