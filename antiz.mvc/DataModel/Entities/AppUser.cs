using BitMinistry;
using BitMinistry.Data;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace antiz.mvc
{
    public class AppUser : IEntity
    {
        [BEntityId(Seed = true)]
        public int? UserId { get; set; }

        [StringLength(33)]
        public string Username { get; set; }

        public static string PassPattern = "^(?=.*[^a-zA-Z]).{7,21}$";

        [StringLength(22)]
        public string Password { get; set; }
        [StringLength(66)]
        public string Name { get; set; }
        [StringLength(444)]
        public string Bio { get; set; }
        public int? CoverId { get; set; }
        public int? AvatarId { get; set; }
        public string Email { get; set; }

        public long? Landline { get; set; }
        public long? Mobile { get; set; }
        [StringLength(111)]
        public string Website { get; set; }
        [StringLength(111)]
        public string Telegram { get; set; }
        [StringLength(111)]
        public string Skype { get; set; }
        [StringLength(111)]
        public string Viber { get; set; }
        [StringLength(111)]
        public string Whatsapp { get; set; }
        [StringLength(111)]
        public string Instagram { get; set; }
        [StringLength(111)]
        public string TikTok { get; set; }
        [StringLength(111)]
        public string Facebook { get; set; }
        [StringLength(111)]
        public string LinkedIn { get; set; }
        [StringLength(111)]
        public string Vimeo { get; set; }
        [StringLength(111)]
        public string Rumble { get; set; }
        [StringLength(111)]
        public string Twitter { get; set; }
        [StringLength(111)]
        public string YouTube { get; set; }
        public int EmailVerificationCode { get; set; }
        public string NuEmail { get;  set; }
        public DateTime? Joined { get; set; }

               

    }
}