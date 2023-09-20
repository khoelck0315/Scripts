﻿# Import the Active Directory module for the Get-ADComputer CmdLet 
Import-Module ActiveDirectory 
 
# Get today's date for the report 
$today = Get-Date 
 
# Setup email parameters 
$subject = "ACTIVE SERVER SESSIONS REPORT - " + $today 
$priority = "Normal" 
$smtpServer = "" 
$emailFrom = "" 
$emailTo = "" 
 
# Create a fresh variable to collect the results. You can use this to output as desired 
$SessionList = "ACTIVE SERVER SESSIONS REPORT - " + $today + "`n`n"
$DisconnectList = "Inactive Server Sessions Report - " + $today + "'n'n"
 
# Query Active Directory for computers running a Server operating system 
$Servers = Get-ADComputer -Filter {OperatingSystem -like "*server*"} 
 
# Loop through the list to query each server for login sessions 
ForEach ($Server in $Servers) { 
    $ServerName = $Server.Name 
 
    # When running interactively, uncomment the Write-Host line below to show which server is being queried 
    # Write-Host "Querying $ServerName" 
 
    # Run the qwinsta.exe and parse the output 
    $queryResults = (qwinsta /server:$ServerName | foreach { (($_.trim() -replace "\s+",","))} | ConvertFrom-Csv)  
     
    # Pull the session information from each instance 
    ForEach ($queryResult in $queryResults) {  
        $sessionType = $queryResult.SESSIONNAME
        $sessionState = $queryResult.ID
        
         
        # We only want to display where a "person" is logged in. Otherwise unused sessions show up as USERNAME as a number
        # To search for a specific person, change "[a-z]" to the user's name 
        If ($sessionType -ne "services" -Or $sessionType -ne "console" -Or ($sessionType -ne "rdp-tcp")) {
            # When running interactively, uncomment the Write-Host line below to show the output to screen 
            Write-Host $ServerName $sessionType is $sessionState
            $SessionList = $SessionList + "`n`n" + $ServerName + " logged in by " + $RDPUser + " on " + $sessionType
            $DisconnectList =  $ServerName + $SessionType + " is " + $sessionState
		}
	}
}
            
       
 
# Send the report email 
Send-MailMessage -To $emailTo -Subject $subject -Body $SessionList -SmtpServer $smtpServer -From $emailFrom -Priority $priority 
 
# When running interactively, uncomment the Write-Host line below to see the full list on screen 
$SessionList 