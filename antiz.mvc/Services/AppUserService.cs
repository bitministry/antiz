using BitMinistry;
using BitMinistry.Data;
using BitMinistry.Data.Wrapper;
using BitMinistry.Mail;
using Microsoft.AspNetCore.Http;
using System;
using System.IO;
using System.Threading.Tasks;

namespace antiz.mvc
{
    public class AppUserService
    {


        public async Task<bool> SendVerificationEmail(AppUser model)
        {
            var body = $@"
username <b>{model.Username}</b>
code <b>{model.EmailVerificationCode}</b>
".NewLineToBR();
            await MailSender.Current.SendAsync(fromEmail: "noreply@" + Program.DomainName, toEmail: model.Email, subject: "code", htmlBody: body);
            return true;
        }

        public void UpdatePhotos(AppUser model, string id, AppUser db, IFormFileCollection files)
        {
            int? oldId = null;
            if (id == "NewAvatar")
            {
                oldId = db.AvatarId;
                var photo = new Photo()
                {
                    Data = CheckPostedImage(files["AvatarImg"], 1000)?.ResizeAndCrop(maxWidth: 200, maxHeight: 200)
                };
                if (photo.Data != null)
                {
                    photo.InsertSql();
                    model.AvatarId = photo.PhotoId;
                }
                else
                    model.AvatarId = null;

                model.UpdateOnly(ignoreDefaults: false, x => x.AvatarId);
                if (oldId != null)
                    oldId.DeleteById<Photo>();

            }
            if (id == "NewCover")
            {
                oldId = db.CoverId;

                var photo = new Photo()
                {
                    Data = CheckPostedImage(files["CoverImg"], 1000)?.ResizeAndCrop(maxWidth: 950, maxHeight: 200)
                };
                if (photo.Data != null)
                {
                    photo.InsertSql();
                    model.CoverId = photo.PhotoId;
                }
                else
                    model.CoverId = null;

                model.UpdateOnly(ignoreDefaults: false, x => x.CoverId);
            }
            if (oldId != null)
                oldId.DeleteById<Photo>();
        }



        byte[] CheckPostedImage(IFormFile file, int maxSizeK = 500)
        {
            if (file == null || string.IsNullOrEmpty(file.FileName))
                return null;

            var fileExtension = Path.GetExtension(file.FileName).ToLower();
            if (fileExtension != ".jpg" && fileExtension != ".png")
                throw new InvalidOperationException("Upload only JPG or PNG files");

            using (var memoryStream = new MemoryStream())
            {
                file.CopyTo(memoryStream);
                var photo = memoryStream.ToArray();

                if (photo.Length > maxSizeK * 1000)
                    throw new InvalidOperationException($"{file.FileName} is too big, max {maxSizeK}k");
                if (photo.Length < 100)
                    throw new InvalidOperationException($"{file.FileName} is too small");

                return photo;
            }
        }


        public void SetMyFollowersToSession( ISession sess, int loginId) {

            var followin = ($"select TargetId from Follow where userId =" + loginId).SelectFromSql(x => x.GetInt32(0));

            var iamFollowing = $",{string.Join(",", followin)},";

            sess.SetString("IamFollowing", iamFollowing);

        }



    }

}