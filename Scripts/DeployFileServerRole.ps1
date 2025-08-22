<#
.DESCRIPTION
Script to change the settings of the Networkadapter of a VM and install the fileserver role
.NOTES
    Author: Kevin Hübner
    Language: PowerShell
    Context: Windows Server Setup Automation (NTFS, Shares, ACL)
#>

$InterfaceAlias = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -like "Extern*" -or $_.InterfaceAlias -like "Ethernet*"} | Select-Object -ExpandProperty InterfaceAlias

Disable-NetAdapterBinding -Name $InterfaceAlias -ComponentID "ms_tcpip6"
New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress $Using:FSIPAdress -AddressFamily IPv4 -DefaultGateway $Using:DefaultGateway -PrefixLength 24 #| Out-Null 
Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $Using:DCIPAdress 

$InterfaceIpAddress = (Get-NetIPAddress -InterfaceAlias $InterfaceAlias  -AddressFamily IPv4).IPAddress


if($InterfaceIpAddress -ne $Using:FSIPAdress){
    New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress $Using:FSIPAdress -AddressFamily IPv4 -DefaultGateway $Using:DefaultGateway -PrefixLength 24 #| Out-Null
    Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $Using:DCIPAdress 

}


Install-WindowsFeature -ConfigurationFilePath C:\temp\Dateiserver.xml 

Rename-Computer -NewName "FS"
Restart-Computer -Force 

