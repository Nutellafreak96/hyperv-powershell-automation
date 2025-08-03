param(
    [string]$KundeRDP,
    [string]$DomainName
)

$FQDN = "TS." + $Using:DomainName

New-RDSessionDeployment -ConnectionBroker $FQDN -SessionHost $FQDN -WebAccessServer $FQDN | Out-Null
#Add-RDServer -Server $FQDN  -Role "RDS-RD-SERVER" -ConnectionBroker $FQDN | Out-Null
New-RDSessionCollection -CollectionName $Using:KundeRDP -SessionHost $FQDN -ConnectionBroker $FQDN | Out-Null
Set-RDSessionCollectionConfiguration -UserGroup "TSUser" -CollectionName $Using:KundeRDP | Out-Null

