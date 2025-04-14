using BitMinistry;
using Microsoft.AspNetCore.Http;
using System;

namespace antiz.mvc
{
    public class Statement : IEntity {

        [BEntityId(Seed = true)]
        public int? StatementId { get; set; }
        public int? ReplyTo { get; set; }
        public int AuthorId { get; set; }
        public string Message { get; set; }
        public string RenderedMessage { get; set; }
        public SocialNet? SocialNet { get; set; }
        public bool IsHighlight { get; set; }
        public int ViewCount { get; set; }
        public int LikeCount { get; set; }
        public int ReplyCount { get; set; }
        public int RepostCount { get; set; }

        public int? PhotoId { get; set; }

        [BSqlIgnore]
        public IFormFile File { get; set; }

    }

    public enum SocialNet { Twitter, TikTok, YouTube, Facebook, Instagram, Rumble, Vimeo }

}