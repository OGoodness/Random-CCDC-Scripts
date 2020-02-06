<#
Script by Angeline Pho

Get-Installed-Programs
Returns A list of installed software including name, version, and install date

Edited by Shawn Hill
#>

#Create an empty list to store the results
$programList = @()

#Get all programs using entries and store them in a variable
$loc = Get-ChildItem HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall
#Extract the paths from each entry
$names = $loc | foreach-object {Get-ItemProperty $_.PsPath}
foreach ($name in $names)
{
    #if the entry isn't blank, format the entry as a new powershell object, with name, version, and date installed as members, and add it to the program list
    If(-Not [string]::IsNullOrEmpty($name.DisplayName)) {      
        $line = Select-Object @{n='Program Name';e={$name.DisplayName}},@{n='Version';e={$name.DisplayVersion}},@{n='Date Installed';e={$name.InstallDate.Substring(4,2) + "/" + $name.InstallDate.Substring(6,2) + "/" + $name.InstallDate.Substring(0,4)}} -InputObject ''
        $programList += $line   
    }
}


#Same thing as above, but need to fetch both 32 and 64 bit installations since they have separate directories
$loc = Get-ChildItem HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall
$names = $loc | foreach-object {Get-ItemProperty $_.PsPath}
foreach ($name in $names)
{
    If(-Not [string]::IsNullOrEmpty($name.DisplayName)) {      
        $line = Select-Object @{n='Program Name';e={$name.DisplayName}},@{n='Version';e={$name.DisplayVersion}},@{n='Date Installed';e={$name.InstallDate.Substring(4,2) + "/" + $name.InstallDate.Substring(6,2) + "/" + $name.InstallDate.Substring(0,4)}} -InputObject ''
        $programList += $line
    }
}

#Show the list of programs with version and date installed in alphabetical order
$programList | Sort-Object | Format-Table -AutoSize

Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');