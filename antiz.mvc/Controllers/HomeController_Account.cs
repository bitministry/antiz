using BitMinistry;
using BitMinistry.Data.Wrapper;
using BitMinistry.Mail;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Data;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace antiz.mvc
{
    public partial class HomeController : Controller
    {

        public IActionResult UserProfile(ProfileVm model )
        {
            model.Id = model.Id ?? HttpContext.Session.GetString("Username");

            if (model.Id == null)
                return RedirectToAction("Index");

            model.Load( Session.GetInt32("LoginId") ?? -1 );

            return View(model);
        }



        [HttpGet]
        public IActionResult Account(string id)
        {
            ViewBag.Id = id;

            var username = HttpContext.Session.GetString("Username");
            var model = (username ?? "").LoadEntity<AppUser>(x => x.Username) ??
                        new AppUser { Username = HttpContext.Request.Cookies["Username"] };

            if (ViewBag.IsModal == true)
                return model.UserId == null ? PartialView(model) : PartialView("LocationReload");

            return View(model);
        }

        [HttpPost]
        public async Task<IActionResult> Account(AppUser model, string act, string passCheck)
        {
            model.Username.ThrowIfNull("no username");
            act.ThrowIfNull("no act");

            // Load existing user based on username
            var existing = model.Username.LoadEntity<AppUser>(x => x.Username);

            if (act == "remindpass")
            {
                // Get client IP
                var ip = HttpContext.Request.Headers["X-Forwarded-For"].FirstOrDefault() ??
                         HttpContext.Connection.RemoteIpAddress?.ToString();

                if (Program.PasswordReminder.ContainsKey(ip) && Program.PasswordReminder[ip] > DateTime.Now.AddHours(-2))
                    return Content($"try again later");

                else
                {
                    if (existing != null)
                    {
                        await MailSender.Current.SendAsync(
                            fromEmail: MailSender.Current.SmtpUser, 
                            toEmail: existing.Email,
                            htmlBody: existing.Password,
                            subject: "Password Reminder"
                        );
                    }
                    return Content("password sent to email if such user exists");
                }
            }

            if (act == "reg")
            {
                model.Email.ThrowIfNull("email missing");

                // Validate passwords
                if (model.Password != null)
                {
                    if (!Regex.IsMatch(passCheck, AppUser.PassPattern))
                        throw new Exception("password must have at least 7 chars, including one non-alphanumeric");

                    if (model.Password != passCheck)
                        throw new Exception("password confirmation does not match");
                }

                // Check for existing username conflict
                var sessionUsername = HttpContext.Session.GetString("Username");
                if (existing != null && (sessionUsername == null || sessionUsername != model.Username))
                {
                    throw new Exception("Username already exists: " + model.Username);
                }

                // Handle email verification
                if (model.Email != existing?.Email)
                {
                    model.NuEmail = model.Email;
                    model.EmailVerificationCode = new Random().Next(1000, 9999);

                    HttpContext.Session.SetString("WeSentYouTheVerificationCode",
                        (await _userService.SendVerificationEmail(model)).CStr());
                }

                // Insert or update the user
                if (sessionUsername == null)
                {
                    model.InsertSql(avoidDuplicate: true);
                }
                else
                {
                    model.UpdateOnly(ignoreDefaults: true,
                        x => x.Username, x => x.Password, x => x.NuEmail, x => x.EmailVerificationCode);
                }

                return LoginAndRedirect(model);
            }

            // Validate credentials
            if (existing == null || model.Password != existing.Password)
                throw new Exception("Invalid credentials");

            return LoginAndRedirect(existing);
        }



        [HttpPost]
        public IActionResult AccountSocial(AppUser model, string id)
        {
            // Retrieve the username from the session
            model.Username = HttpContext.Session.GetString("Username");
            if (string.IsNullOrEmpty(model.Username))
            {
                return RedirectToAction("Index"); // Redirect if session is missing
            }

            // Load the user from the database
            var db = model.Username.LoadEntity<AppUser>(x => x.Username);
            db.ThrowIfNull("User not found");

            model.UserId = db.UserId;

            // Handle uploaded files
            var uploadedFiles = HttpContext.Request.Form.Files;
            if (uploadedFiles.Count > 0)
            {
                _userService.UpdatePhotos(model, id, db, uploadedFiles);
            }

            // Update user fields in the database
            model.UpdateOnly(ignoreDefaults: false,
                x=> x.Name, x=> x.Bio, 
                x => x.Landline, x => x.Mobile, x => x.Website,
                x => x.Telegram, x => x.Skype, x => x.Viber, x => x.Whatsapp,
                x => x.Instagram, x => x.TikTok, x => x.Facebook, x => x.LinkedIn,
                x => x.Vimeo, x => x.Rumble, x => x.Twitter, x => x.YouTube);

            return RedirectToAction("Account");
        }



   



        public async Task<IActionResult> EmailVerify(string EmailVerificationCode, string act)
        {
            var userId = HttpContext.Session.GetInt32("LoginId");
            var db = userId?.LoadEntity<AppUser>();

            if (db == null)
                throw new Exception("No logged-in user");

            if (act == "nucode")
            {
                HttpContext.Session.SetString("WeSentYouTheVerificationCode",
                    (await _userService.SendVerificationEmail(db)).CStr());
                return View();
            }

            if (int.TryParse(EmailVerificationCode, out var code) && code > 0)
            {
                if (db.EmailVerificationCode == code)
                {
                    db.Email = db.NuEmail;
                    db.NuEmail = null;
                    db.EmailVerificationCode = 0;
                    db.UpdateOnly(ignoreDefaults: false, x => x.NuEmail, x => x.Email, x => x.EmailVerificationCode);
                    return RedirectToAction("Account");
                }
            }

            return View();
        }


        RedirectToActionResult LoginAndRedirect(AppUser user)
        {
            HttpContext.Session.SetString("Username", user.Username);
            HttpContext.Session.SetInt32("LoginId", user.UserId.Value);

            _userService.SetMyFollowersToSession(Session, user.UserId.Value); // Session("IamFollowing")

            HttpContext.Response.Cookies.Append("Username", user.Username, new CookieOptions
            {
                Expires = DateTime.Now.AddDays(99),
                HttpOnly = true
            });

            return RedirectToAction("Account");
        }


        public IActionResult LogOff()
        {
            HttpContext.Session.Remove("Username");
            HttpContext.Session.Remove("LoginId");
            HttpContext.Session.Remove("IamFollowing");            

            return RedirectToAction("Index");
        }

    }
}
