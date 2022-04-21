

# VariableS 
$ErrorActionPreference = ‘SilentlyContinue’
$ui = 1
$CSVPATH = "\\s.ad.redbridge.gov.uk\L$\"
$csvfile = "$CSVPATH$(get-date -Format "MMddyyyy")INTUNE.csv"

#Connect VPN

IF (Get-VpnConnection -Name "REDBRIDGE AO-VPN" -AllUserConnection| Where-Object -Property Connectionstatus -EQ Connected)
{Write-Output "True"}
Else
{

Write-Output "False"
rasdial "REDBRIDGE AO-VPN"


}

Sleep 10

# VPN DNS FIX
Set-NetIPInterface -InterfaceAlias "REDBRIDGE AO-VPN" -InterfaceMetric 5


#create templog folder

$path = "c:\templogs\"
If(!(test-path $path))
{
    New-Item -ItemType Directory -Force -Path $path
}

# Uptime
$LastBootUpTime = Get-WmiObject win32_operatingsystem
$Uptime = ((Get-Date) - ($LastBootUpTime.ConvertToDateTime($LastBootUpTime.LastBootUpTime))).Days
if($Uptime -ge 5) {$Over5Days = "1"}
Else {$Over5Days = "0"}

#Set UPTIME counter

New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name 'Over5Days' -Value $Over5Days -PropertyType DWord -Force -ea SilentlyContinue

#Get Adapter, IP address and OS build
$ifindex = Get-NetAdapter -IncludeHidden -Physical | where status -eq up | Select-Object -ExpandProperty ifindex
$v1 = Get-NetIPInterface -AddressFamily IPv4 -InterfaceAlias "REDBRIDGE AO-VPN" | Select-Object interfacemetric -ExpandProperty interfacemetric
$v2 = Get-VpnConnection -AllUserConnection -name "REDBRIDGE AO-VPN" | Select-Object connectionstatus -ExpandProperty connectionstatus
$v4 = Get-DAConnectionStatus | Select-Object -ExpandProperty Status -ErrorAction SilentlyContinue
$v5 = Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $ifindex -ErrorAction SilentlyContinue | Select-Object -ExpandProperty IPAddress
$v6 = Get-ComputerInfo | Select-Object -ExpandProperty WindowsVersion


#Test internal sites
$v3 = Test-NetConnection -ComputerName eforms.redbridge.gov.uk -Port 443
$v33 = Test-NetConnection -ComputerName pay.redbridge.gov.uk -Port 443
$v8 = Test-NetConnection -ComputerName my.redbridge.gov.uk -Port 443
$v9 = Test-NetConnection -ComputerName ad.redbridge.gov.uk
$dns = Resolve-DnsName -Name adfs.redbridge.gov.uk | Select-Object -ExpandProperty IPAddress
$v99 = $v3.SourceAddress | select IPaddress -ExpandProperty IPaddress
$10 = Test-NetConnection -ComputerName www.redbridge.gov.uk -TraceRoute -hop 2
$11 = $10.TraceRoute


#FUNCION IP CHECK
$INTADFSCHECK = $dns -match "10.216.16.113"
$INTeformsCHECK =  $v3.RemoteAddress -match "10.1.5.83"


#cAPTURED INFO
$AOVPNMETRIC = [pscustomobject]@{

'Name' = $env:computername; 
'AOVPN-Status' = $v2; 
'DA-Status' = $v4;
'Uptime' = $Uptime; 
'IPAddress' = $v99; 
'ADFS-INT-DNS' = $INTADFSCHECK -join ','; 
'INT-DNS' = $INTeformsCHECK; 
'eform_IP' = $v3.RemoteAddress; 
'adfs_IP' =$dns -join ','; 
'WindowsVersion' = $v6; 
'eforms_TcpTestSucceeded' = $v3.TcpTestSucceeded;
'pay_TcpTestSucceeded' = $v33.TcpTestSucceeded;
'eforms_PingSucceeded' = $V3.PingSucceeded; 
'my.red_TCPTestSucceeded' = $v8.TcpTestSucceeded; 
'Test_Domain_Controller' = $v9.PingSucceeded;
'AoVPN Metric' = $v1;
'www_Trace Route' = $11 -join ','
}

# EXPORT TO CSV
$AOVPNMETRIC |Export-Csv -Path "$csvfile" -Append
