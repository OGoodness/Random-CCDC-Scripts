#param(

# This script is for checking current logs that are set up to be recorded on the local machine
# It can also be used to check logs being recorded from the domain as well
# This script is able to set up the machine to record logs if logs are disabled or not properly
# configured alread.
# By default this script will return common logs that the machine is and is not recording
# It will also configure common logs to be configured.
# It can be supplied with certain logs using Event IDs if you would like to setup more customized logs
# 
# *What windows should this work on? What windows have built in wevtutil? that's mostly what this script runs on
# *I want to add the ability to tell you the significance of not having certain logs setup 

 
# Parameter guide 
# 
# 
# 
# 
# 


#to scan for local logs





#to show a list of common logs
#creates a windows table to view them
#need to implement the ability to supply it with a file
#and it uses that file to display a custom list of logs to show
function Show-commonlogs{

    $commonseclogs = New-Object system.Data.DataTable "Common Logs"

    $commonseclogs.Columns.add( (New-object system.Data.DataColumn "EventID"))
    $commonseclogs.Columns.Add((New-object system.Data.DataColumn "Description (security logs)"))
    
    
    #$commonseclogs.Columns.add( "EventID",tyDataColumn )
    #$commonseclogs.Columns.add("Description
    #$colID = New-Object system.Data.DataColumn "EventID"
    #$colDes = New-Object System.Data.DataColumn "Description
    #$commonseclogs.Columns.Add($colID)
    #$commonseclogs.Columns.Add($colDes)

    $commonseclogs.LoadDataRow( @("4720","User account created"), $true)
    $commonseclogs.LoadDataRow( @("4722","User account enabled"), $true)
    $commonseclogs.LoadDataRow( @("4724","password reset"), $true)
    $commonseclogs.LoadDataRow( @("4732","Account added or removed from a group"), $true)
    $commonseclogs.LoadDataRow( @("4738","User account change"), $true)
    $commonseclogs.LoadDataRow( @("1102","Audit log cleared"), $true)
    Write-Host $commonseclogs

    $commonsyslogs = New-Object System.Data.DataTable "Common System Logs"

    $commonsyslogs.Columns.Add((New-Object System.Data.DataColumn "EventID1"))
    $commonsyslogs.Columns.Add((New-Object System.Data.DataColumn "Description (system logs)"))
    
    $commonsyslogs.LoadDataRow(@("7030", "Basic service operations"), $true)
    $commonsyslogs.LoadDataRow(@("7045", "Service was installed"), $true)
    $commonsyslogs.LoadDataRow(@("1056", "DHCP server oddities"), $true)
    $commonsyslogs.LoadDataRow(@("10000", "COM Functionality (see Subtee's blogs)"), $true)
    $commonsyslogs.LoadDataRow(@("20001", "Device driver installation (many root-kits do this)"), $true)
    $commonsyslogs.LoadDataRow(@("20001", "Remote Access"), $true)
    $commonsyslogs.LoadDataRow(@("20003", "Service installation"), $true)

    #Write-Host $commonsyslogs

    $commonsyslogs | Format-Table "EventID1", "Description (system logs)"

    #Wridsate-Host " Security`n============
    #7045 = New service Installed
    #" -ForegroundColor Red





}

#is used to either supply a default 
function Get-commonlogs{

    
    Write-Host "AA" -ForegroundColor Red


}

#function that queries for a log, can be given a log type and EventID
#If none is given, then the user will be prompted for a log type and EventID
function Query-log{
    param(
    [Parameter()]
    [string]$Type=""
    #[Int32]$EventID=0
    #[String]$computer
    
    )

    while($Type -ne "Security" -and $Type -ne "System" -and $Type -ne "sec" -and $Type -ne "sys"){
        $Type = "Security"
        $Type = Read-Host -Prompt "System or Security logs?[security]"
        if($type -eq ""){$type = "security"}
    }

    if($Type -eq "sys"){$Type="system"}
    if($Type -eq "sec"){$Type="security"}

    $EventID = ""
    while($EventID -eq ""){
    
        $EventID = Read-Host -Prompt "Enter an EventID `n------------------`n>"
    }

    #Get-WinEvent -logname "security

    #$sh = new-object -com 'Shell.Application'

    #$sh.ShellExecute('powershell', "-Noexit -Command 'dir'", 'runas')

    $hash = @{}

    $hash.add("ID",4720)

    #this works
    $temp1 = @{ID=$EventID}
    $temp2 = @{ID=4720}

    #start-process powershell "-NoExit Get-WinEvent -logname $Type -MaxEvents 200 -FilterHashtable @{Logname = $type}" -verb runas
    #start-process powershell "Get-WinEvent -logname $Type -MaxEvents 200 -FilterHashtable @{Logname = $type}" -verb runas
    #start-process powershell "-noexit Get-WinEvent  -FilterHashtable @{Logname = $type}" -verb runas

    $temp = @{LogName =$Type;ID = $EventID}

    #$temp = @{Logname="security";ID=4720}

    $temp

    #start-process powershell.exe "-noexit wevtutil qe security /q:`"*[System[(EventID=4720)]]`" /c:10 /rd:true /f:text" -verb runas
    
    start-process powershell.exe "-noexit Get-EventLog -LogName $Type -InstanceId $EventID -Newest 15" -Verb runas

                        

    Invoke-Command "ls"
    
    Sleep 5


    

    #start-process powershell "-noexit Get-WinEvent -logname $type " -verb runas
    
    #start-process powershell '-noexit Get-WinEvent -FilterHashtable $temp' -verb runas

    #start-process powershell '-noexit Get-WinEvent -FilterHashtable @{LogName =$Type;ID = $EventID} -ComputerName localhost -MaxEvents 15' -verb runas

    #$sh.ShellExecute('powershell', "-Command 'Get-WinEvent -Logname security -Maxevents 5 '", 'runas')

    #Get-WinEvent -FilterHashtable @{LogName = $type;ID = $EventID} -ComputerName localhost -MaxEvents 15 -Credential Get-Credential

    #Start-process powershell.exe 
    
    #Get-WinEvent -LogName "system" 
    #Get-WinEvent -FilterHashTable @{LogName = 'System';ID ='7045'}


}

function autorun{

    Write-Host "Scanning for suspicious event IDs..."

}


#function that prints out available options
function help{
    
    Write-Host "`nOptions`n--------
    Show-CommonLogs : prints out a list of common events that are IOCs
    Query-log       : guided prompt for the user to enter a log to search for
    autorun         : runs automatically to constantly check for IOCs in the Security and system event logs
    Setup-Logs      : Sets up events to be logged if they are not being logged already
    Check-Logs      : Checks to see if common logs (security and system logs) are enabled and configured"
    

}


#Function For checking to see if System and Security logs are enabled
function 

#-FilterHashTable @{LogName = ', type_of_log,';ID =', event_ID, '}


#wevtutil qe security /q:

#function to ask user what they want to do
while($true){

    echo ""
    $command = Read-Host -Prompt "Event log checker>"

    if($command -eq "exit" -or $command -eq "q" -or $command -eq "logout")
    {
        break
    }

    &$command
    

}


##ask
##ask if shawn knows how to do a param where you just put a -l or -a and nothing else, like most linux commands work
#ask shawn if he knows why the 2 different methods of adding a column prints out 2 different tables



#wevtutil qe security /q:

'''
The valid Get-WinEvent key/value pairs are as follows:

    LogName=<String[]>
    ProviderName=<String[]>
    Path=<String[]>
    Keywords=<Long[]>
    ID=<Int32[]>
    Level=<Int32[]>
    StartTime=<DateTime>
    EndTime=<DateTime>
    UserID=<SID>
    Data=<String[]>
    (Asterisk) *=<String[]>

    '''



#Maybe use secure strings to transport stuff?

#New-WinEvent (Creates a new windows log)

#new-eventlog

#set-logproperties
#show-eventlog
#set-AutologgerConfig

#configuring logs should be easier in a .net language


#This didn't work