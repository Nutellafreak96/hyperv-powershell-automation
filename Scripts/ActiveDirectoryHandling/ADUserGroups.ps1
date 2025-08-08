<#
.SYNOPSIS
Creates necessary Active Directory (AD) users and groups, assigns group memberships, and moves the default Administrator account.

.DESCRIPTION
This script:
- Creates two users (admin and test user) in specific OUs.
- Creates several domain-local groups for various purposes (e.g., file access, RDS).
- Adds users to those groups.
- Adds the admin user to built-in administrative groups.
- Moves the default Administrator account into the "Admins" OU so that GPOs can be applied.

.PARAMETER Using:OUPathname
Distinguished Name (DN) of the root OU where the users and groups will be created.

.PARAMETER Using:ASPW
Password for the admin user "chadmin".

.PARAMETER Using:BSPW
Password for the test user "tuser".

.PARAMETER Using:DomainName
FQDN of the Active Directory domain.

.NOTES
- Requires ActiveDirectory PowerShell module.
- Must be run with sufficient privileges to create users, groups, and modify memberships.

.EXAMPLE
.\Create-UsersAndGroups.ps1
#>

# --- Create Users ---
$userAccounts = @(
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
        UserPrincipalName     = "chadmin@$($Using:DomainName)"
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
        UserPrincipalName     = "t.user@$($Using:DomainName)"
    }
)

foreach ($user in $userAccounts) {New-ADUser @user}

# --- Create Groups ---
New-ADGroup -Name "DATEVUSER" -GroupScope DomainLocal -DisplayName "DATEVUSER" -Path "OU=Groups,$($Using:OUPathname)"
New-ADGroup -Name "TSUser" -GroupScope DomainLocal -DisplayName "TSUSer" -Path "OU=Groups,$($Using:OUPathname)"
New-ADGroup -Name "Daten_LW" -GroupScope DomainLocal -DisplayName "Daten_LW" -Path "OU=Groups,$($Using:OUPathname)"
New-ADGroup -Name "Scan_LW" -GroupScope DomainLocal -DisplayName "Scan_LW" -Path "OU=Groups,$($Using:OUPathname)"
New-ADGroup -Name "GF" -GroupScope DomainLocal -DisplayName "GF" -Path "OU=Groups,$($Using:OUPathname)"
New-ADGroup -Name "GF_LW" -GroupScope DomainLocal -DisplayName "GF_LW" -Path "OU=Groups,$($Using:OUPathname)"


# --- Assign Users to Groups ---
$AdUser = Get-ADUser -Filter * | Select-Object -Property DistinguishedName,SamAccountName | Where-Object DistinguishedName -match "OU=User,$($Using:OUPathname)"
$AdminAdUser = Get-ADUser -Filter * | Select-Object -Property DistinguishedName,SamAccountName | Where-Object DistinguishedName -match "OU=Admins,$($Using:OUPathname)"
Add-ADGroupMember -Identity "Scan_LW"-Members $AdUser, $AdminAdUser
Add-ADGroupMember -Identity "TSUser" -Members $AdUser, $AdminAdUser
Add-ADGroupMember -Identity "Daten_LW" -Members $AdUser, $AdminAdUser
Add-ADGroupMember -Identity "DATEVUSER" -Members $AdUser, $AdminAdUser
Add-ADGroupMember -Identity "Domänen-Admins" -Members $AdminAdUser
Add-ADGroupMember -Identity "Administratoren" -Members $AdminAdUser
Add-ADGroupMember -Identity "Schema-Admins" -Members $AdminAdUser
Add-ADGroupMember -Identity "Organisations-Admins" -Members $AdminAdUser
Add-ADGroupMember -Identity "Richtlinien-Ersteller-Besitzer" -Members $AdminAdUser

Get-ADUser -Identity Administrator | Move-ADObject -TargetPath "OU=Admins,$($Using:OUPathname)"
