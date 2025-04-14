using BitMinistry;
using System;

namespace antiz.mvc
{
    public class Photo : IEntity {

        [BEntityId(Seed = true)]
        public int PhotoId { get; set; }

        public byte[] Data { get; set; }
        public byte[] Thumb { get; set; }
    }

}