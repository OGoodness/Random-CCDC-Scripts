#Getting Server Info
echo "---Server Information---" > reconReport.txt
uname -a >> reconReport.txt
echo "" >> reconReport.txt

#Checking in use ports
echo "---Ports In Use---" >> reconReport.txt
netstat -tulpn | grep LISTEN >> reconReport.txt
echo "" >> reconReport.txt

#Getting all users
echo "---All Users---" >> reconReport.txt
less /etc/passwd >> reconReport.txt
echo "" >> reconReport.txt

#Getting user login log
echo "---Login Log---" >> reconReport.txt
last >> reconReport.txt
echo "" >> reconReport.txt

#Getting all programs currently running
echo "---Programs Running---" >> reconReport.txt
ps >> reconReport.txt
echo"" >> reconReport.txt
