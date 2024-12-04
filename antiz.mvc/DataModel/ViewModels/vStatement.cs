using BitMinistry.Utility;
using Microsoft.AspNetCore.Http;
using System;
using System.Text.RegularExpressions;

namespace antiz.mvc
{
    public class vStatementWithStats  : vStatement{
        public int? LikeUserId { get; set; }
        public int? RepostUserId { get; set; }
    }

    public class vStatement : Statement
    {
        public DateTime? Created { get; set; }
        public string Username { get; set; }
        public string Name { get; set; }
        public int AvatarId { get; set; }

    }

}
