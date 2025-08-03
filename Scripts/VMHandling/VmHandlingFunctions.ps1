<#
.SYNOPSIS
Updates CPU and memory resources of the specified VMs.

.DESCRIPTION
Modifies the number of virtual processors and sets the startup memory for each VM (Domain Controller, File Server, Terminal Server).

.PARAMETER VmDc
Name of the Domain Controller VM.

.PARAMETER VmFs
Name of the File Server VM.

.PARAMETER VmTs
Name of the Terminal Server VM.

.PARAMETER CoreDc
Number of CPU cores for the Domain Controller.

.PARAMETER CoreFs
Number of CPU cores for the File Server.

.PARAMETER CoreTs
Number of CPU cores for the Terminal Server.

.PARAMETER RamDc
RAM allocation (in bytes) for the Domain Controller.

.PARAMETER RamFs
RAM allocation (in bytes) for the File Server.

.PARAMETER RamTs
RAM allocation (in bytes) for the Terminal Server.
#>
function UpdateVMResources {
    param(
        [string]$VmDc,
        [string]$VmFs,
        [string]$VmTs,
        [Int]$CoreDc,
        [Int]$CoreFs,
        [Int]$CoreTs,
        [Int64]$RamDc,
        [Int64]$RamFs,
        [Int64]$RamTs
    )

    Set-VM -Name $VmDc -ProcessorCount $CoreDc -MemoryStartupBytes $RamDc | Out-Null
    Set-VM -Name $VmFs -ProcessorCount $CoreFs -MemoryStartupBytes $RamFs | Out-Null
    Set-VM -Name $VmTs -ProcessorCount $CoreTs -MemoryStartupBytes $RamTs | Out-Null
}

<#
.SYNOPSIS
Sets the MAC address of VMs to static values.

.DESCRIPTION
Reads the current dynamic MAC address of the VMs and reassigns them as static to preserve the address.

.PARAMETER VmDc
Name of the Domain Controller VM.

.PARAMETER VmFs
Name of the File Server VM.

.PARAMETER VmTs
Name of the Terminal Server VM.
#>
function ChangeMacAddress {
    param(
        [string]$VmDc,
        [string]$VmFs,
        [string]$VmTs
    )
    
    $DcMacAddress = Get-VM -Name $VmDc | Get-VMNetworkAdapter | Select-Object -ExpandProperty MacAddress
    $FsMacAddress = Get-VM -Name $VmFs | Get-VMNetworkAdapter | Select-Object -ExpandProperty MacAddress
    $TSsMacAddress = Get-VM -Name $VmTs | Get-VMNetworkAdapter | Select-Object -ExpandProperty MacAddress

    Set-VMNetworkAdapter -VMName $VmDc -StaticMacAddress $DcMacAddress
    Set-VMNetworkAdapter -VMName $VmFs -StaticMacAddress $FsMacAddress
    Set-VMNetworkAdapter -VMName $VmTs -StaticMacAddress $TSsMacAddress
}

<#
.SYNOPSIS
Changes IP addresses and hostnames of VMs, and installs the File Server role.

.DESCRIPTION
Runs PowerShell scripts inside each VM to configure static IP addresses, rename computers, and install the File Server feature on the FS VM.

.PARAMETER VmDc
Name of the Domain Controller VM.

.PARAMETER VmFs
Name of the File Server VM.

.PARAMETER VmTs
Name of the Terminal Server VM.

.PARAMETER Credential
Credentials used to execute the remote scripts in the VMs.
#>
function ChangeVMSettings {
    param(
        [string]$VmDc,
        [string]$VmFs,
        [string]$VmTs,
        [pscredential]$Credential
    )

    Invoke-Command -VMName $VmDc -FilePath ".\VMHandling\ChangeIpRenameDc.ps1" -Credential $Credential -AsJob | Out-Null
    Invoke-Command -VMName $VmFs -FilePath ".\DeployFileServerRole.ps1" -Credential $Credential -AsJob | Out-Null
    Invoke-Command -VMName $VmTs -FilePath ".\VMHandling\ChangeIpRenameTs.ps1" -Credential $Credential -AsJob | Out-Null
    
    Get-Job | Wait-Job | Out-Null
    Get-Job | Where-Object State -like 'Completed' | Remove-Job | Out-Null
}


<##>
function Wait-ForVM {
    param (
        [Parameter(Mandatory=$true)][string]$VMName,
        [Parameter(Mandatory=$true)][pscredential]$Credential,
        [int]$MaxRetries = 60,
        [int]$WaitSeconds = 10,
        [string]$Path
    )
    $retryCount = 0
    $vmReady = $false
    
    while (-not $vmReady -and $retryCount -lt $MaxRetries) {
        try {
            Invoke-Command -VMName $VMName -ScriptBlock { (Get-Service -Name "WSearch").Status } -Credential $Credential -ErrorAction Stop | Out-Null
            $vmReady = $true
        } catch {
            Write-Output "VM $($VMName) not ready... retrying ($($retryCount)/$($MaxRetries))" | Out-File $Path -Append
            Start-Sleep -Seconds $WaitSeconds
            $retryCount++
        }
    }

    if (-not $vmReady) {
        throw "VM $($VMName) did not become ready after $($MaxRetries) attempts."
    }
}