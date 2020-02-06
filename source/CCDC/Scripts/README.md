# Inventory Scans

Run the scan with root privileges.

Save all scan's with the following output:

		sudo ./InventoryScan.sh >> "SystemInventory_$(hostname)_$(date "+%F-%H:$M:$S")"

# Setup Scripts

Scripts are for testing purposes and should not be run during the competition.
Any scripts in this repo should be printed out and executed manually.

Setup scripts should be run based on the host's operating system.

***For Testing Only

Make executable with: 
			
			sudo chmod 644 [Script Name]
	
Excute from a terminal with:

			./[Script Name]
	
# Nmap Scans

When scanning a subnet for auditing purposes run the following:

		nmap -A -v -oX "$(date +%T)_nmap_scan.xml" <IP Address/CIDR>

To transform the xml output of the previous command into an html document, run the following:

		xsltproc path/to/nmap.xsl path/to/nmapscan.xml > nmapscan.html


If xsltproc is not installed, run the following:

	Debian:   sudo apt-get install -y xsltproc
	CentOS:  sudo yum install xsltproc    ****May need to change this. Not sure if correct.
