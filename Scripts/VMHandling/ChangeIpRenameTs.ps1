<#
.DESCRIPTION
Script to change the Network Adapter Settings on a VM and rename the virtual computer
.NOTES
    Author: Kevin Hübner
    Language: PowerShell
    Context: Windows Server Setup Automation (NTFS, Shares, ACL)
#>

$InterfaceAlias = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -like "Extern*" -or $_.InterfaceAlias -like "Ethernet*"} | Select-Object -ExpandProperty InterfaceAlias

<#disable ipv6 to prevent problems for joining a domain#>
Disable-NetAdapterBinding -Name $InterfaceAlias -ComponentID "ms_tcpip6"

<#Set Ip-Address to static and set DNS#>
New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress $Using:TSIPAdress -AddressFamily IPv4 -DefaultGateway $Using:DefaultGateway -PrefixLength 24 #| Out-Null
Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $Using:DCIPAdress

$InterfaceIpAddress = (Get-NetIPAddress -InterfaceAlias $InterfaceAlias  -AddressFamily IPv4).IPAddress
Write-Host " -- TS ist:$($InterfaceIpAddress) soll: $($Using:TSIPAdress)"

if($InterfaceIpAddress -ne $Using:FSIPAdress){
    New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress $Using:TSIPAdress -AddressFamily IPv4 -DefaultGateway $Using:DefaultGateway -PrefixLength 24 #|  Out-Null
    Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $Using:DCIPAdress
}

<#Rename and Restart Computer#>
Rename-Computer -NewName "TS"
Restart-Computer -Force 
