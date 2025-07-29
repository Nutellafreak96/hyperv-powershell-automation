#Erstellen eines Terminalservers durch das Installieren der Rolle Remodedesktopservices


$FQDN = "TS." + $Using:DomainName


Install-WindowsFeature -IncludeManagementTools -Name @("RDS-RD-Server","RDS-Connection-Broker","RDS-Web-Access")
Add-RDSessionHost -SessionHost $FQDN -ConnectionBroker $FQDN | Out-Null
New-RDSessionDeployment -ConnectionBroker $FQDN -SessionHost $FQDN -WebAccessServer $FQDN | Out-Null
New-RDSessionCollection -CollectionName $Using:KundeRDP -SessionHost $FQDN -ConnectionBroker $FQDN | Out-Null
 
