

#Erstellen des Ordners für die VM´s des Kunden und kopieren der vorbereiteten VHDX
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

