<#
.DESCRIPTION
Script to configure the necessary Remote Desktop roles
.NOTES
    Author: Kevin Hübner
    Language: PowerShell
    Context: Windows Server Setup Automation (NTFS, Shares, ACL)
#>

param(
    [string]$KundeRDP,
    [string]$DomainName
)

$FQDN = "TS." + $DomainName

New-RDSessionDeployment -ConnectionBroker $FQDN -SessionHost $FQDN -WebAccessServer $FQDN | Out-Null
New-RDSessionCollection -CollectionName $KundeRDP -SessionHost $FQDN -ConnectionBroker $FQDN | Out-Null
Set-RDSessionCollectionConfiguration -UserGroup "TSUser" -CollectionName $KundeRDP | Out-Null

