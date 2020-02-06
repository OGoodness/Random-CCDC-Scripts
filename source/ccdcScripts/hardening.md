#audit
lynis

#firewall
firewalld
iptables

#ip banning 
fail2ban

#ids
OSSEC
snort

#kernel hardening
turn on SELinux
`setenforce enforcing`

#cron
this will make no one able to make cron jobs
`echo ALL >>/etc/cron.deny`

#lock unused accounts
`passwd -l accountName` <- lock
`passwd -u accountName` <- unlock

#turn off ctrl+alt+delete 
Trap CTRL-ALT-DELETE
`ca::ctrlaltdel:/sbin/shutdown -t3 -r now`

#monitor users
psacct
