<#function to update the ressources of the vms#>
function UpdateVMRessources {
    param(
        [string]$DC,
        [string]$FS,
        [string]$TS,
        [Int16]$CoreDc,
        [Int16]$CoreFs,
        [Int16]$CoreTs,
        [Int64]$RamDc,
        [Int64]$RamFs,
        [Int64]$RamTs
    )
    #Bearbeiten der Anzahl der virtuellen Prozessoren
    Set-VM -Name $DC -ProcessorCount 4 -MemoryStartupBytes $RamDc | Out-Null
    Set-VM -Name $FS -ProcessorCount 4 -MemoryStartupBytes $RamFs| Out-Null
    Set-VM -Name $TS -ProcessorCount 4 -MemoryStartupBytes $RamTs | Out-Null
}
<#Set the MAC Address of the VM to static#>
function ChangeMacAddress {
    param(
        [string]$DC,
        [string]$FS,
        [string]$TS
    )
    
    #Die MacAddressen der Vms auslesen
    $DCMacAddress = Get-VM -Name $DC | Get-VMNetworkAdapter | Select-Object -ExpandProperty MacAddress
    $FSMacAddress = Get-VM -Name $FS | Get-VMNetworkAdapter | Select-Object -ExpandProperty MacAddress
    $TSMacAddress = Get-VM -Name $TS | Get-VMNetworkAdapter | Select-Object -ExpandProperty MacAddress

    #Den VMs statische MacAddressen geben
    Set-VMNetworkAdapter -VMName $DC -StaticMacAddress $DCMacAddress
    Set-VMNetworkAdapter -VMName $FS -StaticMacAddress $FSMacAddress
    Set-VMNetworkAdapter -VMName $TS -StaticMacAddress $TSMacAddress
}

<#Change the IP Addresses of the Windows Server on the VMs to static IP Adresses and install the Fileserver Featuer on the FS VM#>
function ChangeVMSettings {
    param(
        [string]$DC,
        [string]$FS,
        [string]$TS,
        [pscredential]$Credential
    )

    #Den VMs eine statische IP zuweisen, sowie den Computernamen aendern
    Invoke-Command -VMName $DC -FilePath ".\VMHandling\ChangeIP_rename_DC.ps1" -Credential $Credential -AsJob | Out-Null
    Invoke-Command -VMName $FS -FilePath ".\DeployFileServerRole.ps1" -Credential $Credential -AsJob | Out-Null
    Invoke-Command -VMName $TS -FilePath ".\VMHandling\ChangeIp_Rename_TS.ps1" -Credential $Credential -AsJob | Out-Null
    Get-Job | Wait-Job | Out-Null
    Get-Job | Where-Object State -like 'Completed' | Remove-Job | Out-Null
}
