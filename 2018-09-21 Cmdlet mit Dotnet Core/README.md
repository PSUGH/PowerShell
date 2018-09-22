# PowerShell Cmdlets bauen in .NET Core

#### Christian Imhorst (@datenteiler)

## Warum .Net Core?

* ASP.NET erfolgreich in Unternehmen, verlor aber Entwickler

* Die Performanz von ASP.NET ist nicht wettbewerbsfähig:

* Andere Web Application Frameworks unter Linux sind schneller und leistungsfähiger, z.B. Node.JS

* ASP.NET Core war der Anfang von .NET Core

## Was ist .NET Core

* Eine neue, moderne und leistungsfähige .NET Standard Library 2.0 

* Plattformunabhängig

* Wettbewerbsfähig da Open Source

* Verbesserte Modularität, vereinfachte Anwendungsentwicklung

## PowerShell Core

* Basiert auf .Net Core -> Plattformunabhängig, Open Source, Modular

* PowerShell Cmdlets können mit .NET Core und der PowerShell Standard Library für Cross-Plattform Module erstellt werden

* Nachteile? 
  * Auf Cmdlets und Funktionen kann nicht mehr so einfach zugegriffen werden
  * Infrastruktur Code sollte PowerShell-Code sein

* Vorteile? 
  * Binärmodule können durch 3. nicht einfach verändert werden
  * Verschiedene Bibliotheken können in einem Modul zusammengefasst werden
  * Binärmodule können bei bestimmten Aufgaben schneller sein, als Skripte
