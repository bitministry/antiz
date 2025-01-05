using BitMinistry.Data.Wrapper;
using BitMinistry.Utility;
using System.Collections.Generic;
using System.Data;
using System.Linq;

namespace antiz.mvc
{
    public class PostVm : ft_StatementWithStats
    {

        public PostVm() { }

        public PostVm Parent { get; set; }
        public PostVm Child { get; set; }

        public int? LoadMoreFrom { get; internal set; }
        public StatementListVm StatementListVm { get; set; }

        public void LoadParentsAndReplies( int loginId )
        {
            LoadParents();

            StatementListVm = ReplyCount == 0 ?
                new StatementListVm() { 
                    AddPostVm = new AddPostVm()
                } :
                new StatementService()
                    .GetStatementListVm(
                        loginId: loginId,
                        sqlProc: "sp_replies", 
                        loadMoreFrom: LoadMoreFrom, 
                        ("@statementid", StatementId ));

            StatementListVm.AddPostVm.ReplyTo = StatementId;

        }



        void LoadParents()
        {
            if (ReplyTo != null && LoadMoreFrom == null )
            {
                Parent = ReplyTo.Value.LoadEntity<vStatement>().GetClone<PostVm>();
                Parent.LoadParents();
                Parent.Child = this;
            }
        }


    }

}

