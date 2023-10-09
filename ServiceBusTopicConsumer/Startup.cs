using Microsoft.Extensions.Hosting;

namespace ServiceBusTopicConsumer;

public class Startup
{
    static void Main()
    {
        var host = new HostBuilder()
            .ConfigureFunctionsWorkerDefaults()
            .Build();
        host.Run();
    }
    
}