#region cURL vs Invoke-Webrequest
<#
    Was ist cURL?
    -------------    
    * Ein nicht-interaktiver Webbrowser fürs Terminal, um 
        + um Dateien herunterzuladen
        + automatisierte Updates skripten
        + Zugriff auf Remote-APIs testen
    * Automatisierten Transfer von Daten über verschiedene Protokolle z.B. HTTP, FTP, Telnet, IMAP
    * Das Schweizer Taschenmesser für Sysadmins :-)
    * Wird seit einer Weile mit Windows 10 ausgeliefert 
    * Wie konnte das passieren?
#>
#endregion

#region cURL Basisdaten

$cURL = @{
    Entwickler          = 'Daniel Stenberg'
    Erscheinungsjahr    = '1998'
    Version             = '7.79.0 (15. September 2021)'
    Lizenz              = 'MIT-Lizenz'
} > $cURL

# Wie aktuell ist die Version für Windows?
curl.exe --version 

# cURL wird seit April 2018 mit Windows 10 Update 1803 ausgeliefert
# Es muss also nicht mehr extra installiert werden 

#endregion

#region Wie kam cURL in Windows?

$path = "C:\Users\chris\OneDrive\curlVsIwr"
Show-Image -File $path\turner.png
# Richard Turner - Program Manager, Microsoft

# Was war passiert?

Show-Image -File $path\Stenberg.png
# Daniel Stenberg - Entwickler von cURL

# Invoke-WebRequest hat den Alias curl in der Windows PowerShell 

Show-Image -File $path\snover.png
# Jeffrey Snover - Technical Fellow, Microsoft

# Invoke-WebRequest funktioniert anders als curl

# Wer curl in der Kommandozeile nutzen will, will kein Iwr

# Oder wie Jeffrey Snover später resümiert:

Show-Image -File $path\snover2.png

# Der curl-Alias in der Windows PowerShell

powershell.exe -Command 'Get-Alias curl'

# In PowerShell 7 gibt es den Alias dann nicht mehr:

Get-Alias curl

# Im Rahmen der Cross-Plattformstrategie verteilt Microsoft nun also *nix-Tools wie cURL, tar, ssh etc. mit Windows

#endregion

#region Ist Invoke-WebRequest dasselbe wie cURL?

# Einfach Antwort: Nein.

# Invoke-WebRequest sendet Anfragen mit HTTP, HTTPS, FTP und FILE an Webseite oder -service

curl.exe --version

# Beispielsweise verhalten sich die Befehle anders:
curl.exe ifconfig.me

Invoke-WebRequest ipconfig.me

# Vorteil von Invoke-WebRequest ist natürlich, dass die Antwort PowerShell-like in Objekten vorliegt

Invoke-WebRequest -Uri https://git.io/JRRmL | Select-Object -Expand headers

# Die Objekt-Orientierung von PowerShell-Cmdlets haben viele Vorteile, die mit cURL nicht so einfach zu machen sind:

(Invoke-WebRequest psugh.de).links.href

# Nachteil: Es werden andere Werte zurückgeben als bei cURL

curl.exe --head https://git.io/JRRmL

# Wir sehen auch: Cmdlet und cURL benutzen verschiedene Parameter, cURL ist eher Bash-like

curl.exe -sL git.io/JRRmL
(iwr git.io/JRRmL).content

# Das klappt auch mit dem Wetter:

curl.exe http://wttr.in/Hannover
(iwr http://wttr.in/Hannover).content

# cURL profuziert auch schönere Ergebnisse, wenn man schnell einen QR-Code braucht:

curl qrenco.de/psugh.de
(iwr qrenco.de/psugh.de).content

# Fehlgeschlagene Downloads kann man in cURL mit der Option -C fortsetzen:

curl -o "PowerShell Cheat Sheet.pdf" -C - https://www.netz-weise-it.training/images/dokus/Powershell%20Cheat%20Sheet%201.0.pdf

# Das geht erst in PowerShell 7, allerdings mit voke-RestMethod

Invoke-RestMethod -Resume https://www.netz-weise-it.training/images/dokus/Powershell%20Cheat%20Sheet%201.0.pdf -OutFile "PowerShell Cheat Sheet.pdf"

# Invoke-RestMethod ist das 2. Cmdlet, das hÃ¤ufig mit cURL verwechselt wird. Damit werden Anfragen mit 
# HTTP und HTTPS zu einem REST Webservice geschickt, der dann mit strukturierten Daten antwortet, die 
# PowerShell dann in JSON etc. formatiert 

# Mit Invoke-RestMethod kann man Formulare ausfÃ¼llen: https://freeshell.de/~dtntlr/eingabe.html

Invoke-RestMethod https://freeshell.de/~dtntlr/eingabe.php -Method Post -Body @{vor="Poison";nach="Ivy"}

curl -d "vor=Harley&nach=Quinn" https://freeshell.de/~dtntlr/eingabe.php

#endregion 

#region Zum Schluss...

# Cmdlets Invoke-WebRequest und Invoke-RestMethod sind nützliche zum Abfragen und Parsen von Webdaten
# Sie haben eine gewisse Ähnlichkeit mit cURL, unterscheiden sich aber
# Die Cmdlets sind Teil von PowerShell und ihr Ergbnis lässt sich in Objekten weiterverarbeiten
# cURL ist teils auf andere Sprachen und Tools angewiesen, um die gleichen Aufgaben zu erfüllen, z.B. auch auf PowerShell

#endregion

# ENDE
