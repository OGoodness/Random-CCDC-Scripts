<#
 .Synopsis
  --- Remove-Vulnerable-Programs ---
  Uninstalls programs deemed to be vulnerable, or those provided as a list.


 .Description
  Invokes the uninstaller for programs that are known to be vulnerable based on an internal list, or if a
  list of programs is provided, will remove those instead.

 .Parameter Program-List
  The list of programs to override the default filter. Entries are filtered based on an array
  format.

 .Example
   # Removes the programs deemed by the default list.
   Remove-Vulnerable-Programs

 .Example
   # Removes the programs from a custom list
   Remove-Vulnerable-Programs -Program_List @("mimikatz", "nyancat", "armadillo")

#>

function Remove-Vulnerable-Programs {
param(
    #Default Filter list
    [string[]]$Program_List = @("VNC", "TeamViewer")
    )

    #For each program in the list, check if it is installed as a 64 or 32 bit application, and grab the UninstallString
    foreach ($program_name in $Program_List) {
        $uninstall32 = gci "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match $program_name } | select UninstallString
        $uninstall64 = gci "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match $program_name } | select UninstallString
        
        #If 64, extract the uninstall string, remove the quotes, and run the uninstaller.
        if ($uninstall64) {
            $uninstall = $uninstall64.UninstallString
            $uninstall = $uninstall.Trim("`"`'")
            Write $uninstall
            Write "Uninstalling..."
            start-process $uninstall -Wait
            }

        #If 32, extract the uninstall string, remove the quotes, and run the uninstaller.
        if ($uninstall32) {
            $uninstall = $uninstall32.UninstallString
            $uninstall = $uninstall.Trim("`"`'")
            Write $uninstall
            Write "Uninstalling..."
            start-process $uninstall -Wait
            }
    }
}