<#Create Directorys for the Firm VMs and copy the prepared VHDX#>
function CreateCustomerDir {

    param(
        [string]$KundeSpeicherort,
        [string]$KundenName,
        [string]$DateienSpeicherort
    )
    Write-Host $KundeSpeicherort
    Write-host $KundenName
    Write-Host $DateienSpeicherort

    #Ueberpruefen ob Directory schon vorhanden ist
    if (Test-Path "$($KundeSpeicherort)\$($KundenName)") { Remove-Item -Path "$($KundeSpeicherort)\$($KundenName)" -Force -Recurse }
    

    

    #Erstellen der Ordner fuer den Kunden
    New-Item -Name "DC" -Path "$($KundeSpeicherort)\$($KundenName)" -ItemType Directory | Out-Null
    New-Item -Name "FS" -Path "$($KundeSpeicherort)\$($KundenName)" -ItemType Directory | Out-Null
    New-Item -Name "TS" -Path "$($KundeSpeicherort)\$($KundenName)" -ItemType Directory | Out-Null

    #Erstellen des Log-Files
    New-Item -Name "ErrorLog.txt" -Path "$($KundeSpeicherort)\$($KundenName)" -ItemType File | Out-Null


    #Verteilen der vorbereiteten VHDX f�r die VM�s
    #Write-Progress zum Anzeigen des fortschrittes einbauen
    Copy-Item -Path "$($DateienSpeicherort)\Serverprep.vhdx" -Destination "$($KundeSpeicherort)\$($KundenName)\DC\Serverprep.vhdx"
    Copy-Item -Path "$($DateienSpeicherort)\Serverprep.vhdx" -Destination "$($KundeSpeicherort)\$($KundenName)\FS\Serverprep.vhdx"
    Copy-Item -Path "$($DateienSpeicherort)\Serverprep.vhdx" -Destination "$($KundeSpeicherort)\$($KundenName)\TS\Serverprep.vhdx" 



}
<#Enable Copy Service on VMs and Create Directory on VMs to copy necessary files to it#>
function CopyFiles {
    param(
        [String]$Schnittstelle,
        [string]$DC,
        [string]$FS,
        [String]$TS,
        [string]$DateienSpeicherort,
        [pscredential]$Credential
    )
    #Aktivieren der Möglichkeit dateien vom Host in eine VM zu Kopieren
    Enable-VMIntegrationService -VMName $DC -Name $Schnittstelle
    Enable-VMIntegrationService -VMName $FS -Name $Schnittstelle
    Enable-VMIntegrationService -VMName $TS -Name $Schnittstelle

    #Erstellen eines temp Ordners in den Vms
    Invoke-Command -VMName $DC -ScriptBlock { New-Item -Path "C:\" -ItemType Directory -Name "temp" | Out-Null } -Credential $Credential
    Invoke-Command -VMName $FS  -ScriptBlock { New-Item -Path "C:\" -ItemType Directory -Name "temp" | Out-Null } -Credential $Credential 
    Invoke-Command -VMName $TS  -ScriptBlock { New-Item -Path "C:\" -ItemType Directory -Name "temp" | Out-Null } -Credential $Credential 

    #Kopieren der Dateien in die richtige VM    
    Copy-VMFile -DestinationPath "C:\temp\Dateiserver.xml" -FileSource Host -VMName $FS -SourcePath "$($DateienSpeicherort)\Bereitstellungskonfiguration.xml" -CreateFullPath | Out-Null
    Copy-VMFile -DestinationPath "C:\temp\DefaultApps.xml" -FileSource Host -VMName $DC -SourcePath "$($DateienSpeicherort)\chromedefault.xml" -CreateFullPath | Out-Null
    
    #Nutzen einer Session zum DC um den Ordner kopieren zu können
    $DcS = New-PSSession -VMName $DC -Credential $Credential
    Copy-Item -ToSession $DcS -Destination "C:\temp\" -Path "$($DateienSpeicherort)\{812FABB7-FDB3-4A46-8E8D-85BD985BA327}" -Recurse
    Get-PSSession | Remove-PSSession
    
}

<#Delete the unattend files from the vm because they secure relevant information to the admin users on the systems#>
function DeleteFiles {
    param(
        [string]$DC,
        [string]$FS,
        [string]$TS,
        [pscredential]$Credential
    )

    Invoke-Command -VMName $DC -ScriptBlock { Remove-Item -Path "C:\Windows\System32\Sysprep\unattend.*" -Force } -Credential $Credential
    Invoke-Command -VMName $FS -ScriptBlock { Remove-Item -Path "C:\Windows\System32\Sysprep\unattend.*" -Force } -Credential $Credential
    Invoke-Command -VMName $TS -ScriptBlock { Remove-Item -Path "C:\Windows\System32\Sysprep\unattend.*" -Force } -Credential $Credential
}
