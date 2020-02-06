<#

Get Inventory Script

General-Purpose PowerShell Script to get quick access to basic inventory information on the current system.

Lists the following information:

-OS Type
-Client or Server Machine (Guesses on OS Type and installed programs)
-IP Address
-Current Domain Controller
-Installed Windows Features
-Additional Installed Network Services (Beta)


#>

#Get systeminfo block
$computerInfo = systeminfo
$isServer = $false

#Extract Host Name
$hostName = $computerInfo | Where-Object {$_ -match 'Host Name:'}
$hostName = $hostName.TrimStart('Host Name:');

#Extract OS Name
$osName = $computerInfo | Where-Object {$_ -match 'OS Name:'}
$osName = $osName.TrimStart('OS Name:');

#Extract Domain Controller
$dc = $computerInfo | Where-Object {$_ -match 'Logon Server:'}
$dc = $dc.TrimStart('Logon Server:');
$dc = $dc.TrimStart('\\');

#Extract Domain Controller IP Address
$domainController = systeminfo
$ipv4 = (Test-Connection -ComputerName $env:ComputerName -Count 1).IPV4Address.IPAddressToString

$hostName = $computerInfo | Where-Object {$_ -match 'Host Name:'}
$hostName = $hostName.TrimStart('Host Name:');

$featureList = ""

#If the OS is a server installation, attempt to grab installed features
if ($osName.Contains("Server") -and ($osName.Contains("2012") -or $osName.Contains("2016") -or $osName.Contains("2019")))
{
    $isServer = $true
    $featureList = Get-WindowsFeature | Where-Object -Property InstallState -eq -Value "Installed"
}


#Display information retrieved
Write-Host ""
Write-Host "System Information:"
Write-Host ""

Write-Host "Host Name:          " -NoNewline
Write-Host $hostName

Write-Host "OS Type:            " -NoNewline
Write-Host $osName

Write-Host "OS Config:          " -NoNewline
Write-Host $osConfig

Write-Host "IP Address:         " -NoNewline
Write-Host $ipv4

Write-Host "Domain Controller:  " -NoNewline
Write-Host $dc

#Display Server Information if computer is a server
if ($isServer) 
{
    Write-Host "";
    Write-Host "Installed Windows Features (Native Windows Network Services):";
    Write-Host "";
    $featureList | Where-Object {$_.Name -eq "AD-Domain-Services" -or $_.Name -eq "ADLDS" -or $_.Name -eq "DNS"} | select DisplayName -ExpandProperty DisplayName
}