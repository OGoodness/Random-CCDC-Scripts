Import-Module ActiveDirectory

# Set the default password
$password_salt = ConvertTo-SecureString -AsPlainText “replace_this” -Force 
 
# Get the list of accounts from the file on file
# List the user names one per line
$users = Get-Content -Path c:\MyScripts\UserList.txt
 
ForEach ($user in $users) 
{
    $password = Get-ADUser $user
    # Set the default password for the current account
    Get-ADUser $user | Set-ADAccountPassword -NewPassword $password -Reset
    
    #If you need to set the property “Change password at next logon”, 
    #leave the next alone. If not, comment the next line
    Get-ADUser $user | Set-AdUser -ChangePasswordAtLogon $true
    
    Write-Host “Password has been reset for the user: $user”
}