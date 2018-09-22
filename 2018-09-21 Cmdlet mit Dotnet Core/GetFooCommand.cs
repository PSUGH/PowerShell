#region "Eine .Net Core Klassenbibliothek erstellen"
/*
dotnet new classlib --name psmodule
cd .\psmodule
dotnet add package PowerShellStandard.Library --version 5.1.0-preview-06

    bzw. man schreibt in die csproj-Datei:

    <ItemGroup>
        <PackageReference Include="PowerShellStandard.Library" Version="5.1.0-preview-06" />
    </ItemGroup>
*/
#endregion

#region "Ein erstes Cmdlet"
using System.Management.Automation;

namespace PSCmdletExample
{
    [Cmdlet("Set", "Foo")]
    public class SetFooCommand : PSCmdlet
    {
        [Parameter]
        public string SetName { get; set; } = string.Empty;

        protected override void EndProcessing()
        {
            this.WriteObject("Set Foo is " + this.SetName);
            base.EndProcessing();
        }
    }
    #endregion

#region "Die Cmdlet Klasse"
    // Das Verb-Substantiv-Paar, worauf das Cmdlet reagiert:
    [Cmdlet("Get", "Foo")]

    // Cmdlet-Klassen, die von PSCmdlet, erben funktionieren nur innerhalb der PowerShell
    public class GetFooCommand : PSCmdlet
    {
#endregion

#region "Die Paramter des Cmdlets"
        // Parameter des Cmdlets definieren, hier ein String mit Lese- und Schreibeigenschaften:
        [Parameter(
            Position = 0,
            // Eingaben aus der Pipeline sollen in diesen Parameter gehen:
            ValueFromPipeline = true,
            // Akzeptiert Parameter Eingaben aus einer Eigenschaft eines Pipeline-Objekts, 
            // wenn das Pipeline-Objekt bspw. die Eigenschaft 'Name' hat:
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty]
        public string Name { get; set; } = string.Empty;
#endregion

#region "Methoden der Basisklasse"
        // Die Cmdlet-Klasse muss '''mindestens eine''' der gleichnamigen Methoden der Basisklasse überschreiben:

        // BeginProcessing(): Wird einmal am Anfang aufgerufen
        // ProcessRecord(): Wird einmal für jedes Objekt in der Pipeline aufgerufen, mind. einmal
        // EndProcessing(): Wird einmal am Ende aufgerufen
        // StopProcessing(): Wird bei Abbruch einmal aufgerufen

        protected override void ProcessRecord()
        {
            // Die Ausgabe erfolgt über WriteObjekt:
            base.ProcessRecord();
            this.WriteObject("Get Foo is " + this.Name);
        }
    }
}
#endregion

#region "Ein Modulmanifest schreiben"
/*
    Man kann das Modul als DLL laden:

    ipmo bin\Debug\netstandard2.0\psmodule.dll

    Für Modulpfad "$env:PSModulePath" oder PSGallery benötigt man ein Modulmanifest:

    # manifest.ps1

    $manifestSplat = @{
        Path              = "psmodule.psd1"
        Author            = 'Christian Imhorst'
        NestedModules     = @('psmodule.dll')
        RootModule        = "psmodule.psm1"
        FunctionsToExport = @('Get-Foo', 'Set-Foo')
    }

    New-ModuleManifest @manifestSplat
    Set-Content -Value '' -Path "psmodule.psm1"
 */
#endregion

#region "Template für ein PowerShell Standard Modul"
/*
    dotnet new -i Microsoft.PowerShell.Standard.Module.Template 
    dotnet new psmodule
    dotnet build
    ipmo .\bin\Debug\netstandard2.0\mypsmodule.dll
    Get-Module mypsmodule
 */
#endregion

#region "Was muss man noch beachten?"
    /*
      
     * Wenn ein C# Modul kann schwierig wieder entladen werden, DLL ist beim Entwickeln dann blockiert
    
     * Blockade nervt auch, wenn man eine installierte DLL aktualisieren will 
     
     * Mit "Reload Window" über STRG+Shift+P kann man VSCode neu laden. 
      
    */
#endregion
