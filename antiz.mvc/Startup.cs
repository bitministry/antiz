using BitMinistry.Settings;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Razor;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System;

namespace antiz.mvc
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;

            BSettings.Init();
            Program.DomainName = BSettings.Get("domain", "antiZion.co");

        }

        public IConfiguration Configuration { get; }

        public void ConfigureServices(IServiceCollection services)
        {
            services.AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme = CookieAuthenticationDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = CookieAuthenticationDefaults.AuthenticationScheme;
            })
                .AddCookie()
                .AddGoogle(options =>
                {
                    options.ClientId = BSettings.Get("Integration:Google:ClientId");
                    options.ClientSecret = BSettings.Get("Integration:Google:ClientSecret");
                    options.CallbackPath = "/signin-google"; 
                    options.Scope.Add("email");
                    options.Scope.Add("profile");
                });


            services.AddControllersWithViews()
                .AddRazorRuntimeCompilation();

            services.AddDistributedMemoryCache(); 
            services.AddSession(options =>
            {
                options.IdleTimeout = TimeSpan.FromMinutes(30); 
                options.Cookie.HttpOnly = true;
                options.Cookie.IsEssential = true;  
            });

            services.AddResponseCaching();

        }

        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            //if (env.IsDevelopment())
            if (false)
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseExceptionHandler("/Error");
                app.UseHsts();
            }
            app.UseHttpsRedirection();
            app.UseStaticFiles();


            app.UseResponseCaching(); 
            app.UseSession();

            app.UseRouting();

            app.UseAuthentication(); 
            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllerRoute(
                    name: "BackEnd",
                    pattern: "backend/{action}/{*id}",
                    defaults: new { controller = "BackEnd", action = "Partial" }
                );

                endpoints.MapControllerRoute(
                    name: "UserProfile",
                    pattern: "/@{id}/{xcase?}",
                    defaults: new { controller = "Home", action = "UserProfile" },
                    constraints: new { id = @"[\w]+" }  // Regex to allow alphanumeric 
                );

                endpoints.MapControllerRoute(
                    name: "default",
                    pattern: "{action}/{id?}",
                    defaults: new { controller = "Home", action = "Index" }
                    );

            });
        }


    }
}
