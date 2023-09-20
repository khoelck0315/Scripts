function ConvertTo-XBytes {
    [CmdletBinding()]
    Param([Parameter(Mandatory=$true)] [String]$bytes);
    if ($bytes.length -lt 7) { $divisor = 1000; $unit =' KB'; }
    elseif (($bytes.length -gt 6) -and ($bytes.length -lt 10)) { $divisor = 1000000; $unit = ' MB'; }
    elseif ($bytes.length -gt 9) { $divisor = '1000000000'; $unit = ' GB'; }
    else { return $bytes+" Bytes"; }
    return [math]::round([Int64]$bytes / $divisor, 2).toString()+[String]$unit;
}

#General script config
$fileserver = "";
$p = ConvertTo-SecureString -String '' -AsPlainText -Force;
$cred = New-Object -TypeName System.Management.Automation.PSCredential -Argumentlist "", $p;
$drives = @("e:", "j:", "t:");
#Uncomment drives below to run quick test after changes
#$drives = @("");
$properties = @('FullName', 'Length', 'CreationTime', 'LastWriteTime');
$bp = 0;


#Open workbook here, initialize worksheets
$excel = New-Object -ComObject excel.application;
$excel.visible = $False;
$file_report = $excel.Workbooks.Add();
$e_drive = $file_report.Worksheets.Add();
$e_drive.Name = "E Drive";
$j_drive = $file_report.Worksheets.Add();
$j_drive.Name = "J Drive";
$t_drive = $file_report.Worksheets.Add();
$t_drive.Name = "T Drive";
$workbooks = @($e_drive, $j_drive, $t_drive);

#Add the headers to the worksheets 
$headers = @($null, "Full Path", "Size", "Created", "Last Modified");
foreach($workbook in $workbooks) {
    for($i=1;$i -lt $headers.length;$i++) {
        $workbook.Cells(1,$i) = $headers[$i];
        $workbook.Cells(1,$i).Font.Bold = $true;
    }
}

#Loop through the drives and scan them
foreach($drive in $drives) {
    $thisbook = $workbooks[$bp++];
    $row = 2;
    Write-Host "Collecting data for $drive"
    #Open pssession
    $session = New-PSSession -ComputerName $fileserver -Credential $cred
    $data = Invoke-Command -Session $session -InputObject $drive -ScriptBlock {
        Get-ChildItem -Depth 20 -Path $Input -Recurse -File -Verbose| Select-Object -Property FullName,LastWriteTime,CreationTime,Length | Sort-Object -Property length -Descending | Select-Object -First 500
    }
    Remove-PSSession $session;
    #Loop through each file found
    Write-Host "Adding file data to worksheet"
    foreach ($file in $data) {
        $col = 1;
        #Loop through each property that the file contains and add its value to the excel sheet
        foreach ($property in $properties) {
            if ($property -eq 'Length') {
                $thisbook.Cells.Item($row, $col++) = ConvertTo-XBytes -bytes $file.$property;
            }
            else {
                $thisbook.Cells.Item($row, $col++) = $file.$property;
            }
        }
        $row++;
    }
}

#
$excel.DisplayAlerts = 'False';
$path= $env:userprofile+"\desktop\filereport.xlsx";
$file_report.SaveAs($path); 
#$file_report.Close;
$excel.DisplayAlerts = 'False';
$excel.Quit();
