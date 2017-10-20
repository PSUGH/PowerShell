param
(
    [switch]
    $Install,
    
    [switch]
    $Uninstall
)
  
  ## Service
  
if ($Install)
{
$servicename = $($($MyInvocation.MyCommand.Name).Split('.')[0])
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
                //// do some other things while you wait...
                System.Threading.Thread.Sleep(10000); // simulate doing other things...
                process.StandardInput.WriteLine("exit"); // tell console to exit
                if (!process.HasExited)
                {
                    process.WaitForExit(120000); // give 2 minutes for process to finish
                    if (!process.HasExited)
                    {
                        process.Kill(); // took too long, kill it off
                    }
                }
            }
        }
        protected override void OnContinue()
        {
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

            process.Account = ServiceAccount.LocalSystem;

            Installers.Add(process);
            Installers.Add(service);
        }
    }
}
"@
    Add-Type -TypeDefinition $source -Language CSharp -OutputAssembly "$PSScriptRoot\$servicename.exe" -OutputType ConsoleApplication -ReferencedAssemblies "System.ServiceProcess","System.Configuration.Install","System.ComponentModel"
    Start-Process -FilePath "$PSScriptRoot\InstallUtil.exe" -ArgumentList "$PSScriptRoot\$servicename.exe" -Wait
    Start-Service $servicename
    break
  }
  
  if ($Uninstall)
  {
    Stop-Service $servicename
    Start-Process -FilePath "$PSScriptRoot\InstallUtil.exe" -ArgumentList "-u $PSScriptRoot\$servicename.exe" -Wait
  }
  
  ## Script
  
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
