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

foreach ($user in $userAccounts) {
    New-ADUser @user
}

# --- Create Groups ---
$groupNames = @("DATEVUSER", "TSUser", "Daten_LW", "Scan_LW", "GF", "GF_LW")
foreach ($groupName in $groupNames) {
    New-ADGroup -Name $groupName -GroupScope DomainLocal -DisplayName $groupName -Path "OU=Groups,$($Using:OUPathname)"
}

# --- Assign Users to Groups ---
$usersOU = "OU=User,$($Using:OUPathname)"
$adminsOU = "OU=Admins,$($Using:OUPathname)"

$adUsers = Get-ADUser -Filter * | Where-Object DistinguishedName -like "*$usersOU"
$adminUsers = Get-ADUser -Filter * | Where-Object DistinguishedName -like "*$adminsOU"

# Custom domain groups
Add-ADGroupMember -Identity "Scan_LW" -Members $adUsers, $adminUsers
Add-ADGroupMember -Identity "TSUser" -Members $adUsers, $adminUsers
Add-ADGroupMember -Identity "Daten_LW" -Members $adUsers, $adminUsers
Add-ADGroupMember -Identity "DATEVUSER" -Members $adUsers, $adminUsers

# Built-in AD administrative groups
$builtInGroups = @(
    "Domänen-Admins",
    "Administratoren",
    "Schema-Admins",
    "Organisations-Admins",
    "Richtlinien-Ersteller-Besitzer"
)

foreach ($group in $builtInGroups) {
    Add-ADGroupMember -Identity $group -Members $adminUsers
}

# --- Move default Administrator to the Admins OU ---
(Get-ADUser -Identity "Administrator").ObjectGUID | Move-ADObject -TargetPath "OU=Admins,$($Using:OUPathname)"
