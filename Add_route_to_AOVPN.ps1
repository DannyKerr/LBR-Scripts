#Enter Address to add to AOVPN
$NetworkIDAddress = Read-Host "Please Enter Network IP Address"
$NetworkIDSubnet = Read-Host "Please Enter Subnet Prefix /8-32"

$Newroute = "$NetworkIDAddress/$NetworkIDSubnet"

$s1 = New-PSSession -ComputerName LBRDWRASAOV11
$s2 = New-PSSession -ComputerName LBRDWRASAOV12


#Confirm Route is on Server

$Data1 = Invoke-Command -Session $s1 {Get-NetRoute -NextHop 10.130.31.254}
$Data2 = Invoke-Command -Session $s2 {Get-NetRoute -NextHop 10.130.31.254}

$Confirmroutes1 = $data1 | Where-Object -Property DestinationPrefix -eq $Newroute
$Confirmroutes2 = $data2 | Where-Object -Property DestinationPrefix -eq $Newroute

IF ($null -eq $Confirmroutes1) 
{
Write-host "$Newroute not present on LBRDWRASAOV11" -ForegroundColor Red

$question1 = Read-Host "Do you want to add NETWORK $Newroute to LBRDWRASAOV11? Y/N?"
if ($question1 -eq 'y') {

Invoke-Command -Session $s1 {new-NetRoute -InterfaceAlias "Internal 10.130.16" -DestinationPrefix $using:Newroute -NextHop 10.130.31.254 -RouteMetric 1}
Write-Host "$Newroute added to server LBRDWRASAOV11" -ForegroundColor Green
}
else
{
Write-Host "Answer provided is no" -ForegroundColor Red
}

}

IF ($null -eq $Confirmroutes2) 
{
Write-host "$Newroute not present on LBRDWRASAOV12" -Foreground red

$question2 = Read-Host "Do you want to add NETWORK $Newroute to LBRDWRASAOV12? Y/N?"
if ($question2 -eq 'y') {

Invoke-Command -Session $s2 {new-NetRoute -InterfaceAlias "Internal10.130.16" -DestinationPrefix $using:Newroute -NextHop 10.130.31.254 -RouteMetric 1}
Write-Host "$Newroute added to server LBRDWRASAOV12" -ForegroundColor Green
}
else
{
Write-Host "Answer provided is no" -ForegroundColor Red
}

}


IF (($Confirmroutes1.DestinationPrefix -eq $Newroute)-and ($Confirmroutes2.DestinationPrefix -eq $Newroute)) {
Write-host "$Newroute is already present on Both AoVPN Servers" -ForegroundColor Green

}

$question3 = Read-Host "Do you want to confirm the $Newroute on Servers?"
If ($question3 -eq "Y") 
{ 
$upData1 = Invoke-Command -Session $s1 {Get-NetRoute -NextHop 10.130.31.254} |Where-Object -Property "DestinationPrefix" -EQ $Newroute 
$upData2 = Invoke-Command -Session $s2 {Get-NetRoute -NextHop 10.130.31.254} |Where-Object -Property "DestinationPrefix" -EQ $Newroute 

IF ($upData1 -eq $Newroute) 
{Write-host "LBRDWRASAOV11 Confirmed" -ForegroundColor Green}
Else
{Write-host "LBRDWRASAOV11 Confirmed" -ForegroundColor Green}


IF ($upData2 -eq $Newroute) 
{Write-host "LBRDWRASAOV12 Confirmed" -ForegroundColor Green}
Else
{Write-host "LBRDWRASAOV12 Confirmed" -ForegroundColor Green}

}

Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');