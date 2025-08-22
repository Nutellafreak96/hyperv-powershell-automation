
<#
.SYNOPSIS
Creates and links Group Policy Objects (GPOs) and sets associated registry values for system and user configurations.

.DESCRIPTION
This script automates the creation and linking of GPOs for:
- Energy settings (High Performance mode)
- Remote Desktop settings (timeout policies)
- RDS licensing configuration
- Default application associations
- Outlook UI configuration and system restrictions for users
- Drive mapping group SID correction in XML
It also updates an XML file with correct group SIDs for drive mapping preferences.

- Requires RSAT tools (GroupPolicy and ActiveDirectory modules)
- This script assumes that group names match the names used in Drive.xml
- Uses `Set-GPRegistryValue` to enforce registry-based GPO settings

.PARAMETER Using:OUPathname
A scoped variable (e.g. from a parent script block) containing the base OU distinguished name used for GPO targeting.

.NOTES
    Author: Kevin Hübner
    Language: PowerShell
    Context: Windows Server Setup Automation (NTFS, Shares, ACL)
#>


# --- Energy Policy GPO ---
# Creates a GPO to enforce High Performance energy plan and links it to target OUs
New-GPO -Name "Computer - Energie - Hoechstleistung" | Out-Null
New-GPLink -Name "Computer - Energie - Hoechstleistung" -Target "OU=Computer,$($Using:OUPathname)" -LinkEnabled Yes | Out-Null
New-GPLink -Name "Computer - Energie - Hoechstleistung" -Target "OU=RDS-Server,$($Using:OUPathname)" -LinkEnabled Yes | Out-Null
$energyPolicy = @{
    Name      = "Computer - Energie - Hoechstleistung"
    Key       = "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Power\Powersettings"
    ValueName = "ActivePowerScheme"
    Value     = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"  # High Performance GUID
    Type      = "String"
}
Set-GPRegistryValue @energyPolicy | Out-Null


# --- RDP Settings GPO ---
# Creates a GPO to configure RDP timeout values and links it to the RDS OU
New-GPO -Name "Computer - RDP - Settings" | Out-Null
New-GPLink -Name "Computer - RDP - Settings" -Target "OU=RDS-Server,$($Using:OUPathname)" -LinkEnabled Yes | Out-Null
$rdpSettings = @(
    @{
        Name      = "Computer - RDP - Settings"
        Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
        ValueName = "MaxDisconnectionTime"
        Value     = 7200000  # 2 hours
        Type      = "DWord"
    },
    @{
        Name      = "Computer - RDP - Settings"
        Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
        ValueName = "MaxIdleTime"
        Value     = 10800000  # 3 hours
        Type      = "DWord"
    }
)
foreach ($params in $rdpSettings) { Set-GPRegistryValue @params | Out-Null }

 
# --- RDS Licensing GPO ---
# Configures RDS license server and mode
New-GPO -Name "Computer - RDS - Lizenzen" | Out-Null
New-GPLink -Name "Computer - RDS - Lizenzen" -Target "OU=RDS-Server,$($Using:OUPathname)" -LinkEnabled Yes | Out-Null
$rdsLicensing = @(
    @{
        Name      = "Computer - RDS - Lizenzen"
        Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
        ValueName = "LicenseServers"
        Value     = "192.168.175.103"
        Type      = "String"
    },
    @{
        Name      = "Computer - RDS - Lizenzen"
        Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
        ValueName = "LicensingMode"
        Value     = 4  # Per user
        Type      = "DWord"
    }
)
foreach ($params in $rdsLicensing) { Set-GPRegistryValue @params | Out-Null }

# --- Default Apps GPO ---
# Configures file association defaults from a shared XML file
New-GPO -Name "Computer - Default - Apps" | Out-Null
New-GPLink -Name "Computer - Default - Apps" -Target "OU=RDS-Server,$($Using:OUPathname)" -LinkEnabled Yes | Out-Null
$defaultApps = @{
    Name      = "Computer - Default - Apps"
    Key       = "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\System"
    ValueName = "DefaultAssociationsConfiguration"
    Value     = "\\DC\netlogon\DefaultApps.xml"
    Type      = "String"
}
Set-GPRegistryValue @defaultApps | Out-Null


# --- XML SID Update for Drive Mapping ---
# Updates drive mapping XML to match current group SIDs

# Load the XML file
$xmlPath = "C:\temp\{812FABB7-FDB3-4A46-8E8D-85BD985BA327}\DomainSysvol\GPO\User\Preferences\Drives\Drives.xml"
$xml = [xml](Get-Content -Path $xmlPath)

# Fetch groups and their SIDs from the new domain
$groups = Get-ADGroup -Filter * -SearchBase $Using:OUPathname

# Create an array of group name and SID pairs
$groupSidPairs = @()
foreach ($group in $groups) {
    $groupSidPairs += [PSCustomObject]@{
        GroupName = $group.Name  # Just the name, no domain prefix
        SID       = $group.SID.Value
    }
}

# Go through each Drive in the XML
foreach ($drive in $xml.Drives.Drive) {
    foreach ($filter in $drive.Filters.FilterGroup) {
        $xmlGroupFullName = $filter.GetAttribute("name")  # e.g., kevin\Scan_LW

        # Extract only the group name (after the backslash)
        $xmlGroupName = $xmlGroupFullName -replace '^.*\\', ''

        # Find matching group in the SID pairs (case-insensitive)
        $matchingPair = $groupSidPairs | Where-Object { $_.GroupName -ieq $xmlGroupName }

        if ($matchingPair) {
            $filter.SetAttribute("sid", $matchingPair.SID)

            # Optionally also update the domain prefix in the "name" attribute
            $newGroupName = "$Using:NetBIOSName\$xmlGroupName"
            $filter.SetAttribute("name", $newGroupName)
        } else {
            Write-Host "No matching group found for: $xmlGroupFullName"
        }
    }
}

# Save the updated XML back to the same file
$xml.Save($xmlPath)


# --- User Drive Mapping GPO ---
# Restores GPO for mapping network drives and links it to user/admin OUs
Import-GPO -BackupGpoName "User - Netzwerk - Laufwerke" -TargetName "User - Netzwerk - Laufwerke" -Path "C:\temp" -CreateIfNeeded | Out-Null
New-GPLink -Name "User - Netzwerk - Laufwerke" -Target "OU=User,$($Using:OUPathname)" -LinkEnabled Yes | Out-Null
New-GPLink -Name "User - Netzwerk - Laufwerke" -Target "OU=Admins,$($Using:OUPathname)" -LinkEnabled Yes | Out-Null

# --- GUI Lockdown GPO ---
# Hides new Outlook toggle and disables access to certain Control Panel items
New-GPO -Name "User - GUI - Settings" | Out-Null
New-GPLink -Name "User - GUI - Settings" -Target "OU=User,$($Using:OUPathname)" -LinkEnabled Yes | Out-Null
$UserSettings = @(
    @{
        Name = "User - GUI - Settings"
        Key = "HKEY_CURRENT_USER\Software\Policies\Microsoft\office\16.0\Outlook\Preferences"
        ValueName = "NewOutlookMigrationUserSetting"
        Value = 00000000
        Type = "DWord"
    },
    @{
        Name = "User - GUI - Settings"
        Key = "HKEY_CURRENT_USER\Software\Policies\Microsoft\office\16.0\Outlook\Options\General"
        ValueName = "DoNewOutlookAutoMigration"
        Value = 00000000
        Type = "DWord"
    },
    @{
        Name = "User - GUI - Settings"
        Key = "HKEY_CURRENT_USER\Software\Policies\Microsoft\office\16.0\Outlook\Preferences"
        ValueName = "UseNewOutlook"
        Value = 00000000
        Type = "DWord"
    },
    @{
        Name = "User - GUI - Settings"
        Key = "HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Office\16.0\Outlook\Options\General"
        ValueName = "NewOutlookAutoMigrationRetryIntervals"
        Value = 00000000
        Type = "DWord"
    },
    @{
        Name = "User - GUI - Settings"
        Key = "HKEY_CURRENT_USER\Software\Policies\Microsoft\office\16.0\Outlook\Options\General"
        ValueName = "HideNewOutlookToggle"
        Value = 00000001
        Type = "DWord"
    },
    @{
    Name      = "User - GUI - Settings"
    Key       = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    Value     = 1
    Type      = "DWord"
    ValueName = "RestrictCpl"
},
@{
    Name      = "User - GUI - Settings"
    Key       = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\RestrictCpl"
    Value     = "Microsoft.PowerOptions"
    Type      = "String"
    ValueName = "1"
},
@{
    Name      = "User - GUI - Settings"
    Key       = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\RestrictCpl"
    Value     = "Microsoft.Sound"
    Type      = "String"
    ValueName = "2"
},
@{
    Name      = "User - GUI - Settings"
    Key       = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\RestrictCpl"
    Value     = "Microsoft.Keyboard"
    Type      = "String"
    ValueName = "3"
},
@{
    Name      = "User - GUI - Settings"
    Key       = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\RestrictCpl"
    Value     = "Microsoft.DevicesAndPrinters"
    Type      = "String"
    ValueName = "4"
},
@{
    Name      = "User - GUI - Settings"
    Key       = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\RestrictCpl"
    Value     = "Microsoft.Mouse"
    Type      = "String"
    ValueName = "5"
},
@{
    Name      = "User - GUI - Settings"
    Key       = "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Powershell"
    Value     = 0
    Type      = "DWord"
    ValueName = "EnableScripts"
},
@{ 
    Name      = "User - GUI - Settings"
    Key       = "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Powershell"
    #PolicyState : Delete
    Value     = ""
    Type      = "String"
    ValueName = "ExecutionPolicy"
},
@{
    Name      = "User - GUI - Settings"
    Key       = "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\System"
    Value     = 2
    Type      = "DWord"
    ValueName = "DisableCMD"
}
)
foreach($params in $UserSettings){Set-GPRegistryValue @params | Out-Null}
