$Java = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "*java*"}
foreach($program in $Java) { 
    msiexec.exe /x $program.IdentifyingNumber /q;
}