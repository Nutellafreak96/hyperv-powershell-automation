#Skript zum erstellen der Organisationseinheit (OU) 


$OU = @{
    name = $Using:OUName 
    path = $Using:DomainForGPO
}
$User = @{
    name = "User"
    path = $Using:OUPathname
}
$Admins = @{
    name = "Admins"
    path = $Using:OUPathname
}
$Computer = @{
    name = "Computer"
    path = $Using:OUPathname
}
$RDSServer = @{
    name = "RDS-Server"
    path = $Using:OUPathname
}
$Server = @{
    name = "Server"
    path = $Using:OUPathname
}
$Groups = @{
    name = "Groups"
    path = $Using:OUPathname
}
$User_deaktiviert = @{
    name = "Deaktiviert"
    path = "OU=User,"+ $Using:OUPathname
}
New-ADOrganizationalUnit @OU
New-ADOrganizationalUnit @User
New-ADOrganizationalUnit @Groups
New-ADOrganizationalUnit @Admins
New-ADOrganizationalUnit @Computer
New-ADOrganizationalUnit @RDSServer
New-ADOrganizationalUnit @Server
New-ADOrganizationalUnit @User_deaktiviert

Get-ADComputer -Identity "TS" | Move-ADObject -TargetPath "OU=RDS-Server,$($Using:OUPathname)"
Get-ADComputer -Identity "FS" | Move-ADObject -TargetPath "OU=Server,$($Using:OUPathname)"
