param
(
    [switch]
    $Install,
    
    [switch]
    $Uninstall
)

# Der Name unsers Dienstes ist der Name des Skripts
$servicename = $($($MyInvocation.MyCommand.Name).Split('.')[0])

if ($Install)
{
# Der Service wird in C# erstellt:
$source = @"
using System.ServiceProcess;
using System.Configuration.Install;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;

// Das Grundgerüst des Dienstes:

namespace MyService
{
    public class Service : ServiceBase
    {
        static void Main()
        {
            Service.Run(new Service());
        }

        protected override void OnStart(string[] args)
        {
            using (EventLog eventLog = new EventLog("Application"))
            {
                if (!EventLog.SourceExists("$servicename"))
                    EventLog.CreateEventSource("$servicename", "Application");
                EventLog.WriteEntry("$servicename", "Starting Service", EventLogEntryType.Information, 1704);
            }
            using (Process process = new Process())
            {
                process.StartInfo = new System.Diagnostics.ProcessStartInfo(@"C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe");
                process.StartInfo.Arguments = @"-ExecutionPolicy Bypass -f $PSCommandPath";
                process.StartInfo.CreateNoWindow = true;
                process.StartInfo.ErrorDialog = false;
                process.StartInfo.RedirectStandardError = true;
                process.StartInfo.RedirectStandardInput = true;
                process.StartInfo.RedirectStandardOutput = true;
                process.StartInfo.UseShellExecute = false;
                process.StartInfo.WindowStyle = System.Diagnostics.ProcessWindowStyle.Hidden;
                process.Start();
                System.Threading.Thread.Sleep(10000);
                process.StandardInput.WriteLine("exit"); // Die Console soll sich nach Ausführung beenden
                if (!process.HasExited)
                {
                    process.WaitForExit(120000); // Gibt dem Dienst 2 Minuten, sich zu beenden ...
                    if (!process.HasExited)
                    {
                        process.Kill(); // ... wenn das zu lange dauert, kill ihn. 
                    }
                }
            }
        }
        protected override void OnContinue()
        {
            // Der Dienst schreibt in die Ereignisanzeige, hier unter "Anwendungen"
            using (EventLog eventLog = new EventLog("Application"))
            {
                if (!EventLog.SourceExists("$servicename"))
                    EventLog.CreateEventSource("$servicename", "Application");
                EventLog.WriteEntry("$servicename", "Continuing Service", EventLogEntryType.Information, 1704);
            }
        }
        protected override void OnStop()
        {
            using (EventLog eventLog = new EventLog("Application"))
            {
                if (!EventLog.SourceExists("$servicename"))
                    EventLog.CreateEventSource("$servicename", "Application");
                EventLog.WriteEntry("$servicename", "Stopping Service", EventLogEntryType.Information, 1704);
            }
        }
    }

    // Der Installer des Dienstes:
    [RunInstaller(true)]
    public class Installation : Installer
    {
        private ServiceInstaller service;
        private ServiceProcessInstaller process;

        public Installation()
        {
            service = new ServiceInstaller();
            process = new ServiceProcessInstaller();

            service.ServiceName = "$servicename";
            service.DisplayName = "$servicename";
            service.Description = "Windows-Dienst $servicename";
            
            // Der Dienst läuft mit den höchsten Rechten
            process.Account = ServiceAccount.LocalSystem;

            Installers.Add(process);
            Installers.Add(service);
        }
    }
}
"@
# Die EXE-Datei des Dienstes wird mit den notwendigen Verweisen kompiliert, installiert und gestartet
Add-Type -TypeDefinition $source -Language CSharp -OutputAssembly "$PSScriptRoot\$servicename.exe" -OutputType ConsoleApplication -ReferencedAssemblies "System.ServiceProcess","System.Configuration.Install","System.ComponentModel"
# Die InstallUtil.exe liegt in diesem Beispiel im selben Pfad wie das Skript, man findet es sonst unter den 
# Programmen des verwendeten .NET-Frameworks, z.B. C:\Windows\Microsoft.NET\Framework\v4.0.30319
Start-Process -FilePath "$PSScriptRoot\InstallUtil.exe" -ArgumentList "$PSScriptRoot\$servicename.exe" -Wait
Start-Service $servicename
break
}
  
if ($Uninstall)
{
  Stop-Service $servicename
  # InstallUtil.exe mit Parameter -U deinstalliert den Dienst wieder
  Start-Process -FilePath "$PSScriptRoot\InstallUtil.exe" -ArgumentList "-u $PSScriptRoot\$servicename.exe" -Wait
}
  
# Das Skript schreibt einfach die aktuelle Zeit und eine Zufallszahl in eine Text-Datei. Es wird immer wieder
# zusammen mit dem Dienst ausgeführt.
  
$logfile = "$env:PUBLIC\log\random.txt"

if ($(Test-Path -Path $logfile))
{
  Remove-Item $logfile
}
else
{
    New-Item -Path $logfile -Force | Out-Null
}

$a = Get-Date
$b = Get-Random 
  
Write-Output -InputObject ('{0} {1}' -f $a, $b) | Out-File -FilePath $logfile
