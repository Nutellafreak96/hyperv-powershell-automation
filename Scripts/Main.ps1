<#
.DESCRIPTION
Main script to handle variables and execute the scripts to automate the server structure creation
.NOTES
    Author: Kevin Hübner
    Language: PowerShell
    Context: Windows Server Setup Automation (NTFS, Shares, ACL)
#>

#Needed to create and visualize .NET windows
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#Scripts to handle specific parts of the automation
. .\UserInterfaceFunctions\UiFunctions.ps1
. .\FileHandling\FileHandlingFunctions.ps1
. .\VMHandling\VmHandlingFunctions.ps1





#Check if the scipt is executed via an administrator shell/cmd

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $scriptPath = $MyInvocation.MyCommand.Path
    $scriptDir = Split-Path $scriptPath

    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoExit", "-Command", "cd `"$scriptDir`"; & `"$scriptPath`""
    exit
}


#Script-Variables
$ErrorCount = 0                                                 #Error Count
$Daten = UserInterface                                          #Saved user input as Array
$VHDX = Get-VHDSizeBytes
if ($null -eq $VHDX) { Write-Host "Invalid VHDX-Size"; Exit }
if ($Daten -is [string]) { Write-Host $Daten; Exit }
$KundeSpeicherort = $Daten[0]                                   #Path of the VMs
$Kunde = $Daten[1]                                              #Client name
$Global:KundeRDP = "$($Daten[1])-RDP"                           #SessionCollection name
$Global:DomainName = $Daten[2]                                  #Domain name
$Global:NetBIOSName = $Daten[3]                                 #NetBIOS-Name 
$Global:OUName = $Daten[4]                                      #$Organizational Unit name
$Global:DCIPAdress = $Daten[5]                                  #Domain Controller IP Adress
$Global:FSIPAdress = $Daten[6]                                  #Fileserver IP Adress
$Global:TSIPAdress = $Daten[7]                                  #Terminalserver IP Adress
$Global:DefaultGateway = $Daten[8]                              #DefaultGateway 
$LPWord = $Daten[9]                                             #password for the local Administrator
$DPWord = $Daten[9]                                             #password for the domain Administrator
$Global:Dsrm = $Daten[10]                                       #DSRM password
$Global:BSPW = $Daten[11]                                       #Test-user password
$Global:ASPW = $Daten[12]                                       #Firm Admin-user password 
$RamDc = $Daten[13]                                             #RAM value DC
$RamFs = $Daten[14]                                             #RAM value FS
$RamTs = $Daten[15]                                             #RAM value TS
$SwitchSelected = $Daten[16]                                    #Networkswitch for VMs
$DateienSpeicherort = $Daten[17]                                #Path to prepared Files
$CoreDc = $Daten[18]                                            #CPU cores DC
$CoreFs = $Daten[19]                                            #CPU cores FS
$CoreTs = $Daten[20]                                            #CPU cores TS
$FQDN = "TS." + $DomainName                                     #FQDN TS

#Path of the WindowsServer VHDX
$DC_VHDX_Path = "$($KundeSpeicherort)\$($Kunde)\DC\Serverprep.vhdx"
$FS_VHDX_Path = "$($KundeSpeicherort)\$($Kunde)\FS\Serverprep.vhdx"
$TS_VHDX_Path = "$($KundeSpeicherort)\$($Kunde)\TS\Serverprep.vhdx"

#VM names
$VM_Name_DC = "$($Kunde)-DC" 
$VM_Name_FS = "$($Kunde)-FS" 
$VM_Name_TS = "$($Kunde)-TS" 

# Integration Services component name
$CopyService = "Gastdienstschnittstelle" 

#String manipulation to setup the correct strings for the domain part of the script
$DomainNameSplit = $DomainName -split "\." 
$Global:DomainForGPO = ($DomainNameSplit | ForEach-Object { "DC=$_" }) -join "," 
$Global:OUPathname = "OU=" + $OUName + "," + $DomainForGPO 


#Credentials of local Administrator
$LUser = "Administrator"
$LPWord = $Daten[9] 
$LCredentialParams = @{
    TypeName     = "System.Management.Automation.PSCredential"
    ArgumentList = $LUser, $LPWord
}
$LCredential = New-Object @LCredentialParams

#Credentials of domain Administrator
$DUser = "$($NetBIOSName)\Administrator"
$DPWord = $Daten[9] 
$DCredentialParams = @{
    TypeName     = "System.Management.Automation.PSCredential"
    ArgumentList = $DUser, $DPWord
}
$DCredential = New-Object @DCredentialParams


<#Hashtables for VM creation#>

#DomainController
$DC = @{
    Name       = $VM_Name_DC
    Generation = 2
    VHDPath    = $DC_VHDX_Path
    Path       = "$($KundeSpeicherort)\$Kunde\DC"
    SwitchName = $SwitchSelected
}
#Fileserver
$FS = @{
    Name       = $VM_Name_FS
    Generation = 2
    VHDPath    = $FS_VHDX_Path
    Path       = "$($KundeSpeicherort)\$($Kunde)\FS"
    SwitchName = $SwitchSelected
}
#Terminalserver
$TS = @{
    Name       = $VM_Name_TS
    Generation = 2
    VHDPath    = $TS_VHDX_Path
    Path       = "$($KundeSpeicherort)\$($Kunde)\TS"
    SwitchName = $SwitchSelected
}

#Log Handling
$LogFilePath = "$($KundeSpeicherort)\$($Kunde)\LOG_File.txt"


<#Functions to Handle small things about VMs#>

#VM creation via hashtables
function CreateVMs {
    New-VM @DC | Out-Null
    New-VM @FS | Out-Null
    New-VM @TS | Out-Null
    
    #create and attach vhd(x) to fileserver vm
    
    New-VHD -Fixed -Path "$($KundeSpeicherort)\$($Kunde)\FS\fs.vhdx" -SizeBytes $VHDX | Out-Null
    Add-VMHardDiskDrive -VMName $VM_Name_FS  -Path "$($KundeSpeicherort)\$($Kunde)\FS\fs.vhdx" 
}
#Delete VMs
function DeleteVMs {
    Remove-VM -Name $VM_Name_DC -Force
    Remove-VM -Name $VM_Name_FS -Force
    Remove-VM -Name $VM_Name_TS -Force
}
#Start VMs
function StartVMs {   
    Start-VM -Name $VM_Name_DC -AsJob | Out-Null
    Start-VM -Name $VM_Name_FS -AsJob | Out-Null
    Start-VM -Name $VM_Name_TS -AsJob | Out-Null
    Get-Job | Wait-Job | Out-Null
    Get-Job | Where-Object State -like 'Completed' | Remove-Job | Out-Null

}
#Stop VMs
function StopVMs {

    Stop-VM -Name $VM_Name_DC -AsJob | Out-Null
    Stop-VM -Name $VM_Name_FS -AsJob | Out-Null
    Stop-VM -Name $VM_Name_TS -AsJob | Out-Null
    Get-Job | Wait-Job | Out-Null
    Get-Job | Where-Object State -like 'Completed' | Remove-Job | Out-Null
}
#Restart VMs
function RestartVMs {
    Restart-VM -Name $VM_Name_DC -AsJob -Force | Out-Null
    Restart-VM -Name $VM_Name_FS -AsJob -Force | Out-Null
    Restart-VM -Name $VM_Name_TS -AsJob -Force | Out-Null
    Get-Job | Wait-Job | Out-Null
    Get-Job | Where-Object State -like 'Completed' | Remove-Job | Out-Null

}

#Install ActiveDiretoryDomainService Role
function DeployADDSRole {
    Invoke-Command -VMName $VM_Name_DC -FilePath ".\DeployDomainControlerRole.ps1" -Credential $LCredential
}

#Join the Domain 

function JoinDomain {
    Invoke-Command -VMName $VM_Name_FS -ScriptBlock { Add-Computer -DomainName $Using:DomainName -Credential $Using:DCredential -Restart } -Credential $LCredential
    Invoke-Command -VMName $VM_Name_TS -ScriptBlock { Add-Computer -DomainName $using:DomainName -Credential $Using:DCredential -Restart } -Credential $LCredential
}



#Create directory structure on the Fileserver
function DirectoryPreparation {
    Invoke-Command -VMName $VM_Name_FS -FilePath ".\FileHandling\DirectoryPreparations.ps1" -Credential $DCredential
}

#Create basic AD structure
function BasicADStructure {
    Invoke-Command -VMName $VM_Name_DC -FilePath ".\ActiveDirectoryHandling\OrganizationalUnitStructure.ps1" -Credential $DCredential 
    Invoke-Command -VMName $VM_Name_DC -FilePath ".\ActiveDirectoryHandling\ADUserGroups.ps1" -Credential $DCredential 
    Invoke-Command -VMName $VM_Name_DC -FilePath ".\ActiveDirectoryHandling\RegistryGroupPolicies.ps1" -Credential $DCredential 
    Invoke-Command -VMName $VM_Name_DC -ScriptBlock { Move-Item -Path "C:\temp\DefaultApps.xml" -Destination "C:\Windows\SYSVOL\domain\scripts" } -Credential $DCredential 
}

#Set User permissions for directorys
function DirPermissions {
    Invoke-Command -VMName $VM_Name_FS -FilePath ".\FileHandling\Permissions.ps1" -Credential $DCredential
}

#Install and configure RemoteDesktop roles
function DeployTSRole {
    param(
        [string]$DC,
        [string]$TS,
        [string]$RdpName,
        [pscredential]$Credential,
        [string]$FQDN,
        [string]$Path
    )
    
    $TsSession1 = New-PSSession -VMName $TS -Credential $Credential
    
    
    #Wait until VM is ready initially
    #Wait-ForVM -VMName $TS -Credential $Credential 

    #Install RDS roles with automatic reboot
    Invoke-Command -Session $TsSession1 -FilePath ".\DeployRemoteDesktopServices.ps1" 
    Get-PSSession | Remove-PSSession

    #Wait again after reboot
    
    Start-Sleep -Seconds 150

    #Configure RDS deployment
    #Invoke-Command -VMName $TS -FilePath ".\ConfigureRemoteDesktopDeployment.ps1" -Credential $Credential
    $TsSession2 = New-PSSession -VMName $TS -Credential $Credential
    if ($null -eq $TsSession2) { $TsSession2 = New-PSSession -VMName $TS -Credential $Credential }
    Invoke-Command -Session $TsSession2 -FilePath ".\ConfigureRemoteDesktopDeployment.ps1" -ArgumentList $KundeRDP, $DomainName
    Invoke-Command -Session $TsSession2 -ScriptBlock { Restart-Computer -Force }

    

    Wait-ForVM -VMName $TS -Credential $Credential -MaxRetries 6 -WaitSeconds 10 -Path $Path


    Get-PSSession | Remove-PSSession
}

#Change passwords of the local admini
function ChangeAdminPasswords {
    param(
        [string]$LAdminDc,   # Plain text Local Admin password (DC)
        [string]$LAdminFs,   # Plain text Local Admin password (FS)
        [string]$LAdminTs,   # Plain text Local Admin password (TS)
        [string]$DC,
        [string]$FS,
        [string]$TS,
        [pscredential]$Credential
    )

    # File Server local admin password
    Invoke-Command -VMName $FS -Credential $Credential -ScriptBlock {
        param($pw)
        $secPw = ConvertTo-SecureString $pw -AsPlainText -Force
        Get-LocalUser -Name "Admin" | Set-LocalUser -Password $secPw
    } -ArgumentList $LAdminFs

    # Terminal Server local admin password
    Invoke-Command -VMName $TS -Credential $Credential -ScriptBlock {
        param($pw)
        $secPw = ConvertTo-SecureString $pw -AsPlainText -Force
        Get-LocalUser -Name "Admin" | Set-LocalUser -Password $secPw
    } -ArgumentList $LAdminTs

    # Domain Controller: local admin password
    Invoke-Command -VMName $DC -Credential $Credential -ScriptBlock {
        param($localPw, $domainPw)

        $localSec = ConvertTo-SecureString $localPw -AsPlainText -Force
        Get-LocalUser -Name "Admin" | Set-LocalUser -Password $localSec

    } -ArgumentList $LAdminDc

}


############################################################
#Main (Aufrufen von Funktionen und Abarbeitung des Scripts)#
############################################################



CreateCustomerDirectory  -CustomerPath $KundeSpeicherort -CustomerName $Kunde -SourcePath $DateienSpeicherort  -Path $LogFilePath 
Write-Output "$(Get-TimeStamp) -- Skript nach dem Erstellen der Ordnerstruktur und Kopieren der vhdx" | Out-File $LogFilePath -append


CreateVMs
Write-Output "$(Get-TimeStamp) -- VMs erstellt" | Out-File $LogFilePath -append


UpdateVMResources -VmDc $VM_Name_DC -VmFs $VM_Name_FS -VmTs $VM_Name_TS -CoreDc $CoreDc -CoreFs $CoreFs -CoreTs $CoreTs -RamDc $RamDc -RamFs $RamFs -RamTs $RamTs

Write-Output "$(Get-TimeStamp) -- VM Ressourcen angepasst" | Out-File $LogFilePath -append



StartVMs

Write-Output "$(Get-TimeStamp) -- VMs gestartet" | Out-File $LogFilePath -append



Wait-ForVM -VMName $VM_Name_DC -Credential $LCredential -MaxRetries 100 -WaitSeconds 10 -Path $LogFilePath 



Write-Output "$(Get-TimeStamp) -- Windows Initialisierung fertig" | Out-File $LogFilePath -append


CopyFilesToVMs -IntegrationServiceName $CopyService -VmDc $VM_Name_DC  -VmFs $VM_Name_FS -VmTs $VM_Name_TS  -SourcePath $DateienSpeicherort -Credential $LCredential
Write-Output "$(Get-TimeStamp) -- Kopieren der Dateien fertig" | Out-File $LogFilePath -append


DeleteSensitiveFiles -VmDc $VM_Name_DC -VmFs $VM_Name_FS -VmTs $VM_Name_TS -Credential $LCredential
Write-Output "$(Get-TimeStamp) -- Löschen Sicherheitsrelevanter Dateien fertig" | Out-File $LogFilePath -append



StopVMs
$DcState = (Get-VM -Name $VM_Name_DC).State
$FsState = (Get-VM -Name $VM_Name_FS).State
$TsState = (Get-VM -Name $VM_Name_TS).State
while ( ($DcState -ne "off") -or ($FsState -ne "off") -or ($TsState -ne "off") ) {
    Start-Sleep -Seconds 1
    Write-Output "$(Get-TimeStamp) -- Loop1 DC:$($DcState) FS:$($FsState) TS:$($TsState)" | Out-File $LogFilePath -append
    $DcState = (Get-VM -Name $VM_Name_DC).State
    $FsState = (Get-VM -Name $VM_Name_FS).State
    $TsState = (Get-VM -Name $VM_Name_TS).State
}
Write-Output "$(Get-TimeStamp) -- VMs gestoppt" | Out-File $LogFilePath -append



ChangeMacAddress -VmDC $VM_Name_DC -VmFs $VM_Name_FS -VmTs $VM_Name_TS
Write-Output "$(Get-TimeStamp) -- MAC Addressen der VMs auf statisch umgestellt" | Out-File $LogFilePath -append


StartVMs
Start-Sleep -Seconds 10
Write-Output "$(Get-TimeStamp) -- VMs erneut gestartet" | Out-File $LogFilePath -append

while ( ($DcState -eq "off") -or ($FsState -eq "off") -or ($TsState -eq "off") ) {
    Start-Sleep -Seconds 1
    Write-Output "$(Get-TimeStamp) -- Loop2 DC:$($DcState) FS:$($FsState) TS:$($TsState)" | Out-File $LogFilePath -append
    $DcState = (Get-VM -Name $VM_Name_DC).State
    $FsState = (Get-VM -Name $VM_Name_FS).State
    $TsState = (Get-VM -Name $VM_Name_TS).State
}

Wait-ForVM -VMName $VM_Name_DC -Credential $LCredential -MaxRetries 20 -WaitSeconds 10 -Path $LogFilePath 

ChangeVMSettings -VmDC $VM_Name_DC -VmFs $VM_Name_FS -VmTs $VM_Name_TS -Credential $LCredential
Write-Output "$(Get-TimeStamp) -- VMs haben eine feste IP erhalten und der virtuelle Computer bekommt einen neuen Namen | FS Rolle installiert" | Out-File $LogFilePath -append


Wait-ForVM -VMName $VM_Name_DC -Credential $LCredential -MaxRetries 20 -WaitSeconds 10 -Path $LogFilePath 

 
DeployADDSRole
Write-Output "$(Get-TimeStamp) -- DC wurde erstellt" | Out-File $LogFilePath -append

Start-Sleep -Seconds 390 #6,5min warten auf Server neustart



JoinDomain
Write-Output "$(Get-TimeStamp) -- VMs treten der Domain bei" | Out-File $LogFilePath -append


Wait-ForVM -VMName $VM_Name_FS -Credential $DCredential -MaxRetries 60 -WaitSeconds 10 -Path $LogFilePath  


DirectoryPreparation


Write-Output "$(Get-TimeStamp) -- Ordnerstruktur auf der neuen Festplatte am FS erstellt" | Out-File $LogFilePath -append


BasicADStructure
Write-Output "$(Get-TimeStamp) -- OU,User,Gruppen,GPO erstellt " | Out-File $LogFilePath -append
Wait-ForVM -VMName $VM_Name_DC -Credential $DCredential -MaxRetries 60 -WaitSeconds 10 -Path $LogFilePath  




DirPermissions
Write-Output "$(Get-TimeStamp) -- Ordner Freigaben erstellt und NTFS Rechte bearbeitet" | Out-File $LogFilePath -append


DeployTSRole -DC $VM_Name_DC -TS $VM_Name_TS -RdpName $KundeRDP -Credential $DCredential -FQDN $FQDN -Path $LogFilePath
Write-Output "$(Get-TimeStamp) -- TS Rolle installiert und eingerichtet" | Out-File $LogFilePath -append



$PArray = PasswordChange

ChangeAdminPasswords -LAdminDc $PArray[0] -LAdminFs $PArray[1] -LAdminTs $PArray[2] -DC $VM_Name_DC -FS $VM_Name_FS -TS $VM_Name_TS -Credential $DCredential
Write-Output "$(Get-TimeStamp) -- Script finished | Errors:$($ErrorCount)" | Out-File $LogFilePath -append 


RestartVMs
Write-Output "$(Get-TimeStamp) -- VMs neugestartet" | Out-File $LogFilePath -append