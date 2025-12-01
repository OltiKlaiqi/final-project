using System;
using System.Threading;
using Prometheus;

var counter = Metrics.CreateCounter("worker_jobs_total", "Number of jobs processed.");

while (true)
{
    counter.Inc();
    Console.WriteLine("Worker processed a job.");
    Thread.Sleep(5000);
}
