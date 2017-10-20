using System.ServiceProcess;
using System.ServiceModel;
using System.Configuration.Install;
using System.ComponentModel;

// Das Grundgerüst eines Windows-Dienstes:

namespace Dienst
{
    public class Service : ServiceBase
    {
        static void Main()
        {
            Service.Run(new Service());
        }

        protected override void OnStart(string[] args)
        {
            base.OnStart(args);
        }
        protected override void OnContinue()
        {
            base.OnContinue();
        }
        protected override void OnStop()
        {
            base.OnStop();
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

            service.ServiceName = "MeinWindowsDienst";
            service.DisplayName = "MeinWindowsDienst";
            service.Description = "Mein Windows-Dienst";

            process.Account = ServiceAccount.LocalSystem;

            Installers.Add(process);
            Installers.Add(service);
        }
    }
}
