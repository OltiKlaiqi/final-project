using System;
using System.Threading;
using System.Threading.Tasks;
using Prometheus;

// Start Prometheus metrics server on port 80
var server = new MetricServer(port: 80);
server.Start();

// Create a counter for jobs processed
var counter = Metrics.CreateCounter("worker_jobs_total", "Number of jobs processed.");

// Increment the counter every 5 seconds in a background task
_ = Task.Run(async () =>
{
    while (true)
    {
        counter.Inc();
        Console.WriteLine("Worker processed a job.");
        await Task.Delay(5000);
    }
});

// Keep the application alive indefinitely
Console.WriteLine("Metrics server running on port 80. Press Ctrl+C to exit.");
await Task.Delay(Timeout.Infinite);

