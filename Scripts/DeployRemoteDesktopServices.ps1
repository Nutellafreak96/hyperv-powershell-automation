<#
.DESCRIPTION
Script to change install and configure the active directory service role
.NOTES
    Author: Kevin Hübner
    Language: PowerShell
    Context: Windows Server Setup Automation (NTFS, Shares, ACL)
#>
Install-WindowsFeature -IncludeManagementTools -Name @( 
            "Remote-Desktop-Services",
            "RDS-RD-Server", 
            "RDS-Connection-Broker", 
            "RDS-Web-Access",
            "RDS-Licensing"
        ) -Restart | Out-Null

