# Into the Core
Christian Imhorst (@datenteiler)

## Was ist PowerShell 5?

* Die Windows PowerShell ist fertig
* Sie wird als stabil angesehen und erhält keine neuen Features
* Sie wird weiter für die Administration von Windows genommen
* Sie basiert auf das .NET Framework 
* Keine „Breaking Changes“

## Was ist PowerShell 6 / Core?

* PowerShell Core ist ein neues Produkt, das auf Windows PS basiert
* PowerShell Core läuft auf .NET-Core und ist Plattform unabhängig 
* Für die Unabhängigkeit mussten ein paar Dinge geopfert werden:
* Weniger Cmdlets und weniger Module: `(Get-Command).Length`
* Es gibt nur Konsolen-Cmdlets 
* Ist (noch) Veräderungen unterworfen: _„breaking changes“_

## Was sind die „breaking changes“?

* Keine Remote Procedure Calls (RPCs) mehr, da Windows spezifisch 
* Remoting funktioniert über WS-MAN und SSH  
* Viele Web-Cmdlets funktionieren anders, z.B. Invoke-WebRequest, oder der folgende Befehl in PowerShell 5 und 6

  `irm ipinfo.io`

* PowerShell Workflows werden nicht mehr supportet
* Es gibt keine Snap-Ins mehr
* PowerShell 6 kann keine DSC Ressourcen ausführen, denn DSC gibt es unter Linux nicht, dort wird LCM verwendet.

## PowerShell 6 unter Windows

* Die Kommandozeile ist nicht aktuell (Kein STRG+C / +V)

  `gps | where ws -gt 100MB | sort WS –Desc | FT Name, WS, Starttime`

* Keine grafische Ausgabe wie Out-GridView
* Es fehlen Cmdlets von PowerShell 5 und nicht alle funktionieren
* Der Name ist jetzt pwsh.exe
* (Die Namen posh oder psh waren schon vergeben)
* Standardparameter ist kein Befehl, sondern Skript

  `pwsh.exe –command $psversiontable`

## PowerShell Core unter Linux	

* Externe Befehle der Linux-Shell haben Vorrang vor dem Alias (ls, ps, sort)
* Windows-Aliase wie dir oder cd sind möglich
* Groß- und Kleinschreibung muss beachtet werden 
* Das geht deshalb so nicht:

  `gps | where ws -gt 100MB | sort WS –Desc | | FT Name, WS, Starttime`

* Externe Befehle liefern Strings, nicht Objekte (wie unter Win auch):

  `ls | gm`

* PSReadline macht Vorschläge in Emacs-Style, was man ändern kann:
  
  `Set-PSReadlineOption –EditMode Windows` 
  
* Pfadtrenner sind / und nicht \ (Get-PSDrive)
* WSMan geht mit OMI-Server unter Linux. Oder: OpenSSH unter Windows

## Cmdlets die unter Linux fehlen

* Cmdlets für lokale Benutzer und Gruppen: Remove-LocalUser 
* Alle Cmdlets für Dienste: Get-Service, Start-Service
* Für Aktionen mit dem Computer: Restart-Computer
* Alle CIM-Cmdlets: Get-CimInstance
* Keine COM-Objekte oder WMI
* Keine Cmdlets für Zugriffsrechte: Get-Acl, Set-Acl
* Cmdlets für den Remotezugriff: Connect-WSMan
* Netzwerk-Cmdlets: Test-Connection
* etc.pp.

## Eigene Cmdlets für Core erstellen

* Ähnlich wie bei Windows CMD, den Rückgabetext in Objekte umwandeln:
* Windows-Beispiel:

  `driverquery /fo csv | ConvertFrom-Csv -Header Modulname,Anzeigename,Treibertyp | sort Modulname`

* Linux-Beispiel:

  ```
  cat /etc/passwd | 
  ConvertFrom-CSV -Delimiter ':' -Header Name,Passwd,UID,GID,Description,Home,Shell |
  Sort-Object Name |
  Format-Table
  ```
  
  ## Was bietet PowerShell Core unter Linux?
  
* Die PowerShell bietet mächtiges Pipelining 
* Sowie Ein- und Ausgabe-Cmdlets für und mit Objekte

  ```
  gps firefox | select *
  kill (gps firefox).id
  gps | gm
  ```

* Das Arbeiten mit Objekten wirkt moderner und mächtiger als mit Text
* PowerShell Cmdlets sind  dafür aber keine Universalwerkzeuge
* Cmdlets sind spezialisierte .NET-Klassen, die PowerShell zur Laufzeit instanziiert und ausführt.
* Cmdlets werden erstellt, um innerhalb der PowerShell zu laufen

## Was soll PowerShell Core überhaupt?

* Microsoft wechselt sein Geschäftsmodel 
* Statt Software soll in Zukunft Rechenzeit verkauft werden
* Egal, ob in der Cloud oder im Datacenter – Azure Stack
* Das darunterliegende OS ist dafür uninteressant
* Dafür benötigt der Admin Automatisierungstools, die alle OS bedienen
* Dafür könnte MS auch Bash nehmen, Bash ist aber keine moderne Shell
* Bash bedeutet Text-Output und eine hohe Lernkurve
* PowerShell bietet mit seinen Objekten konsequent strukturierte Daten

## Ein Fazit für PowerShell Core

* Unter Windows wird man mittelfristig weiter die PowerShell 5.x nehmen
* PowerShell und C# gehören nicht zum Standard des Linux-Admins
* Man kann sich als Pionier  hervortun und Cmdlets für den Zugriff aufs Betriebssystem oder Netzwerk neu schreiben...
* ... oder einfach Bash und Python/Perl nehmen, was effektiver ist
* Kompilierte und objektorientierte Anwendungen für die Administration sind „overkill“
* PowerShell Core ist kein Ersatz für Windows PowerShell

## Wird sich PowerShell Core unter Linux durchsetzen?

* Die Systemadministration ist aktuell im Umbruch
* Schlagworte sind Container, Serverless Computing mit Terraform, Nomad, Kubernetes, OpenFaaS etc.
* Admins verwalten zukünftig keine Server mehr, das machen Datacenters von Microsoft, Google, Amazon etc.
* Stattdessen wird eine neue Azure-VM/EC2/GCP mit Terraform ausgerollt und ein Container mit K8s deployed
* Das schafft die Linux-Welt komplett ohne PowerShell
* Die Probleme, die PowerShell Core lösen will, wurden dort bereits gelöst, indem YAML- und JSON-Dateien und Dockerfiles editiert werden
