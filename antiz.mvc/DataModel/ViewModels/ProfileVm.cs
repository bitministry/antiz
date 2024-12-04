using BitMinistry.Data.Wrapper; 
using Microsoft.AspNetCore.Http;
using Org.BouncyCastle.Math.EC;
using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace antiz.mvc
{
    public class ProfileVm {

        public string Id { get; set; }
        public int? LoadMoreFrom { get; set; }
        public vAppUser AppUser { get; set; }

        public StatementListVm StatementListVm { get; set; }

        public enum Case { Posts, Likes, Replies, Highlights, Followers, Following }

        public Case? XCase { get; set; } = Case.Posts;

        public IEnumerable<AppUser> FollowContent;
            

        internal void Load( int loginId )
        {
            AppUser = Id.LoadEntity<vAppUser>(x => x.Username);

            switch (XCase)
            {
                case Case.Posts:
                case Case.Replies:
                case Case.Highlights:
                    StatementListVm = new StatementService()
                            .GetStatementListVm(
                                loginId: loginId,
                                sqlProc: "sp_usertimeline",
                                loadMoreFrom: LoadMoreFrom,
                                ("@authorid", AppUser.UserId.Value),
                                ("@case", XCase.ToString() ) );

                    StatementListVm.AddPostVm.TargetUsername = AppUser.Username;

                    break;

                case Case.Following:
                    FollowContent = (@"select * from AppUser u 
                        join Follow f on f.TargetId = u.UserId 
                        where f.UserId = " + AppUser.UserId).QueryForSql<AppUser>();                            
                    break;

                case Case.Followers:
                    FollowContent = (@"select * from AppUser u 
                        join Follow f on f.UserId = u.UserId 
                        where f.TargetId = " + AppUser.UserId).QueryForSql<AppUser>();
                    break;

            }
        }
    }


    public class vAppUser : AppUser {
        public int IamFollowingCount { get; set; }
        public int PeopleFollowMeCount { get; set; }


        public bool IFollow(ISession sess) =>
                sess.GetInt32("LoginId") == UserId ||
                Regex.IsMatch(sess.GetString("IamFollowing") ?? "", $",{UserId},");


    }

}