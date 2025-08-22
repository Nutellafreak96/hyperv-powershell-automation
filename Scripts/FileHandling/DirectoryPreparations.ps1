<#
.SYNOPSIS
Prepares the file server (FS) for DATEV and configures folder structures for sharing.

.DESCRIPTION
This script brings disk 1 online, formats it as NTFS with drive letter D:, and creates several directories used for file sharing in a DATEV environment. 
These include folders for configuration databases, general data storage, scanned documents, and management files.

- This script assumes that Disk 1 is intended for use as the data volume.
- Folders are created in the `D:\Freigaben\` structure.

.NOTES
    Author: Kevin Hübner
    Language: PowerShell
    Context: Windows Server Setup Automation (NTFS, Shares, ACL)
.EXAMPLE
.\Prepare-DatevFolders.ps1
#>



# Bring Disk 1 online
$disk = Get-Disk -Number 1
Set-Disk -InputObject $disk -IsOffline $false | Out-Null



# Check if the disk is initialized
if ($disk.PartitionStyle -eq 'RAW') {
    Initialize-Disk -Number 1 -PartitionStyle GPT | Out-Null # Initialize Disk for first use if 
}

# Create a new volume on Disk 1 and assign it as drive D:
#New-Volume -Disk $disk -FriendlyName "Daten" -DriveLetter D -FileSystem NTFS | Out-Null 

# Clear existing partitions and data on Disk 1
Get-Disk -Number 1 | Clear-Disk -RemoveData -Confirm:$false | Out-Null

# Initialize Disk for first use with GPT partition style
Initialize-Disk -Number 1 -PartitionStyle GPT | Out-Null

# Create a new partition that uses the full capacity of Disk 1
New-Partition -DiskNumber 1 -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Daten" -Confirm:$false | Out-Null


# Create DATEV-specific folder structure under D:\Freigaben\
New-Item -ItemType Directory -Path "D:\Freigaben\WINDVSW1\" -Name "CONFIGDB" | Out-Null
New-Item -ItemType Directory -Path "D:\Freigaben\" -Name "Daten" | Out-Null
New-Item -ItemType Directory -Path "D:\Freigaben\" -Name "Scan" | Out-Null
New-Item -ItemType Directory -Path "D:\Freigaben\" -Name "GF" | Out-Null
