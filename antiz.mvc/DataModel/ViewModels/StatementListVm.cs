using System.Collections.Generic;

namespace antiz.mvc
{
    public class StatementListVm 
    {
        public int? LoadMoreFrom { get; set; }

        public AddPostVm AddPostVm { get; set; }
        public IEnumerable<ft_StatementWithStats> Content { get; set; } = new ft_StatementWithStats[0];

        public Dictionary<int, vStatement> ReplyParents { get; set; }

    }

}
