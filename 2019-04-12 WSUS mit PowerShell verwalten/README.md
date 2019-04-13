# WSUS mit PowerShell verwalten

## Serververwaltung
 
### 1. Ersetzte Updates ablehnen

Der "Assistent für die Serverbereinigung" entfernt keine Updates die durch eine neuere Version ersetzt wurden. Dafür wird das 
Skript "Decline-SupersededUpdates.ps1" benötigt.

Quelle: https://social.technet.microsoft.com/Forums/msonline/en-US/15f0443d-2f68-4d9e-a580-0e330fbac6cc/no-updates-after-3159706?forum=winserverwsus

Mit dem Skript "Add-PKTaskDeclineSuperseededUpdates.ps1" kann auf dem WSUS-Server eine Aufgabe erstellt werden, die dieses Skript 
regelmäßig ausführt.

### 2. Wartung der WSUS-Datenbank

Die WSUS-Datenbank muss regelmäßig gewartet werden, um eine ausreichende Performance zu erreichen. Ich habe es schon oft erlebt, 
dass die Performance der Datenbank aufgrund nicht stattfindender Wartung so schlecht ist, dass die WSUS-Konsole nicht mehr 
funktioniert. Dazu wird das SQL-Skript "WsusDBMaintenance.sql" verwendet.
Quelle: https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/dd939795(v%3dws.10)

Mit dem Skript "Add-PKTaskWSUSDBMaintenance.ps1" kann auf dem WSUS-Server eine Aufgabe erstellt werden, die dieses Skript 
regelmäßig ausführt. Dieses Skript benötigt das Tool "sqlcmd.exe". Dies muss installiert sein und der Pfad zu dem Tool muss im 
Skript eventuell angepasst werden.

### 3. Durchführen der Synchronisierung per Powershell-Skript
    
Der über die WSUS-Konsole konfigurierbare Zeitplan für die Synchronisierung ist unflexibel. Man kann aber auch die Synchronisierung
auf "Manuell synchronisieren" stellen und die Synchronisierung über ein eingeplantes PowerShell-Skript durchführen. Dazu kann das 
Powershell-Modul "PoshWSUS" verwendet werden das über die Powershell Gallery bezogen werden kann.

Quelle: https://www.powershellgallery.com/packages/PoshWSUS/2.3.1.6

Mit dem Skript "Start-PKWSUSServerSync.ps1" kann die Synchronisierung des WSUS-Servers angestoßen werden.

### 4. Entfernen von nicht erwünschten Updates

Die Vorschauen auf Updates (Kennzeichnung "Preview" bzw. "Vorschau") sollen automatisch abgelehnt werden. Ebenso soll mit den 
Updates verfahren werden die nur die Sicherheitsupdates enthalten (Kennzeichnung "Sicherheitsqualitätsupdate").
Mit dem Skript "Remove-PKUnwantedUpdates.ps1" kann das Entfernen nicht erwünschter Updates angestoßen werden. Dazu ist das 
Powershell-Modul "PoshWSUS" erforderlich.

### 5. „Assistent für die Serverbereinigung“ regelmäßig automatisch ausführen

Der „Assistent für die Serverbereinigung“ soll regelmäßig automatisch durchgeführt werden. Mit dem Skript 
"Start-PKWSUSServerCleanup.ps1" kann die Bereinigung des WSUS-Servers angestoßen werden. Dazu ist das Powershell-Modul "PoshWSUS" erforderlich.
