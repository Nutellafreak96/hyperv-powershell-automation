<#
.DESCRIPTION
Script to change install and configure the active directory service role
.NOTES
    Author: Kevin Hübner
    Language: PowerShell
    Context: Windows Server Setup Automation (NTFS, Shares, ACL)
#>


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
