#Funktion um einen Zeitstempel zu erstellen z.B. für Logs
function Get-TimeStamp {
    return "[{0:dd/MM/yy} {0:HH:mm:ss}]" -f (Get-Date)
}

<#
.SYNOPSIS
Creates directories for a customer's virtual machines and copies the prepared VHDX files.

.DESCRIPTION
This function creates a folder structure (DC, FS, TS) for a given customer at a specified storage location.
It also copies a prepared VHDX image into each subfolder and creates a log file for tracking errors.

.PARAMETER CustomerPath
The base directory where the customer's folders should be created.

.PARAMETER CustomerName
The name of the customer; used as the subdirectory name.

.PARAMETER SourcePath
The location of the prepared VHDX files to be copied.

.EXAMPLE
CreateCustomerDirectory -CustomerPath "D:\VMs" -CustomerName "Contoso" -SourcePath "C:\Images"
#>
function CreateCustomerDirectory {
    param(
        [string]$CustomerPath,
        [string]$CustomerName,
        [string]$SourcePath,
        [string]$Path
    )


    # Check if directory already exists and remove it
    if (Test-Path "$($CustomerPath)\$($CustomerName)") {
        Remove-Item -Path "$($CustomerPath)\$($CustomerName)" -Force -Recurse
    }

    # Create folders for the customer
    New-Item -Name "DC" -Path "$($CustomerPath)\$($CustomerName)" -ItemType Directory | Out-Null
    New-Item -Name "FS" -Path "$($CustomerPath)\$($CustomerName)" -ItemType Directory | Out-Null
    New-Item -Name "TS" -Path "$($CustomerPath)\$($CustomerName)" -ItemType Directory | Out-Null

    # Create the error log file
    New-Item -Name "LOG_File.txt" -Path "$($CustomerPath)\$($CustomerName)" -ItemType File | Out-Null

    Write-Output "$(Get-TimeStamp) -- Skript startet mit dem kopieren der VHD(X)" | Out-File $Path -append

    # Copy the prepared VHDX files to the customer directories
    Copy-Item -Path "$($SourcePath)\Serverprep.vhdx" -Destination "$($CustomerPath)\$($CustomerName)\DC\Serverprep.vhdx"
    Copy-Item -Path "$($SourcePath)\Serverprep.vhdx" -Destination "$($CustomerPath)\$($CustomerName)\FS\Serverprep.vhdx"
    Copy-Item -Path "$($SourcePath)\Serverprep.vhdx" -Destination "$($CustomerPath)\$($CustomerName)\TS\Serverprep.vhdx"
}


<#
.SYNOPSIS
Enables VM guest services and copies configuration files into customer VMs.

.DESCRIPTION
Activates the "Guest Services" integration component on Hyper-V VMs and creates a temp directory on each VM.
It then copies necessary deployment files from the host system to each VM using `Copy-VMFile` and PowerShell remoting.

.PARAMETER IntegrationServiceName
The name of the integration service (e.g. "Guest Service Interface").

.PARAMETER VmDc
Name of the Domain Controller VM.

.PARAMETER VmFs
Name of the File Server VM.

.PARAMETER VmTs
Name of the Terminal Server VM.

.PARAMETER SourcePath
Directory path on the host where configuration files are stored.

.PARAMETER Credential
Admin Credentials used to access the guest VMs via PowerShell remoting.

.EXAMPLE
CopyFilesToVMs -IntegrationServiceName "Guest Service Interface" -VmDc "DC01" -VmFs "FS01" -VmTs "TS01" -SourcePath "C:\Deploy" -Credential $cred
#>
function CopyFilesToVMs {
    param(
        [string]$IntegrationServiceName,
        [string]$VmDc,
        [string]$VmFs,
        [string]$VmTs,
        [string]$SourcePath,
        [psCredential]$Credential
    )

    # Enable file copy integration service on each VM
    Enable-VMIntegrationService -VMName $VmDc -Name $IntegrationServiceName
    Enable-VMIntegrationService -VMName $VmFs -Name $IntegrationServiceName
    Enable-VMIntegrationService -VMName $VmTs -Name $IntegrationServiceName


    # Create "temp" folder in each VM
    Invoke-Command -VMName $VmDc -ScriptBlock { New-Item -Path "C:\" -ItemType Directory -Name "temp" | Out-Null } -Credential $Credential
    Invoke-Command -VMName $VmFs -ScriptBlock { New-Item -Path "C:\" -ItemType Directory -Name "temp" | Out-Null } -Credential $Credential
    Invoke-Command -VMName $VmTs -ScriptBlock { New-Item -Path "C:\" -ItemType Directory -Name "temp" | Out-Null } -Credential $Credential

    # Copy configuration files to the appropriate VMs
    Copy-VMFile -DestinationPath "C:\temp\FileServerConfig.xml" -FileSource Host -VMName $VmFs -SourcePath "$($SourcePath)\InstallationFiles\ServerRole\Bereitstellungskonfiguration.xml" -CreateFullPath | Out-Null
    Copy-VMFile -DestinationPath "C:\temp\DefaultApps.xml" -FileSource Host -VMName $VmDc -SourcePath "$($SourcePath)\InstallationFiles\GroupPolicies\chromedefault.xml" -CreateFullPath | Out-Null

    # Use a PowerShell session to copy a directory to the Domain Controller
    $dcSession = New-PSSession -VMName $VmDc -Credential $Credential
    Copy-Item -ToSession $dcSession -Destination "C:\temp\" -Path "$($SourcePath)\InstallationFiles\GroupPolicies\{812FABB7-FDB3-4A46-8E8D-85BD985BA327}" -Recurse
    Get-PSSession | Remove-PSSession
}


<#
.SYNOPSIS
Removes unattended installation files from Windows VMs.

.DESCRIPTION
Deletes all unattend.xml-related files from the `Sysprep` directory on Domain Controller, File Server, and Terminal Server VMs
to prevent exposure of sensitive administrator information.

.PARAMETER VmDc
Name of the Domain Controller VM.

.PARAMETER VmFs
Name of the File Server VM.

.PARAMETER VmTs
Name of the Terminal Server VM.

.PARAMETER Credential
Admin Credentials for connecting to each VM.

.EXAMPLE
DeleteSensitiveFiles -VmDc "DC01" -VmFs "FS01" -VmTs "TS01" -Credential $cred
#>
function DeleteSensitiveFiles {
    param(
        [string]$VmDc,
        [string]$VmFs,
        [string]$VmTs,
        [psCredential]$Credential
    )

    Invoke-Command -VMName $VmDc -ScriptBlock { Remove-Item -Path "C:\Windows\System32\Sysprep\unattend.*" -Force } -Credential $Credential
    Invoke-Command -VMName $VmFs -ScriptBlock { Remove-Item -Path "C:\Windows\System32\Sysprep\unattend.*" -Force } -Credential $Credential
    Invoke-Command -VMName $VmTs -ScriptBlock { Remove-Item -Path "C:\Windows\System32\Sysprep\unattend.*" -Force } -Credential $Credential
}
