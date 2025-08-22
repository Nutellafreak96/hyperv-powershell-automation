Dieses Repository enthält alle relevanten Skripte und Ressourcen zu meiner Bachelorarbeit mit dem Titel:

**"Skriptgesteuerte Erstellung und Konfiguration von Windows-basierten virtuellen Maschinen in Hyper-V mittels PowerShell"**

Ziel der Arbeit ist die automatisierte Bereitstellung, Konfiguration und Rollenzuweisung von Windows-Server-basierten virtuellen Maschinen unter Verwendung von PowerShell und Hyper-V.

---

## Projektstruktur
```
.
├── Scripts/ # PowerShell-Skripte für Automatisierung und Rollenbereitstellung
│ ├── ActiveDirectoryHandling/ # Funktionen zum AD-Handling
│ ├── FileHandling/ # Dateioperationen und -verwaltung
│ ├── UserInterfaceFunctions/ # Konsolenmenü und UI-Funktionen
│ ├── VMHandling/ # Erstellung und Konfiguration von VMs
│ ├── ConfigureRemoteDesktopDeployment.ps1
│ ├── DeployDomainControlerRole.ps1
│ ├── DeployFileServerRole.ps1
│ ├── DeployRemoteDesktopServices.ps1
│ └── Main.ps1 # Hauptskript zum Ausführen des Prozesses
│
├── ServerPreparations/ # Vorbereitungsdateien für die Serverbereitstellung
│ ├── InstallationFiles/ # Weitere benötigte Installationsdateien
│ └── ... (z. B. VHDX-Template) # Template für die VM-Erstellung
│
├── Thesis/ # Inhalte der Bachelorarbeit
│ ├── bilder/ # Abbildungen
│ ├── thesis.pdf # Finales PDF-Dokument
│ ├── thesis.tex # LaTeX-Datei
│ └── references.bib # BibTeX-Datei
│
└── .gitignore # Ausgeschlossene Dateien und Ordner
.gitignore – Ausgeschlossene Dateien und Ordner
```
---
## Ausführen des Hauptskripts

Um die automatisierte Erstellung und Konfiguration zu starten, rufe folgendes Skript aus einer PowerShell-Konsole mit administrativen Rechten auf:

```
C:\hyperv-powershell-automation\Scripts\Main.ps1
```

Stelle sicher, dass alle Abhängigkeiten korrekt platziert und Hyper-V sowie PowerShell aktiviert und entsprechend konfiguriert sind.

---

## Voraussetzungen

- Windows Server | Windows 10 Pro  oder höher mit aktiviertem Hyper-V

- PowerShell 5.1 oder höher

- Administratorrechte für die Ausführung der Skripte

- ISO-/VHDX-Dateien für die Betriebssysteminstallation

---

## Autor

Kevin Hübner

Bachelorarbeit an der Hochschule für Technik und Wirtschaft Berlin, HTW Berlin, Fachbereich Computer Engineering
