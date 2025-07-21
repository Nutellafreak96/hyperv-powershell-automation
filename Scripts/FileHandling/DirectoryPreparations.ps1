#Vorbereitung des FS für Datev und für die Freigabe von verschiedenen Ordnern, welche angelegt werden



Get-Disk -Number 1 | Set-Disk -IsOffline $false 
Get-Disk -Number 1 | New-Volume -FriendlyName "Daten" -DriveLetter D -FileSystem NTFS | Out-Null
New-Item -ItemType Directory -Path "D:\Freigaben\WINDVSW1\" -Name "CONFIGDB" | Out-Null
New-Item -ItemType Directory -Path "D:\Freigaben\" -Name "Daten" | Out-Null
New-Item -ItemType Directory -Path "D:\Freigaben\" -Name "Scan" | Out-Null
New-Item -ItemType Directory -Path "D:\Freigaben\" -Name "GF" | Out-Null




