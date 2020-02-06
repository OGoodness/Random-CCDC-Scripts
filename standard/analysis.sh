mkdir analysis_output

echo "--------Find Users with 0----------"
awk -F: '($3 == "0") {print}' /etc/passwd >> analysis_output/0_perm_users
echo "--------Check for empty passwords----------"
awk -F: '($2 == "") {print}' /etc/shadow >> analysis_output/empty_pass_users
echo "---------All Running Services---------"
chkconfig --list | grep '3:on' >> analysis_output/running_services
echo "--------Services and their run levels----------"
systemctl list-unit-files --type=service >> analysis_output/services_and_runlevel
echo "---------Network Ports and Info---------"
netstat -tulpn >> analysis_output/network_info
ss -tulpn >> analysis_output/network_info
echo "---------Find all SUID and GUID ---------"
#See all set user id files:
find / -perm +4000 >> analysis_output/all_SUID_files
# See all group id files
find / -perm +2000 >> analysis_output/all_GUID_files
# Or combine both in a single command
# find / \( -perm -4000 -o -perm -2000 \) -print 
# find / -path -prune -o -type f -perm +6000 -ls
echo "--------All world writable files----------"
find /dir -xdev -type d \( -perm -0002 -a ! -perm -1000 \) -print >> analysis_output/all_world_writable_files

echo "---------No Owner Files---------"
find /dir -xdev \( -nouser -o -nogroup \) -print>> analysis_output/all_no_owner_files

echo "------------------"
echo "------------------"
echo "------------------"
echo "------------------"
echo "------------------"
echo "------------------"
