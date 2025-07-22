#Netzwerkfreigaben + Netzlaufwerke erstellen (registry)


$Freigaben = @(
    @{
        Name = "GF"
        Path = "D:\Freigaben\GF"
        ChangeAccess = "$($Using:NetBiosName)\GF"
        FullAccess = "$($Using:NetBiosName)\Domänen-Admins"
    },
    @{
        Name = "Daten"
        Path = "D:\Freigaben\Daten"
        ChangeAccess = "$($Using:NetBiosName)\Daten_LW"
        FullAccess = "$($Using:NetBiosName)\Domänen-Admins"
     },
     @{
        Name = "Scan"
        Path = "D:\Freigaben\Scan"
        ChangeAccess = "$($Using:NetBiosName)\Scan_LW"
        FullAccess = "$($Using:NetBiosName)\Domänen-Admins"
     },
     @{
        Name = "DATEV"
        Path = "D:\Freigaben\WINDVSW1"
        ChangeAccess = "$($Using:NetBiosName)\DATEVUSER"
        FullAccess = "$($Using:NetBiosName)\Domänen-Admins"        
     }
)
foreach($items in $Freigaben){New-SmbShare @items | Out-Null}
