using BitMinistry.Data.Wrapper;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BitMinistry;
using BitMinistry.Data;
using System.Linq;
using System.Collections.Generic;
using System;

namespace antiz.mvc
{

    public class BackEndController : Controller
    {
        ISession Session => HttpContext.Session;
        public ActionResult GetUserSuggestions(string id)
        {
            using (var sql = new BSqlCommander( comType: System.Data.CommandType.StoredProcedure ))
            {
                sql.AddWithValue("@userId", Session.GetInt32("LoginId"));
                sql.AddWithValue("@query", id );

                var filteredUsers = 
                    sql.QueryForSql<AppUser>("sp_mentions", reset: false )
                    .Select( x=> new { 
                        x.AvatarId,
                        x.Name,
                        x.Username
                    } )
                    .ToList();
                return Json(filteredUsers);


            }
        }

        public ContentResult NewFollow(int id )
        {
            if (Session.GetInt32("LoginId") == null)
                return Content("no_login");

            var loginId = Session.GetInt32("LoginId").Value;
            new Follow()
            {
                UserId = loginId,
                TargetId = id
            }.SaveOrUpdate(x => x.UserId == loginId && x.TargetId == id);

            new AppUserService().SetMyFollowersToSession(Session, loginId);

            return Content("done");
        }

        public ActionResult UnFollow(int id)
        {
            if (Session.GetInt32("LoginId") == null)
                return RedirectToAction("Index", "Home");

            var loginId = Session.GetInt32("LoginId").Value;
            new Follow().DeleteWhere(x => x.UserId == loginId && x.TargetId == id);
            new AppUserService().SetMyFollowersToSession(Session, loginId);

            return RedirectToRoute("UserProfile", new { id });
        }

        public ContentResult LikeOrRepost(string id, int statementId )
        {
            var loginId = Session.GetInt32("LoginId");
            if (loginId == null) return Content("null");

            using (var sql = new BSqlRawCommander(comType: System.Data.CommandType.StoredProcedure))
            {
                sql.AddWithValue("login", loginId);
                sql.AddWithValue("statementId", statementId);
                return Content(sql.ExecuteScalar("sp_flip_"+ id ).CStr());
            }
        }




        public static Statement stm;

        [HttpPost]
        public IActionResult AddView([FromBody] int[] statementIds)
        {
            if (statementIds?.Any() == false)
                return Content("0");

            using (var sql = new BSqlRawCommander( comType: System.Data.CommandType.StoredProcedure))
            {
                var par = statementIds.ToSqlParameter("@statements"); 
                sql.Com.Parameters.Add(par);
                sql.AddWithValue("@userId", Session.GetInt32("LoginId") );

                return Content( sql.ExecuteNonQuery("sp_register_views", reset: false ).CStr() );

            }

        }


        [ResponseCache(Duration = 2600000, VaryByQueryKeys = new[] { "id" }, Location = ResponseCacheLocation.Client)]
        public ActionResult Photo(int? id = 0) { 
            using (var sql = new BSqlCommander())
            {
                var imageData = id.Value.LoadEntity<Photo>();

                return File(imageData.Data, "image/jpeg");
            }
        }


        [ResponseCache(Duration = 2600000, VaryByQueryKeys = new[] { "id" }, Location = ResponseCacheLocation.Client)]
        public ActionResult Thumb(int? id = 0)
        {
            using (var sql = new BSqlCommander())
            {
                var imageData = id.Value.LoadEntity<Photo>();

                return File(imageData.Thumb, "image/jpeg");
            }
        }

        public ActionResult Partial( string id ) => PartialView( $"~/Views/{id}.cshtml" );

    }

}