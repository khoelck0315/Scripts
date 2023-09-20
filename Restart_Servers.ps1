#Reboot script for servers

$cred = Get-Credential

$servers = @(<list servers by hostname>)

foreach ($server in $servers) {
    Restart-Computer -Force -ComputerName $server -Credential $cred;
}