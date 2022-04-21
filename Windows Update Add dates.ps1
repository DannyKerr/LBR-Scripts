 $a1 = Import-Csv -Path 'C:\Users\admdannyk\OneDrive - London Borough Of Redbridge\Desktop\Scripts\Data\Intune_End_User_Update_Status_2022-04-19T06_37_51.396Z.csv'
 #y$a1G = $A1 | Group-Object -Property "Quality Update Version" |Where-Object {$_.'user' -cnotcontains 'System account' } | Sort-Object -Property name -Descending 
 $ref1 = Import-Csv -Path 'C:\Users\admdannyk\OneDrive - London Borough Of Redbridge\Desktop\Scripts\Data\Reflist.csv'
 $results = "$env:data\results19-04.csv"
 $date = (get-date -Format mm/dd/yyyy)

  foreach ($c in $a1) {

  $refd = $c."Quality Update Version" -replace '10.0.',''
$dateconverted = [datetime]::parseexact($date, 'mm/dd/yyyy', $null)
$ref = ($ref1 | Where-Object Build -Match $refd).date
$refdateconverted = [datetime]::parseexact($ref, 'mm/dd/yyyy', $null)


 #cAPTURED INFO
$Table = [pscustomobject]@{

'Device' = $c.Device; 
'User' = $c.User; 
'Quality Update Version' = $c."Quality Update Version"; 
'Feature Update Version' = $c.'Feature Update Version'; 
'Last Scan Time' = $c.'Last Scan Time'; 
'Last Check-in Time' =  $c.'Last Check-in Time'
'Build Date' = ($ref1 | Where-Object Build -Match $refd).date
'Days Out of Date' = ($refdateconverted -$dateconverted).days;

}

# write record

$Table|Export-Csv -Path "$results" -Append

}
import-csv -path $results | format-table
