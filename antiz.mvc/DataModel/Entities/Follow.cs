using BitMinistry;
using System;

namespace antiz.mvc
{
    public class Follow : IEntity {

        public int UserId { get; set; }

        public int TargetId { get; set; }
    }

}