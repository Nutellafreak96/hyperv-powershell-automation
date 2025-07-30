#Erstellen eines Terminalservers durch das Installieren der Rolle Remodedesktopservices


$FQDN = "TS." + $Using:DomainName



Add-RDSessionHost -SessionHost $FQDN -ConnectionBroker $FQDN -CollectionName $Using:KundeRDP | Out-Null
New-RDSessionDeployment -ConnectionBroker $FQDN -SessionHost $FQDN -WebAccessServer $FQDN | Out-Null
#New-RDSessionCollection -CollectionName $Using:KundeRDP -SessionHost $FQDN -ConnectionBroker $FQDN | Out-Null
 
