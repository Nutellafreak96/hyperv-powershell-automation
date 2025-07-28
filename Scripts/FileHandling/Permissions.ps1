#region NTFS Share and Permission Setup

<##
.SYNOPSIS
    Creates SMB shares and NTFS permissions for predefined folders.

.DESCRIPTION
    This script sets up SMB shares and NTFS access permissions for directories like DATEV, Scan, GF, and Daten.
    It disables inheritance, grants custom access rights to domain groups, and applies NTFS ACLs.

.NOTES
    Author: Kevin Hübner
    Language: PowerShell
    Context: Windows Server Setup Automation (NTFS, Shares, ACL)
##>


$ShareDefinitions = @(
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
foreach($items in $ShareDefinitions){New-SmbShare @items | Out-Null}


# NTFS Permissions - Disable inheritance, remove inherited rules
$WINDVSW1 = Get-Acl -Path "D:\Freigaben\WINDVSW1\"
$isProtected = $true #Disable inheritance
$preserveInheritance = $false #remove inherited rules
$WINDVSW1.SetAccessRuleProtection($isProtected, $preserveInheritance) #Disable inheritance, remove inherited rules
Set-Acl -Path "D:\Freigaben\WINDVSW1" -AclObject $WINDVSW1


#NTFS Permissions for the Datev Directory
#Group: DatevUser
$WINDVSW1 = Get-Acl -Path "D:\Freigaben\WINDVSW1\"
$identity = "$($Using:NetBiosName)\DATEVUSER"
$rights = "Modify,Synchronize"
$inheritance = "ContainerInherit"
$propagation = "none"
$type = "Allow"											 
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propagation, $type)
$WINDVSW1.AddaccessRule($ACE)
Set-Acl -Path "D:\Freigaben\WINDVSW1\" -AclObject $WINDVSW1

$WINDVSW1 = Get-Acl -Path "D:\Freigaben\WINDVSW1\"
$identity = "$($Using:NetBiosName)\DATEVUSER"
$rights = "Write,Delete,Read,Synchronize"
$inheritance = "ObjectInherit"
$propagation = "InheritOnly"
$type = "Allow"
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propagation, $type)
$WINDVSW1.AddaccessRule($ACE)
Set-Acl -Path "D:\Freigaben\WINDVSW1\" -AclObject $WINDVSW1

#Group: Domain-Admins
$WINDVSW1 = Get-Acl -Path "D:\Freigaben\WINDVSW1\"
$identity = "$($Using:NetBiosName)\Domänen-Admins"
$rights = "FullControl"											 
$inheritance = "ContainerInherit, ObjectInherit" 				 
$propagation = "None" 											 
$type = "Allow" 
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propagation, $type)
$WINDVSW1.AddaccessRule($ACE)
Set-Acl -Path "D:\Freigaben\WINDVSW1\" -AclObject $WINDVSW1

#Ersteller-Besitzer
$WINDVSW1 = Get-Acl -Path "D:\Freigaben\WINDVSW1\"
$identity = "ERSTELLER-BESITZER"
$rights = "FullControl"											 
$inheritance = "ContainerInherit, ObjectInherit"  				 
$propagation = "InheritOnly" 											 
$type = "Allow" 
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propagation, $type)
$WINDVSW1.AddaccessRule($ACE)
Set-Acl -Path "D:\Freigaben\WINDVSW1\" -AclObject $WINDVSW1

#System
$WINDVSW1 = Get-Acl -Path "D:\Freigaben\WINDVSW1\"
$identity = "SYSTEM"
$rights = "FullControl"											 
$inheritance = "ContainerInherit, ObjectInherit"  				 
$propagation = "None" 											 
$type = "Allow" 
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propagation, $type)
$WINDVSW1.AddaccessRule($ACE)
Set-Acl -Path "D:\Freigaben\WINDVSW1\" -AclObject $WINDVSW1


# NTFS Permissions for the Scan Directory

$Scan = Get-Acl -Path "D:\Freigaben\Scan\"
$isProtected = $true #Disable inheritance
$preserveInheritance = $false #remove inherited rules
$Scan.SetAccessRuleProtection($isProtected, $preserveInheritance)
Set-Acl -Path "D:\Freigaben\Scan" -AclObject $Scan

#Group: Domain-Admins
$Scan = Get-Acl -Path "D:\Freigaben\Scan\"
$identity = "$($Using:NetBiosName)\Domänen-Admins"
$rights = "FullControl"											 
$inheritance = "ContainerInherit, ObjectInherit" 				 
$propagation = "None" 											 
$type = "Allow" 
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propagation, $type)
$Scan.AddaccessRule($ACE)
Set-Acl -Path "D:\Freigaben\Scan\" -AclObject $Scan
#Group: Scan_LW
$Scan = Get-Acl -Path "D:\Freigaben\Scan\"
$identity = "Scan_LW"
$rights = "Modify, Synchronize"											 
$inheritance = "ContainerInherit, ObjectInherit" 				 
$propagation = "None" 											 
$type = "Allow" 
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propagation, $type)
$Scan.AddaccessRule($ACE)
Set-Acl -Path "D:\Freigaben\Scan\" -AclObject $Scan
#Ersteller-Besitzer
$Scan = Get-Acl -Path "D:\Freigaben\Scan\"
$identity = "ERSTELLER-BESITZER"
$rights = "FullControl"											 
$inheritance = "ContainerInherit, ObjectInherit"  				 
$propagation = "InheritOnly" 											 
$type = "Allow" 
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propagation, $type)
$Scan.AddaccessRule($ACE)
Set-Acl -Path "D:\Freigaben\Scan\" -AclObject $Scan
#System
$Scan = Get-Acl -Path "D:\Freigaben\Scan\"
$identity = "SYSTEM"
$rights = "FullControl"											 
$inheritance = "ContainerInherit, ObjectInherit"  				 
$propagation = "None" 											 
$type = "Allow" 
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propagation, $type)
$Scan.AddaccessRule($ACE)
Set-Acl -Path "D:\Freigaben\Scan\" -AclObject $Scan


# NTFS Permission for the GF Directory

$GF = Get-Acl -Path "D:\Freigaben\GF\"
$isProtected = $true #Disable inheritance
$preserveInheritance = $false #remove inherited rules
$GF.SetAccessRuleProtection($isProtected, $preserveInheritance)
Set-Acl -Path "D:\Freigaben\GF\" -AclObject $GF

# Group: DOmain-Admins
$GF = Get-Acl -Path "D:\Freigaben\GF\"
$identity = "$($Using:NetBiosName)\Domänen-Admins"
$rights = "FullControl"											 
$inheritance = "ContainerInherit, ObjectInherit" 				 
$propagation = "None" 											 
$type = "Allow" 
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propagation, $type)
$GF.AddaccessRule($ACE)
Set-Acl -Path "D:\Freigaben\GF\" -AclObject $GF

#Group: GF_LW
$GF = Get-Acl -Path "D:\Freigaben\GF\"
$identity = "GF_LW"
$rights = "Modify, Synchronize"											 
$inheritance = "ContainerInherit, ObjectInherit" 				 
$propagation = "None" 											 
$type = "Allow" 
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propagation, $type)
$GF.AddaccessRule($ACE)
Set-Acl -Path "D:\Freigaben\GF\" -AclObject $GF

#Ersteller-Besitzer
$GF = Get-Acl -Path "D:\Freigaben\GF\"
$identity = "ERSTELLER-BESITZER"
$rights = "FullControl"											 
$inheritance = "ContainerInherit, ObjectInherit"  				 
$propagation = "InheritOnly" 											 
$type = "Allow" 
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propagation, $type)
$GF.AddaccessRule($ACE)
Set-Acl -Path "D:\Freigaben\GF\" -AclObject $GF

#System
$GF = Get-Acl -Path "D:\Freigaben\GF\"
$identity = "SYSTEM"
$rights = "FullControl"											 
$inheritance = "ContainerInherit, ObjectInherit"  				 
$propagation = "None" 											 
$type = "Allow" 
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propagation, $type)
$GF.AddaccessRule($ACE)
Set-Acl -Path "D:\Freigaben\GF\" -AclObject $GF


# NTFS Permission for the Daten Directory

$Daten = Get-Acl -Path "D:\Freigaben\Daten\"
$isProtected = $true #Disable inheritance
$preserveInheritance = $false #remove inherited rules
$Daten.SetAccessRuleProtection($isProtected, $preserveInheritance)
Set-Acl -Path "D:\Freigaben\Daten\" -AclObject $Daten

#Group: Domain-Admins
$Daten = Get-Acl -Path "D:\Freigaben\Daten\"
$identity = "$($Using:NetBiosName)\Domänen-Admins"
$rights = "FullControl"											 
$inheritance = "ContainerInherit, ObjectInherit" 				 
$propagation = "None" 											 
$type = "Allow" 
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propagation, $type)
$Daten.AddaccessRule($ACE)
Set-Acl -Path "D:\Freigaben\Daten\" -AclObject $Daten

#Group: Daten_LW
$Daten = Get-Acl -Path "D:\Freigaben\Daten\"
$identity = "Daten_LW"
$rights = "Modify, Synchronize"											 
$inheritance = "ContainerInherit, ObjectInherit" 				 
$propagation = "None" 											 
$type = "Allow" 
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propagation, $type)
$Daten.AddaccessRule($ACE)
Set-Acl -Path "D:\Freigaben\Daten\" -AclObject $Daten

#Ersteller
$Daten = Get-Acl -Path "D:\Freigaben\Daten\"
$identity = "ERSTELLER-BESITZER"
$rights = "FullControl"											 
$inheritance = "ContainerInherit, ObjectInherit"  				 
$propagation = "InheritOnly" 											 
$type = "Allow" 
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propagation, $type)
$Daten.AddaccessRule($ACE)
Set-Acl -Path "D:\Freigaben\Daten\" -AclObject $Daten

#System
$Daten = Get-Acl -Path "D:\Freigaben\Daten\"
$identity = "SYSTEM"
$rights = "FullControl"											 
$inheritance = "ContainerInherit, ObjectInherit"  				 
$propagation = "None" 											 
$type = "Allow" 
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propagation, $type)
$Daten.AddaccessRule($ACE)
Set-Acl -Path "D:\Freigaben\Daten\" -AclObject $Daten