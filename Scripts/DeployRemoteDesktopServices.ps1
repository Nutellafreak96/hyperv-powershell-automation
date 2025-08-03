#Erstellen eines Terminalservers durch das Installieren der Rolle Remodedesktopservices

Install-WindowsFeature -IncludeManagementTools -Name @( 
            "Remote-Desktop-Services",
            "RDS-RD-Server", 
            "RDS-Connection-Broker", 
            "RDS-Web-Access",
            "RDS-Licensing"
        ) -Restart | Out-Null

