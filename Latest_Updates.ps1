# Generate a list of recently updated servers

# Import the Active Directory module for the Get-ADComputer CmdLet 
Import-Module ActiveDirectory 

# Query Active Directory for computers running a Server operating system 
$Servers = Get-ADComputer -Filter { OperatingSystem -like "*server*" } 
#$queryResults = [System.Collections.ArrayList]@();

#Build the credentials
$username = ""
$password = Read-Host -AsSecureString -Prompt "Enter the password for the credential"
$jobCred = New-Object -TypeName System.Management.Automation.PSCredential ($username, $password)

# Loop through the list to query each server for login sessions 
ForEach ($Server in $Servers) { 
    $ServerName = $Server.Name 
    $result = Get-WmiObject win32_quickfixengineering -Credential $jobCred -ComputerName $ServerName  | sort installedon -desc -erroraction ignore | select -First 1;
    $csvResult = $result.InstalledOn;
    #Write-Host $ServerName - Last Updated: $result.InstalledOn;
    Add-Content -path C:\util\updates.csv -Value "$ServerName, $csvResult"
}

