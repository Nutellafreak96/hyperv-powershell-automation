<#
.SYNOPSIS
Creates an organizational unit (OU) structure in Active Directory.

.DESCRIPTION
This script creates a base OU and several child OUs commonly used in RDS/Windows environments:
- User
- Admins
- Computer
- RDS-Server
- Server
- Groups
- Deactivated Users

Additionally, it moves the computers "TS" and "FS" to the corresponding OUs.

.PARAMETER Using:OUName
The name of the root organizational unit to be created.

.PARAMETER Using:DomainForGPO
The distinguished name (DN) of the domain where the root OU should be placed.

.PARAMETER Using:OUPathname
The full DN path of the root OU used to create sub-OUs.

.NOTES
- Requires the ActiveDirectory PowerShell module
- Make sure the computer objects (e.g., "TS", "FS") already exist in the domain
#>

# --- Define OU structures using hashtables ---

$rootOU = @{
    Name = $Using:OUName
    Path = $Using:DomainForGPO
}
$userOU = @{
    Name = "User"
    Path = $Using:OUPathname
}
$adminsOU = @{
    Name = "Admins"
    Path = $Using:OUPathname
}
$computerOU = @{
    Name = "Computer"
    Path = $Using:OUPathname
}
$rdsServerOU = @{
    Name = "RDS-Server"
    Path = $Using:OUPathname
}
$serverOU = @{
    Name = "Server"
    Path = $Using:OUPathname
}
$groupsOU = @{
    Name = "Groups"
    Path = $Using:OUPathname
}
$disabledUserOU = @{
    Name = "Deactivated"
    Path = "OU=User," + $Using:OUPathname
}

# --- Create OUs ---

New-ADOrganizationalUnit @rootOU
New-ADOrganizationalUnit @userOU
New-ADOrganizationalUnit @groupsOU
New-ADOrganizationalUnit @adminsOU
New-ADOrganizationalUnit @computerOU
New-ADOrganizationalUnit @rdsServerOU
New-ADOrganizationalUnit @serverOU
New-ADOrganizationalUnit @disabledUserOU

# --- Move known computers to appropriate OUs ---

Get-ADComputer -Identity "TS" | Move-ADObject -TargetPath "OU=RDS-Server,$($Using:OUPathname)"
Get-ADComputer -Identity "FS" | Move-ADObject -TargetPath "OU=Server,$($Using:OUPathname)"
