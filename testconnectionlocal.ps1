$results = "$env:data\connectiontest.csv"


function Green
{
    process { Write-Host $_ -ForegroundColor Green }
}

function Red
{
    process { Write-Host $_ -ForegroundColor Red }
}

$LBRLT = Get-Content "C:\Users\admdannyk\OneDrive - London Borough Of Redbridge\Desktop\Scripts\Hosts.txt"

Foreach ($LT in $LBRLT)
{
  if (Test-Connection -ComputerName $LT -Count 1 -Quiet)
{
Write-Output "$LT Online" |green

#P*********

$d1 = $LT
$d2 = (Test-Connection -ComputerName $LT -Count 1).IPV4Address

 $Table = [pscustomobject]@{
    'Device' = $d1; 
    'IPV4Address' = $d2; 
    'Status' = "Online";

}

# write record

$Table|Export-Csv -Path "$results" -Append
     
    
} 
    
else 
    
{
 
 
 Write-Output "$LT offline" | red

$d1 = $LT

 $Table = [pscustomobject]@{
    'Device' = $d1; 
    'IPV4Address' = 'na';
    'Status' = 'Offline';
}

 
$Table|Export-Csv -Path "$results" -Append

}
}

