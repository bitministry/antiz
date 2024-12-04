using Microsoft.AspNetCore.Mvc.Razor;
using Microsoft.AspNetCore.Http;


namespace antiz.mvc
{
    public class ViewHelpers
    {
    }



    public abstract class BaseViewPage<TModel> : RazorPage<TModel>
    {
        public ISession Session => ViewContext.HttpContext.Session;
    }


}