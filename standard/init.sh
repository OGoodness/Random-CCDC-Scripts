APT:
	setenforce 0
	history >> /root/init_history
	mkdir /root/log_back /root/web_back /root/sql_back /home/quar
  	cp -r /var/www/html /root/web_back
  	cp -r /var/log /root/log_back
  	mysqldump -u root -p --all-databases > /root/sql_back.sql
  	cp /etc/passwd /root/passwd_init
	cp /etc/sudoers /root/sudoers_init
	cp /etc/group /root/group_init
	chattr +i /root/passwd_init /root/sudoers_init /root/group_init -r
	mkdir /root/quar/cron_back
	mv /etc/cron* /root/quar/cron/ -r

  
	



YUM:
	setenforce 0
	history >> /root/init_history
	mkdir /root/log_back /root/web_back /root/sql_back /home/quar
  	cp -r /var/www/html /root/web_back
  	cp -r /var/log /root/log_back
  	mysqldump -u root -p --all-databases > /root/sql_back.sql
  	cp /etc/passwd /root/passwd_init
	cp /etc/sudoers /root/sudoers_init
	cp /etc/group /root/group_init
	chattr +i /root/passwd_init /root/sudoers_init /root/group_init -r
	mkdir /root/quar/cron_back
	mv /etc/cron* /root/quar/cron/ -r
