#Zum erstellen von .NET Klassen und damit zum erstellen von GUI Fenstern in Powershell muessen diese beiden Sachen eingebunden werden
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#Funktionen zum Erstellen und Anzeigen der GUI Fenster.
. .\UserInterfaceFunctions\UIFunctions.ps1
. .\FileHandling\FileHandlingFunctions.ps1
. .\VMHandling\VmHandlingFunctions.ps1




#Ueberpruefen ob das Skript als Administrator ausgefuehrt wird

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $scriptPath = $MyInvocation.MyCommand.Path
    $scriptDir = Split-Path $scriptPath

    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoExit", "-Command", "cd `"$scriptDir`"; & `"$scriptPath`""
    exit
}


#Script-Variablen
$Daten = UserInterface #Speichert alle Eingaben in einem Array
if ($Daten -is [string]) { Write-Host $Daten; Exit }
$KundeSpeicherort = $Daten[0] #Speicherort der VM´s
$Kunde = $Daten[1] #Name des Kunden
$Global:KundeRDP = "$($Daten[1])-RDP" #Name der SessionCollection
$Global:DomainName = $Daten[2] #Name der Domäne
$Global:NetBIOSName = $Daten[3] #NetBIOS-Name 
$Global:OUName = $Daten[4] #$Name der OU des Kunden
$Global:DCIPAdress = $Daten[5]  #IP Adresse die der DC haben soll
$Global:FSIPAdress = $Daten[6]  #IP Adresse die der FS haben soll
$Global:TSIPAdress = $Daten[7]  #IP Adresse die der TS haben soll
$Global:DefaultGateway = $Daten[8]  #DefaultGateway fuer die Server [in der Regel die Firewall]
$LPWord = $Daten[9] #password for the local Administrator
$DPWord = $Daten[9]  #password for the domain Administrator
$Global:Dsrm = $Daten[10] #Passwort für den DSRM-Administrators
$Global:BSPW = $Daten[11] #Passwort des lokalen Admins (extra lokaler User angelegt durch unattend.xml für Windows)
$Global:ASPW = $Daten[12] #Passwort des Domain-Administrators (gleich wie das Passwort für den lokalen Benutzer)
$RamDc = $Daten[13] #Variable um den Ausgewaehlten RAM den VM´s zuzuweisen
$RamFs = $Daten[14] #Variable um den Ausgewaehlten RAM den VM´s zuzuweisen
$RamTs = $Daten[15] #Variable um den Ausgewaehlten RAM den VM´s zuzuweisen
$SwitchSelected = $Daten[16] #Variable zum speichern der Netzwerkschnittstelle der VMs
$DateienSpeicherort = $Daten[17] #Speicherort der vorbereiteten Datein


#Pfad der WindowsServer VHDX
$DC_VHDX_Path = "$($KundeSpeicherort)\$($Kunde)\DC\Serverprep.vhdx"
$FS_VHDX_Path = "$($KundeSpeicherort)\$($Kunde)\FS\Serverprep.vhdx"
$TS_VHDX_Path = "$($KundeSpeicherort)\$($Kunde)\TS\Serverprep.vhdx"

#Namen der VM´s
$VM_Name_DC = "$($Kunde)-DC" #Name der VM - DC
$VM_Name_FS = "$($Kunde)-FS" #Name der VM - FS
$VM_Name_TS = "$($Kunde)-TS" #Name der VM - TS

#Variable fuer die Schnittstelle um das Kopieren zwischen Host und VM zu ermoeglichen
$CopyService = "Gastdienstschnittstelle" 

#String manipulation to setup the correct strings for the domain part of the script
$DomainNameSplit = $DomainName -split "\." #Aufteilung des Domain namen in eintelteile
$Global:DomainForGPO = "DC=$($DomainNameSplit[0]),DC=$($DomainNameSplit[1])" #Zusammensetzen zu einem Distinguished Name
$Global:OUPathname = "OU=" + $OUName + "," + $DomainForGPO #Distinguished Name für die OU


#Login für die Remote-Session des lokalen Administrators
$LUser = "Administrator"
$LPWord = $Daten[9] 
$LCredentialParams = @{
    TypeName     = "System.Management.Automation.PSCredential"
    ArgumentList = $LUser, $LPWord
}
$LCredential = New-Object @LCredentialParams

#Login für die Remote-Session des Donmain Administrators
$DUser = "$($NetBIOSName)\Administrator"
$DPWord = $Daten[9] 
$DCredentialParams = @{
    TypeName     = "System.Management.Automation.PSCredential"
    ArgumentList = $DUser, $DPWord
}
$DCredential = New-Object @DCredentialParams

<#hashtables mit Daten für die VM´s#>

#Fuer den DomainController
$DC = @{
    Name       = $VM_Name_DC
    #MemoryStartupBytes = $RamSelected
    Generation = 2
    VHDPath    = $DC_VHDX_Path
    Path       = "$($KundeSpeicherort)\$Kunde\DC"
    SwitchName = $SwitchSelected
}
#Fuer den Fileserver
$FS = @{
    Name       = $VM_Name_FS
    #MemoryStartupBytes = $RamSelected
    Generation = 2
    VHDPath    = $FS_VHDX_Path
    Path       = "$($KundeSpeicherort)\$($Kunde)\FS"
    SwitchName = $SwitchSelected
}
#Fuer den Terminalserver
$TS = @{
    Name       = $VM_Name_TS
    #MemoryStartupBytes = $RamSelected
    Generation = 2
    VHDPath    = $TS_VHDX_Path
    Path       = "$($KundeSpeicherort)\$($Kunde)\TS"
    SwitchName = $SwitchSelected
}

#Log Handling
$LogFilePath = "$($KundeSpeicherort)\$($Kunde)\ErrorLog.txt"
#How to write to LogFile
#Write-Output "$(Get-TimeStamp) -- Message" | Out-File $LogFilePath -append

<#Functions to Handle small things about VMs#>

#Funktion um einen Zeitstempel zu erstellen z.B. für Logs
function Get-TimeStamp {
    return "[{0:dd/MM/yy} {0:HH:mm:ss}]" -f (Get-Date)
}

#Erstellen der VM´s
function CreateVMs {
    New-VM @DC | Out-Null
    New-VM @FS | Out-Null
    New-VM @TS | Out-Null
    
    #Erstellen und hinzufuegen einer neuen virtuellen Festplatte fuer den FS
    #Laufwerk an VM fuer FS Haengen (G:Daten [500MB])
    New-VHD -Fixed -Path "$($KundeSpeicherort)\$($Kunde)\FS\fs.vhdx" -SizeBytes 10MB | Out-Null
    Add-VMHardDiskDrive -VMName $VM_Name_FS  -Path "$($KundeSpeicherort)\$($Kunde)\FS\fs.vhdx" 
}
#Löschen der VM´s
function DeleteVMs {
    Remove-VM -Name $VM_Name_DC -Force
    Remove-VM -Name $VM_Name_FS -Force
    Remove-VM -Name $VM_Name_TS -Force
}

function StartVMs {   
    Start-VM -Name $VM_Name_DC -AsJob | Out-Null
    Start-VM -Name $VM_Name_FS -AsJob | Out-Null
    Start-VM -Name $VM_Name_TS -AsJob | Out-Null
    Get-Job | Wait-Job | Out-Null
    Get-Job | Where-Object State -like 'Completed' | Remove-Job | Out-Null

}
#Stoppen der VM´s
function StopVMs {

    Stop-VM -Name $VM_Name_DC -AsJob | Out-Null
    Stop-VM -Name $VM_Name_FS -AsJob | Out-Null
    Stop-VM -Name $VM_Name_TS -AsJob | Out-Null
    Get-Job | Wait-Job | Out-Null
    Get-Job | Where-Object State -like 'Completed' | Remove-Job | Out-Null
}
#Neustarten der VMs
function RestartVMs {
    Restart-VM -Name $VM_Name_DC -AsJob -Force | Out-Null
    Restart-VM -Name $VM_Name_FS -AsJob -Force | Out-Null
    Restart-VM -Name $VM_Name_TS -AsJob -Force | Out-Null
    Get-Job | Wait-Job | Out-Null
    Get-Job | Where-Object State -like 'Completed' | Remove-Job | Out-Null

}


############################################################
#Main (Aufrufen von Funktionen und Abarbeitung des Scripts)#
############################################################

#FirmName #get input from the user about the firm name
#DomainValueUI #get input from the user for important domain values
#SwitchSelectorUI #let the user decide which networkswitch the vms use
#RamSelectorUI #let the user decied how much ram the vms use
#ServerIPAdressUI #get input from the user about the ip-addresses the vms should use
#SelectDirUI #let the user select the directory to store the vms
#PasswordUI #let the user input the password used by the script
#UserInterface #userinterface to combine all of the above functions
#$Daten

#Erstellen des Ordners fuer die Vms des Kunden
CreateCustomerDir -KundeSpeicherort $KundeSpeicherort -KundenName $Kunde -DateienSpeicherort $DateienSpeicherort 
Write-Output "$(Get-TimeStamp) -- Skript nach dem Erstellen der Ordnerstruktur und Kopieren der vhdx" | Out-File $LogFilePath -append

#Erstelln der VMs
CreateVMs
Write-Output "$(Get-TimeStamp) -- VMs erstellt" | Out-File $LogFilePath -append

#Bearbeiten der Anzahl der virtuellen Prozessoren und des Arbeitsspeichers
UpdateVMRessources -DC $VM_Name_DC -FS $VM_Name_FS -TS $VM_Name_TS -CoreDc $CoreDc -CoreFs $CoreFs -CoreTs $CoreTs -RamDc $RamDc -RamFs $RamFs -RamTs $RamTs

Write-Output "$(Get-TimeStamp) -- VM Ressourcen angepasst" | Out-File $LogFilePath -append


#Starten der VMs
StartVMs

Write-Output "$(Get-TimeStamp) -- VMs gestartet" | Out-File $LogFilePath -append


Start-Sleep -Seconds 240 #4min warten damit Server online sind
###########################


Write-Output "$(Get-TimeStamp) -- Windows Initialisierung fertig" | Out-File $LogFilePath -append

#Kopieren der wichtigsten Dateien auf den Servern
CopyFiles -Schnittstelle $CopyService -DC $VM_Name_DC -FS $VM_Name_FS -TS $VM_Name_TS -Dateienspeicherort $DateienSpeicherort -Credential $LCredential
Write-Output "$(Get-TimeStamp) -- Kopieren der Dateien fertig" | Out-File $LogFilePath -append

#Loeschen der Antwortdatei zum ueberspringen von Windows einrichtungspunkten | Löschen der unattend.xml
DeleteFiles -DC $VM_Name_DC -FS $VM_Name_FS -TS $VM_Name_TS -Credential $LCredential
Write-Output "$(Get-TimeStamp) -- Löschen Sicherheitsrelevanter Dateien fertig" | Out-File $LogFilePath -append
