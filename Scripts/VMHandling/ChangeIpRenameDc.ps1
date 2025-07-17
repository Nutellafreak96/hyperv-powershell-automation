$InterfaceAlias = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -like "Extern*" -or $_.InterfaceAlias -like "Ethernet*"} | Select-Object -ExpandProperty InterfaceAlias


<#Set Ip-Address of Adapter Ethernet to static#>
New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress $Using:DCIPAdress -AddressFamily IPv4 -DefaultGateway $Using:DefaultGateway -PrefixLength 24 | Out-Null 
Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses "127.0.0.1"

$InterfaceIpAddress = (Get-NetIPAddress -InterfaceAlias $InterfaceAlias  -AddressFamily IPv4).IPAddress
if($InterfaceIpAddress -ne $Using:FSIPAdress){
    New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress $Using:DCIPAdress -AddressFamily IPv4 -DefaultGateway $Using:DefaultGateway -PrefixLength 24 | Out-Null 
    Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses "127.0.0.1"
}


<#Rename and Restart Command#>
Rename-Computer -NewName "DC"
Restart-Computer -Force
