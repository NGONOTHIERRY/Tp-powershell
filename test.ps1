$DnsServerName = "srvc.dc1"
$IpAddress = "192.168.147.10"
$Forwarders = @("8.8.8.8", "8.8.4.4")

    Install-WindowsFeature DNS -IncludeManagementTools

New-NetIPAddress -InterfaceAlias $adapter.Name -IPAddress $IpAddress -PrefixLength 24 -DefaultGateway "192.168.147.1"

Rename-Computer -NewName $DnsServerName 
Restart-Computer 

Import-Module DNSServer

$Rapport = @"
===== RAPPORT SYSTEME =====
 srv1.dc1 : $DnsServerName
 Adresse IP : $IpAddress
Ipadress : $IpAddress
Forwarders : $( $Forwarders -join ", " )
DefaulGeteway : $defaultGateway
===========================
"@
$Rapport | Out-File "./audit_system.csv"Encoding UTF8
Write-Host "Rapport généré dans /audit_system.cs1"ForegroundColor Green