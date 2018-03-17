using System.Management.Automation;
using System.Net.NetworkInformation;

namespace TestSimpleConnection 
{
    /// <summary>
    /// <para type="synopsis">
    /// Simple test if your computer is up.
    /// </para>
    /// <para type="description">
    /// With Test-SimpleConnection you can simple ping a
    /// computer or server.
    /// </para>
    /// <para type="example">
    /// Test-SimpleConnection -Computer "Computername"
    /// </para>
    /// </summary>
    [Cmdlet("Test","SimpleConnection")]
    public class TestSimpleConnectionCmdlet:PSCmdlet
    {
         [Parameter(
                    Mandatory = true,
                    Position = 0,
                    ValueFromPipelineByPropertyName = true,
                    ValueFromPipeline = true,
                    HelpMessage = "The computer you want to ping.")]
        public string Computer { get; set; }
        
        protected override void ProcessRecord()
        {          
            Ping ping = new Ping();
            PingReply reply;
            string server;
            server = Computer.ToString();
            try
            {
                if (ping.Send(server).Status == IPStatus.Success)
                {
                    reply = ping.Send(server);
                    var myobj = new MyObject()
                                {
                                    Computername = server.ToString(),
                                    Address      = reply.Address.ToString(),
                                    Response     = reply.RoundtripTime.ToString()
                                };
                    WriteObject(myobj);              
                }
            }
            catch (PingException)
            {
                WriteObject("\nNo Route to Host.\n");
            }
            base.ProcessRecord();
        }
    }
    public class MyObject
    {
        public string Computername { get; set; }
        public string Address { get; set; }
        public string Response { get; set; }
    }
}
