<#
.SYNOPSIS
Prepares the file server (FS) for DATEV and configures folder structures for sharing.

.DESCRIPTION
This script brings disk 1 online, formats it as NTFS with drive letter D:, and creates several directories used for file sharing in a DATEV environment. 
These include folders for configuration databases, general data storage, scanned documents, and management files.

.NOTES
- This script assumes that Disk 1 is intended for use as the data volume.
- Folders are created in the `D:\Freigaben\` structure.

.EXAMPLE
.\Prepare-DatevFolders.ps1
#>

# Bring Disk 1 online
Get-Disk -Number 1 | Set-Disk -IsOffline $false 

# Initialize Disk for first use
Initialize-Disk -Number 1

# Create a new volume on Disk 1 and assign it as drive D:
Get-Disk -Number 1 | New-Volume -FriendlyName "Daten" -DriveLetter D -FileSystem NTFS | Out-Null

# Create DATEV-specific folder structure under D:\Freigaben\
New-Item -ItemType Directory -Path "D:\Freigaben\WINDVSW1\" -Name "CONFIGDB" | Out-Null
New-Item -ItemType Directory -Path "D:\Freigaben\" -Name "Daten" | Out-Null
New-Item -ItemType Directory -Path "D:\Freigaben\" -Name "Scan" | Out-Null
New-Item -ItemType Directory -Path "D:\Freigaben\" -Name "GF" | Out-Null
