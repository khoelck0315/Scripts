<#
This script extracted data from mysql and updated AD attributes based off of the results.  It was part of a data conversion process.

If the machine running the script does not have MySQL workbench installed, the driver to connect to MySQL first needs to be installed:
    Connector/Net- http://dev.mysql.com/downloads/connector/net/

Also, the PSmodule will be need to be downloaded and preferably be placed in a folder to load automatically
    (C:\Program Files (x86)\WindowsPowerShell\Modules folder.)

Download and install with the following commands below:
    Invoke-WebRequest  -Uri https://github.com/adbertram/MySQL/archive/master.zip -OutFile  'C:\util\MySQL.zip'
    $modulesFolder = 'C:\Program Files\WindowsPowerShell\Modules'
    Expand-Archive -Path  C:\util\MySql.zip -DestinationPath $modulesFolder
    Rename-Item -Path "$modulesFolder\MySql-master" -NewName MySQL
#>

# Make sure MySQL module is loaded into the shell
$mysqlModDir = "C:\Program Files\WindowsPowerShell\Modules\MySQL\"
Import-Module -Name "$mysqlModDir\mysql.psm1";
Import-Module -Name "$mysqlModDir\mysql.psd1";

# Make sure Settings -> Apps -> Optional Features -> Add a feature ->
# RSAT: Active Directory Domain Services and Lightweight Directory Services Tools has been installed!
Import-Module -Name activedirectory

# Create the login credential
$userName = "";
$password = "";
$secStringPassword = ConvertTo-SecureString $password -AsPlainText -Force
$mysqlCred = New-Object -TypeName System.Management.Automation.PSCredential ($userName, $secStringPassword);

# Connect to MySQL Database
$conn = Connect-MySqlServer -Credential $mysqlCred -ComputerName <computername> -Database <database>

# Execute the Query
$query = "SELECT * FROM dateinfo";


# Define AD attributes that will be updated
$attr1 = "";
$attr2 = "";

#For each user in MySQL, find the AD object and update it
foreach($result in $results) {
    $user = Get-Aduser $result."User Logon Name" -Properties *
    $attr1val = <logic to get value>
    $attr2val = <logic to get value>

    #Set Birthday
    if($user.propertyNames.contains($attr1)) {
        Set-Aduser -Identity $user.SamAccountName -Replace @{$attr1=$attr1val}
    }
    else {
        Set-Aduser -Identity $user.SamAccountName -Add @{$attr1=$attr1val}
    }

    #Set Anniversary
    if($user.propertyNames.contains($attr2)) {
        Set-Aduser -Identity $user.SamAccountName -Replace @{$attr2=$attr2val}
    }
    else {
        Set-Aduser -Identity $user.SamAccountName -Add @{$attr2=$attr2val}
    }
    
}

# Identify users that may have been missing from the MySQL database, output that list to a separate file
$masterList = Get-Aduser -Filter * -SearchBase <DN string> -Properties *
New-Item -Path "C:\util" -Name "missingaccounts.txt" -ItemType "file"

foreach($user in $masterList) {
    if((!$user.propertyNames.contains($attr1)) -or (!$user.propertyNames.contains($attr2))) {
        Write-Host -NoNewLine ".";
        Add-Content -Path "C:\util\missingaccounts.txt" -Value $user.DisplayName
    }
}

Write-Host Done

Disconnect-MySqlServer