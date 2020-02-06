#!/bin/bash

# https://github.com/UCI-CCDC/CCDC2020
#UCI CCDC linux inventory script for os detection and to speed up general operations

#Written by UCI CCDC linux subteam
#UCI CCDC, 2020


if [[ $EUID -ne 0 ]]; then
	printf 'Must be run as root, exiting!\n'
	exit 1
fi

#log () { printf "\033[01;30m$(date)\033[0m: $1\n" }

printf "\n*** generating audit.txt in your home directory\n"
touch $HOME/audit.txt 
adtfile="tee -a $HOME/audit.txt"


#prettyos is the name displayed to user, name is the name for use later in package manager
cat /etc/os-release | grep -w "PRETTY_NAME" | cut -d "=" -f 2 | $adtfile





if  grep -i "alpine" /etc/os-release ; then
    alpinelp=1
    while [ "$alpinelp" == 1 ] ; do
        printf "Alpine? lol k, do you want to install some basic stuff? [y/N/? for list]"
        read -r alpinechoice
            case "$alpinechoice" in 
            Y|y) apk update && apk upgrade && apk add bash vim curl man man-pages mdocml-apropos bash-doc bash-completion util-linux pciutils usbutils coreutils binutils findutils 
            alpinelp=0;;
            N|n) alpinelp=0;; 
            w) printf "bash vim curl man man-pages mdocml-apropos bash-doc bash-completion util-linux pciutils usbutils coreutils binutils findutils";;
            *) printf "invalid choice" 
        esac
    done
fi

printf "\n***IP ADDRESSES***\n"
if  hash ip addr 2>/dev/null  ; then
ip addr | awk '
/^[0-9]+:/ {
  sub(/:/,"",$2); iface=$2 }
/^[[:space:]]*inet / {
  split($2, a, "/")
  print iface" : "a[1]
}' | $adtfile
fi

## /etc/group
printf "[  \033[01;35mUser\033[0m, \033[01;36mGroup\033[0m  ]\n" && grep "sudo\|adm\|bin\|sys\|uucp\|wheel\|nopasswdlogin\|root" /etc/group | awk -F: '{printf "\033[01;35m" $4 "\033[0m : \033[01;36m" $1 "\033[0m\n"}' | column |$adtfile
printf "To delete users/groups, use \033[01;30msudo userdel -r \$user\033[0m and \033[01;30msudo groupdel \$user\033[0m\n"

## /etc/sudoers
if [ -f /etc/sudoers ] ; then
    printf "\033[01;30m$(date)\033[0m: %s\n" "Sudoers"
    sudo awk '!/#(.*)|^$/' /etc/sudoers | $adtfile
fi 

## Less Fancy /etc/shadow
printf "\033[01;30m$(date)\033[0m: %s\n" "Passwordless accounts: "
awk -F: '($2 == "") {print}' /etc/shadow # Prints accounts without passwords
echo;

#printf "\n***USERS IN SUDO GROUP***\n"
#grep -Po '^sudo.+:\K.*$' /etc/group | $adtfile
#
#printf "\n***USERS IN ADMIN GROUP***\n"
#grep -Po '^admin.+:\K.*$' /etc/group | $adtfile
#
#printf "\n***USERS IN WHEEL GROUP***\n"
#grep -Po '^wheel.+:\K.*$' /etc/group | $adtfile
#
if hash netstat 2>/dev/null ; then 
    if [ $(netstat -punta  2>/dev/null) ] ; then 
        netstat -punta | $adtfile 
    else 
        printf "\n netstat -punta failed ily\n"
    fi
fi


printf '**services you should cry about***\n'
ps aux | grep 'Docker\|samba\|postfix\|dovecot\|smtp\|psql\|ssh\|clamav\|mysql' | grep -v "grep"


### NOTE WORKING O NTHIS FOR NOW, IDK IF THERE IS ALWAYS A .BASH_PROFILE IN ~
#echo 'NOTE THIS MIGHT NOT WORK'
# # shellcheck disable=SC2016
#printf '*** Making Bash profile log time/date using at $HOME/.bash_profile ***'
# # shellcheck disable=SC2183
#if printf 'export HISTTIMEFORMAT="%d/%m/%y %T"' >> ~/.bash_profile >/dev/null 2>/dev/null ; then 
#    # shellcheck source=/dev/null
#      source ~/.bash_profile
#    
#else 
#    echo something went wrong with making bash profile track time! 
#fi

printf 'wgetting git harden.sh please run eventually, if this fails go into inventory.sh and get the file'
if hash wget 2>/dev/null ; then
    wget https://git.io/Jvq37
else
    echo wget failed, file is https://git.io/Jvq37
fi


#curl -
#pull the external audit.sh script
