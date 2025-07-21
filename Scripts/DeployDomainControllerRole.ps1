#Installieren der ADDS Rolle und Konfigurieren eines neuen Forest (Heraufstufen zu einem DomainController)
#Add-Computer -DomainName $Domäne -Restart ##hinzufuegen zu einer domäne



$ADDS = @{
        CreateDnsDelegation = $false 
        DatabasePath = "C:\WINDOWS\NTDS" 
        DomainMode = "Win2025" 
        DomainName = $Using:DomainName  
        DomainNetbiosName = $Using:NetBIOSName 
        ForestMode = "Win2025" 
        InstallDns = $true
        LogPath = "C:\WINDOWS\NTDS"
        NoRebootOnCompletion= $true 
        SysvolPath = "C:\WINDOWS\SYSVOL" 
        Force =$true
        SafeModeAdministratorPassword = $Using:Dsrm}

Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools | Out-Null
Import-Module ADDSDeployment 
Install-ADDSForest @ADDS | Out-Null

Add-DnsServerForwarder -IPAddress 8.8.8.8

Restart-Computer -Force
