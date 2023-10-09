using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

public class ServiceBusTopicListeners
{
    private ILogger _logger;
    public ServiceBusTopicListeners(IServiceProvider serviceProvider)
    {
        var loggerFactory = serviceProvider.GetRequiredService<ILoggerFactory>();
        _logger = loggerFactory.CreateLogger(this.GetType());
    }
    [Function(nameof(ProcessOrders))]
    public async Task ProcessOrders([ServiceBusTrigger("orders", subscriptionName: "sydneyorders", 
        Connection = "servicebus_cs", IsSessionsEnabled = false)] string message, FunctionContext context)
    {
        _logger.LogInformation($"Received message: {message}");   
    }    
}