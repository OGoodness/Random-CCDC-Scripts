$Agent = Read-Host -Prompt 'Agent Name'
$Date = (Get-Date).ToString('MM.dd.yyyy')

$Title = 'System Inventory Report' 
 
$AgentHeading = "Created by: PaceCCDCTeam"

$DateHeading = "Date Created: $Date"

$Srvc = Get-Service | Sort-Object -Property Status, DisplayName | Format-Table @{L='Display Name';E={$_.DisplayName}}, Status #| Out-File -FilePath E:\Process-ServicesInventory-$Date.txt -Append
$Prcs = tasklist -V 
$hstnme = (Get-WmiObject Win32_OperatingSystem).CSName
$hstos = (Get-WmiObject Win32_OperatingSystem).Caption 
$hstarc = (Get-WmiObject Win32_OperatingSystem).OSArchitecture
$hstosversion = (Get-WmiObject Win32_OperatingSystem).Version
$instSoft = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Sort-Object Publisher, DisplayName, DisplayVersion, InstallDate | Format-Table –AutoSize 
$localusr = Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount='True'" | Select PSComputername, Name, Status, Disabled, AccountType, Lockout, PasswordRequired, PasswordChangeable, SID | Format-Table –AutoSize 


Write-Output "---------------------------------------------------" -ForegroundColor Yellow
Write-Output "                      $Title                       " -ForegroundColor Yellow
Write-Output "---------------------------------------------------" -ForegroundColor Yellow
Write-Output " "
Write-Output $AgentHeading -ForegroundColor Magenta
Write-Output $DateHeading  -ForegroundColor Magenta
Write-Output " "
Write-Output "---------------------------------------------------" -ForegroundColor Yellow
Write-Output "          Operating System Information             " -ForegroundColor Yellow
Write-Output "---------------------------------------------------" -ForegroundColor Yellow
Write-Output " "

Write-Output "Operating System: $hstos $hstarc" -ForegroundColor Magenta
Write-Output "Version Number: $hstosversion" -ForegroundColor Magenta
Write-Output "Computer Name: $hstnme" -ForegroundColor Magenta
Write-Output " "


Write-Output "                Installed Services                 " -ForegroundColor Green 
Write-Output "---------------------------------------------------" -ForegroundColor Green
Write-Output " "
Write-Output $Srvc  -ForegroundColor Magenta
Write-Output " "
Write-Output "                Running Processes                  " -ForegroundColor Green
Write-Output "---------------------------------------------------" -ForegroundColor Green
Write-Output " "
Write-Output $Prcs -ForegroundColor Magenta
Write-Output " "
Write-Output "                Installed Software                  " -ForegroundColor Green 
Write-Output "---------------------------------------------------" -ForegroundColor Green
Write-Output " "
Write-Output $instSoft -ForegroundColor Magenta
Write-Output " "

Write-Output "---------------------------------------------------" -ForegroundColor Yellow
Write-Output "                 User Information                  " -ForegroundColor Yellow
Write-Output "---------------------------------------------------" -ForegroundColor Yellow
Write-Output " "

Write-Output "                Local User Accounts                " -ForegroundColor Green
Write-Output "---------------------------------------------------" -ForegroundColor Green
Write-Output " "

Write-Output $localusr -ForegroundColor Magenta


Write-Output "              User Accounts by Group               " -ForegroundColor Green
Write-Output "---------------------------------------------------" -ForegroundColor Green
Write-Output " "

function Get-Accounts { 
$localadmgrp = net localgroup administrators | 
 where {$_ -AND $_ -notmatch "command completed successfully"} | 
 select -skip 4
New-Object PSObject -Property @{
 Computername = $env:COMPUTERNAME
 Group = "Administrators"
 Members=$localadmgrp
 }

$localusrgrp = net localgroup users | 
 where {$_ -AND $_ -notmatch "command completed successfully"} | 
 select -skip 4
New-Object PSObject -Property @{
 Computername = $env:COMPUTERNAME
 Group = "Users"
 Members = $localusrgrp
 }

 $localrmtdskgrp = net localgroup "Remote Desktop Users"| 
 where {$_ -AND $_ -notmatch "command completed successfully"} | 
 select -skip 4
New-Object PSObject -Property @{
 Computername = $env:COMPUTERNAME
 Group = "Remote Desktop Users"
 Members = $localrmtdskgrp
 }

 $localrmtmntgrp = net localgroup "Remote Management Users"| 
 where {$_ -AND $_ -notmatch "command completed successfully"} | 
 select -skip 4
New-Object PSObject -Property @{
 Computername = $env:COMPUTERNAME
 Group = "Remote Management Users"
 Members = $localrmtmntgrp
 }

 $localsmagrp = net localgroup "System Managed Accounts Group"| 
 where {$_ -AND $_ -notmatch "command completed successfully"} | 
 select -skip 4
New-Object PSObject -Property @{
 Computername = $env:COMPUTERNAME
 Group = "System Managed Accounts Group"
 Members = $localsmagrp
 }

 $localpowusrgrp = net localgroup "Power Users"| 
 where {$_ -AND $_ -notmatch "command completed successfully"} | 
 select -skip 4
New-Object PSObject -Property @{
 Computername = $env:COMPUTERNAME
 Group = "Power Users"
 Members = $localpowusrgrp
 }

  $localgstgrp = net localgroup "Guests"| 
 where {$_ -AND $_ -notmatch "command completed successfully"} | 
 select -skip 4
New-Object PSObject -Property @{
 Computername = $env:COMPUTERNAME
 Group = "Guests"
 Members = $localgstgrp
 }

 }

Get-Accounts 

Write-Output " "
Write-Output "                 Logged on Users                   " -ForegroundColor Green 
Write-Output "---------------------------------------------------" -ForegroundColor Green
Write-Output " "

query USER

Write-Output "---------------------------------------------------" -ForegroundColor Yellow
Write-Output "              Networking Information               " -ForegroundColor Yellow
Write-Output "---------------------------------------------------" -ForegroundColor Yellow
Write-Output " "

Write-Output " "
Write-Output "              IPAddress Information                " -ForegroundColor Green
Write-Output "---------------------------------------------------" -ForegroundColor Green
Write-Output " "

Get-NetIPAddress | Sort-Object -Property AddressFamily,AddressState |Format-Table -Property IPAddress,AddressFamily,InterfaceAlias,AddressState,InterfaceIndex -AutoSize 


Write-Output " "
Write-Output "              MACAddress Information                " -ForegroundColor Green
Write-Output "---------------------------------------------------" -ForegroundColor Green
Write-Output " "

Get-WmiObject win32_networkadapterconfiguration | Format-List -Property Caption,IPAddress,MACAddress

Write-Output " "
Write-Output "                  Routing Table                    " -ForegroundColor Green
Write-Output "---------------------------------------------------" -ForegroundColor Green
Write-Output " "

Get-NetRoute |Sort-Object -Descending -Property AddressFamily,NextHop,InterfaceAlias | Format-Table -Property AddressFamily,State,ifIndex,InterfaceAlias,NextHop

Write-Output " "
Write-Output "                   Open Ports                      " -ForegroundColor Green
Write-Output "---------------------------------------------------" -ForegroundColor Green
Write-Output " "

Get-NetTCPConnection | Sort-Object -Property State,RemoteAddress

Write-Output " "
Write-Output "                  Firewall Rules                   " -ForegroundColor Green
Write-Output "---------------------------------------------------" -ForegroundColor Green
Write-Output " "

Get-NetFirewallRule -PolicyStore ActiveStore | Format-Table -Property DisplayName,Enabled,Direction,Owner,PolicyStoreSource

cat C:\Windows\System32\drivers\etc\hosts
