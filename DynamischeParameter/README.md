# Dynamische Parameter #

Mir dynamische Parameter lassen sich zusätzliche Parameter einblenden, die vom Inhalt anderer Parameter abhängen. Sie 
benötigen allerdings einen nicht unerheblichen Programmieraufwand.

Sie werden von Cmdlets immer dann eingesetzt, wenn sie in einem bestimmten Zusammenhang sinnvoll sind, z.B. bei _Get-ChildItem_: 
Durchsucht man den Zertifikate Store von Windows mit _Get-ChildItem_ bekommt man den Parameter _CodeSigningCert_ angeboten, beim 
Anzeigen des Inhalts eines Ordners auf der Festplatte, aber nicht.

Die folgenden Beispiele zu dynamischen Parameter sind von Tobias während des PowerShell Usergroup Treffens Hannover am 16.06.2017 
gezeigt worden.
