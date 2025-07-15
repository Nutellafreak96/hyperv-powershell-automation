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
