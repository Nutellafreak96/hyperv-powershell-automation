#Erstellen eines Terminalservers durch das Installieren der Rolle Remodedesktopservices


$FQDN = "TS." + $Using:DomainName


#Install-WindowsFeature -IncludeManagementTools -Name @("Remote-Desktop-Services", "RDS-RD-Server","RDS-Connection-Broker","RDS-Web-Access") -Restart | Out-Null
New-RDSessionDeployment -ConnectionBroker $FQDN -SessionHost $FQDN -WebAccessServer $FQDN | Out-Null
#Add-RDSessionHost -SessionHost $FQDN -ConnectionBroker $FQDN -CollectionName $Using:KundeRDP | Out-Null
New-RDSessionCollection -CollectionName $Using:KundeRDP -SessionHost $FQDN -ConnectionBroker $FQDN | Out-Null
 
