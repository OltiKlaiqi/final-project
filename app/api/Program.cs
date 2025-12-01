using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Prometheus;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();

var app = builder.Build();

// Expose /metrics for Prometheus
app.UseMetricServer();

// Optional: HTTP request metrics
app.UseHttpMetrics();

app.MapGet("/hello", () => "Hello from demo API!");

app.Run();