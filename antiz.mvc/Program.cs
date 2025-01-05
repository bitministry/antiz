using BitMinistry;
using BitMinistry.Settings;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;
using System;

namespace antiz.mvc
{
    public class Program
    {
        public static string DomainName;

        public static SafeDictionary<string, DateTime> PasswordReminder = new SafeDictionary<string, DateTime>();

        public static void Main(string[] args)
        {
            CreateHostBuilder(args).Build().Run();

            

        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();
                });
    }
}
