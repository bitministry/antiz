using System.Collections.Generic;

namespace antiz.mvc
{
    public class StatementListVm 
    {
        public int? LoadMoreFrom { get; set; }

        public AddPostVm AddPostVm { get; set; }
        public IEnumerable<vStatementWithStats> Content { get; set; } = new vStatementWithStats[0];

    }

}
