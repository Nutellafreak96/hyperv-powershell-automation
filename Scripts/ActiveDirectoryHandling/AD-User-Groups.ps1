#Notwendige Gruppen und Benutzer erstellen
#AD Gruppen und Benutzer erstellen


#Benutzer
$Users = @(
    @{
        Path                  = "OU=Admins,$($Using:OUPathname)"
        ChangePasswordAtLogon = $false
        AccountPassword       = $Using:ASPW
        PasswordNeverExpires  = $true
        Enabled               = $true
        GivenName             = "Chambionic"
        Name                  = "Chambionic GmbH"
        SamAccountName        = "chadmin"
        Surname               = "GmbH"
        UserPrincipalName     = "chadmin@$($using:DomainName)"
    },
    @{
        Path                  = "OU=User,$($Using:OUPathname)"
        ChangePasswordAtLogon = $false
        AccountPassword       = $Using:BSPW
        PasswordNeverExpires  = $true
        Enabled               = $true
        GivenName             = "Test"
        Name                  = "Test-User"
        SamAccountName        = "tuser"
        Surname               = "User"
        UserPrincipalName     = "t.user@$($using:DomainName)"
    }
)

foreach($item in $Users){New-ADUser @item}


#Gruppen
New-ADGroup -Name "DATEVUSER" -GroupScope DomainLocal -DisplayName "DATEVUSER" -Path "OU=Groups,$($Using:OUPathname)"
New-ADGroup -Name "TSUser" -GroupScope DomainLocal -DisplayName "TSUSer" -Path "OU=Groups,$($Using:OUPathname)"
New-ADGroup -Name "Daten_LW" -GroupScope DomainLocal -DisplayName "Daten_LW" -Path "OU=Groups,$($Using:OUPathname)"
New-ADGroup -Name "Scan_LW" -GroupScope DomainLocal -DisplayName "Scan_LW" -Path "OU=Groups,$($Using:OUPathname)"
New-ADGroup -Name "GF" -GroupScope DomainLocal -DisplayName "GF" -Path "OU=Groups,$($Using:OUPathname)"
New-ADGroup -Name "GF_LW" -GroupScope DomainLocal -DisplayName "GF_LW" -Path "OU=Groups,$($Using:OUPathname)"


#User den Gruppen zuordnen
$AdUser = Get-ADUser -Filter * | Select-Object -Property DistinguishedName,SamAccountName | Where-Object DistinguishedName -match "OU=User,$($Using:OUPathname)"
$AdminAdUser = Get-ADUser -Filter * | Select-Object -Property DistinguishedName,SamAccountName | Where-Object DistinguishedName -match "OU=Admins,$($Using:OUPathname)"
Add-ADGroupMember -Identity Scan_LW -Members $AdUser, $AdminAdUser
Add-ADGroupMember -Identity TSUser -Members $AdUser, $AdminAdUser
Add-ADGroupMember -Identity Daten_LW -Members $AdUser, $AdminAdUser
Add-ADGroupMember -Identity DATEVUSER -Members $AdUser, $AdminAdUser
Add-ADGroupMember -Identity Domänen-Admins -Members $AdminAdUser
Add-ADGroupMember -Identity Administratoren -Members $AdminAdUser
Add-ADGroupMember -Identity Schema-Admins -Members $AdminAdUser
Add-ADGroupMember -Identity Organisations-Admins -Members $AdminAdUser
Add-ADGroupMember -Identity Richtlinien-Ersteller-Besitzer -Members $AdminAdUser

#Den Administrator zur OU verschieben damit die GPOs greifen
(Get-ADUser -Identity "Administrator").ObjectGUID | Move-ADObject -TargetPath "OU=Admins,$($Using:OUPathname)"
