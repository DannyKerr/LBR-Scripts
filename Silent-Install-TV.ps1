# Vars
$DestFile = "$env:COMPUTERNAME-TV-ID.txt"
$ToolPath = "\\s\l$\TeamViewer"
$DestPath = "\\s\l$\TeamViewerIDs"
$Dest = "$DestPath\$DestFile"
 
# Install Team Viewer
Start-Process -wait $ToolPath\TeamViewer_Host_Setup.exe /S
Start-Sleep -Seconds 2
net stop teamviewer
Start-Sleep -Seconds 2
reg import $ToolPath\tv-settings.reg
Start-Sleep -Seconds 2
net start teamviewer
Start-Sleep -Seconds 2
(Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\TeamViewer' -Name ClientID).ClientID > $dest
#Remove-Item "$env:public\desktop\TeamViewer.lnk"
