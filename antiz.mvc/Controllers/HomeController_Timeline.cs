using BitMinistry;
using BitMinistry.Data.Wrapper;
using BitMinistry.Utility;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using System;
using System.Data;
using System.Threading.Tasks;

namespace antiz.mvc
{
    public partial class HomeController : Controller
    {
        AppUserService _userService;
        StatementService _statementServ;
        ISession Session => HttpContext.Session;

        public HomeController() {
            _userService = new AppUserService();
            _statementServ = new StatementService();
        }


        public ActionResult Index( int? loadMoreFrom )
        {
            var model = _statementServ
                .GetStatementListVm(
                    loginId: Session.GetInt32("LoginId") ?? -1,
                    sqlProc: "sp_home",
                    loadMoreFrom: loadMoreFrom);

            if (loadMoreFrom != null )
                return PartialView("_StatementList", model);
            else
                return View("_StatementList", model);


        }



        [HttpPost]
        public ActionResult Post(Statement comment)
        {
            Session.GetString("UserId").ThrowIfNull();

            if (comment.StatementId != null)
            { 
                var exist = comment.StatementId.Value.LoadEntity<Statement>();
                if ( exist.AuthorId != Session.GetInt32("LoginId"))
                    throw new UnauthorizedAccessException("not your comment!");
            }                

            comment.AuthorId = Session.GetInt32("LoginId").Value;

            var model = _statementServ.Post( comment );


            return RedirectToAction("Post", new { id = model.ReplyTo ?? model.StatementId  }) ;
        }

        [HttpGet]
        public ActionResult Post(int id, int? loadMoreFrom ) {

            var loginId = Session.GetInt32("LoginId") ?? -1;

            var model = _statementServ.vStatementWithStats( statementId: id, loginId: loginId) 
                .GetClone<PostVm>();
            model.LoadMoreFrom = loadMoreFrom; 

            model.LoadParentsAndReplies(loginId);
            
            return model.LoadMoreFrom != null ?
                PartialView("_StatementList", model.StatementListVm) : 
                View( model );
        }


        public PartialViewResult EditStatement(int id) {
            var model = id.LoadEntity<Statement>();
            return PartialView( "_AddPostForm", model );
        }

        public override void OnActionExecuting(ActionExecutingContext context)
        {
            var isModal = context.HttpContext.Request.Query["isModal"];
            if (isModal == "true")
            {
                ViewBag.isModal = true; ViewData["isModal"] = true;
            }

            base.OnActionExecuting(context);
        }

    
        // [Route("Error")]
        public IActionResult Error(Exception ex)
        {
            var model = new ExceptionVm
            {
                ExceptionMessage = ex.Message,
                StackTrace = ex.StackTrace
            };

            return View(model);
        }


    }

}