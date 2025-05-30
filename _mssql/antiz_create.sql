USE [master]
GO
/****** Object:  Database [antiz]    Script Date: 12/5/2024 12:52:54 AM ******/
CREATE DATABASE [antiz]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'antiz', FILENAME = N'd:\SqlData\antiz.mdf' , SIZE = 4096KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'antiz_log', FILENAME = N'd:\SqlData\antiz_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [antiz] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [antiz].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [antiz] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [antiz] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [antiz] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [antiz] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [antiz] SET ARITHABORT OFF 
GO
ALTER DATABASE [antiz] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [antiz] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [antiz] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [antiz] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [antiz] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [antiz] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [antiz] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [antiz] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [antiz] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [antiz] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [antiz] SET  DISABLE_BROKER 
GO
ALTER DATABASE [antiz] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [antiz] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [antiz] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [antiz] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [antiz] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [antiz] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [antiz] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [antiz] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [antiz] SET  MULTI_USER 
GO
ALTER DATABASE [antiz] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [antiz] SET DB_CHAINING OFF 
GO
ALTER DATABASE [antiz] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [antiz] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [antiz]
GO
/****** Object:  User [antiz]    Script Date: 12/5/2024 12:52:54 AM ******/
CREATE USER [antiz] FOR LOGIN [antiz] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [antiz]
GO
/****** Object:  Schema [bm]    Script Date: 12/5/2024 12:52:54 AM ******/
CREATE SCHEMA [bm]
GO
/****** Object:  UserDefinedTableType [dbo].[intarray]    Script Date: 12/5/2024 12:52:54 AM ******/
CREATE TYPE [dbo].[intarray] AS TABLE(
	[id] [int] NOT NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[stringarray]    Script Date: 12/5/2024 12:52:54 AM ******/
CREATE TYPE [dbo].[stringarray] AS TABLE(
	[id] [varchar](111) NOT NULL
)
GO
/****** Object:  StoredProcedure [dbo].[sp_flip_like]    Script Date: 12/5/2024 12:52:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_flip_like] @login int, @statementid int 
as 

declare @count int = 1 
if not exists ( select * from SLike where UserId = @login and StatementId = @statementid  )
	insert into Slike ( UserId, StatementId) values ( @login, @statementid )
else
begin 
	delete from SLike where UserId = @login and StatementId = @statementid  
	set @count = -1 
end 
	
update Statement set LikeCount = LikeCount + @count where StatementId = @statementid  

select @count 
GO
/****** Object:  StoredProcedure [dbo].[sp_flip_repost]    Script Date: 12/5/2024 12:52:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_flip_repost] @login int, @statementid int 
as 

declare @count int = 1 
if not exists ( select * from Repost where UserId = @login and StatementId = @statementid  )
	insert into Repost ( UserId, StatementId) values ( @login, @statementid )
else
begin 
	delete from Repost where UserId = @login and StatementId = @statementid  
	set @count = -1 
end 
	
update Statement set RepostCount  = RepostCount + @count where StatementId = @statementid  

select @count 
GO
/****** Object:  StoredProcedure [dbo].[sp_home]    Script Date: 12/5/2024 12:52:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  proc [dbo].[sp_home] @login int, @offset int, @pagesize int 
as 

declare @currep bigint 

set @currep = dbo.fEpochFromDateTime( getdate())


select * 
from vStatementWithStats s

where 
        ISNULL(LikeUserId, @login) = @login
    and ISNULL(RepostUserId, @login) = @login

ORDER BY 
    ( select count(*) from StatementShown ss where ss.TargetStatementId = s.StatementId and ViewerId = @login and Epoch < ( @currep - 600 ) ),                                   
    (
			dbo.calculateViewScore( s.ViewCount ) * 0.33			-- views 
			+ dbo.calculateViewScore( LikeCount )* 0.66			-- likes x 3
			+ dbo.calculateViewScore( ReplyCount ) 				-- likes x 3
		- dbo.calculateAgePenalty( (@currep - Epoch)/60 ) *3	-- minute based 

--- MORE AT desmos.com 

		) 

OFFSET @offset ROWS FETCH NEXT @pagesize ROWS ONLY


GO
/****** Object:  StoredProcedure [dbo].[sp_mentions]    Script Date: 12/5/2024 12:52:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[sp_mentions] @userId int, @query nvarchar(22)
as 




select AvatarId, Name, Username from Appuser where Username like  @query + '%' 




GO
/****** Object:  StoredProcedure [dbo].[sp_register_views]    Script Date: 12/5/2024 12:52:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_register_views] @statements intarray readonly, @userid int 
as 

insert into StatementShown( TargetStatementId, ViewerId ) 
select id, isnull( @userid , -1 ) from @statements 

UPDATE t SET t.ViewCount = t.ViewCount+ 1 
FROM Statement t 
INNER JOIN @statements tt ON t.StatementId = tt.id;
GO
/****** Object:  StoredProcedure [dbo].[sp_replies]    Script Date: 12/5/2024 12:52:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[sp_replies] @statementid int, @login int, @offset int, @pagesize int 
as 
	
declare @currep bigint 

set @login = isnull( @login, -1 )
set @currep = dbo.fEpochFromDateTime( getdate())

select * 
from vStatementWithStats s

where 
        ReplyTo = @statementid
    and ISNULL(LikeUserId, @login) = @login
    and ISNULL(RepostUserId, @login) = @login


ORDER BY 
    ( select count(*) from StatementShown ss where ss.TargetStatementId = s.StatementId and ViewerId = @login and Epoch < ( @currep - 600 ) ),
    (
			dbo.calculateViewScore( s.ViewCount ) * 0.33			-- views 
			+ dbo.calculateViewScore( LikeCount )* 0.66			-- likes x 3
			+ dbo.calculateViewScore( ReplyCount ) 				-- likes x 3
		- dbo.calculateAgePenalty( (@currep - Epoch)/60 ) *3	-- minute based 

--- MORE AT desmos.com 

		) 

OFFSET @offset ROWS FETCH NEXT @pagesize ROWS ONLY
GO
/****** Object:  StoredProcedure [dbo].[sp_usertimeline]    Script Date: 12/5/2024 12:52:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




create proc [dbo].[sp_usertimeline] @authorid int, @case varchar(11), @login int, @offset int, @pagesize int 
as 
	
declare @currep bigint 

set @login = isnull( @login, -1 )
set @currep = dbo.fEpochFromDateTime( getdate())

select * 
from vStatementWithStats s

where 
	AuthorId = @authorid
	and	IsHighlight = case when @case = 'Highlights' then 1 else IsHighlight end
	and ((@case = 'Replies' AND ReplyTo IS NOT NULL) OR (@case != 'Replies' AND ReplyTo IS NULL) )
    and ISNULL(LikeUserId, @login) = @login
    and ISNULL(RepostUserId, @login) = @login


ORDER BY 
    ( select count(*) from StatementShown ss where ss.TargetStatementId = s.StatementId and ViewerId = @login and Epoch < ( @currep - 600 ) ),
    (
			dbo.calculateViewScore( s.ViewCount ) * 0.33			-- views 
			+ dbo.calculateViewScore( LikeCount )* 0.66			-- likes x 3
			+ dbo.calculateViewScore( ReplyCount ) 				-- likes x 3
		- dbo.calculateAgePenalty( (@currep - Epoch)/60 ) *3	-- minute based 

--- MORE AT desmos.com 

		) 

OFFSET @offset ROWS FETCH NEXT @pagesize ROWS ONLY
GO
/****** Object:  UserDefinedFunction [dbo].[calculateAgePenalty]    Script Date: 12/5/2024 12:52:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[calculateAgePenalty]
(
    @x FLOAT 
)
RETURNS FLOAT
AS
BEGIN
    DECLARE @result FLOAT;

    -- Implement the formula
    SET @result = -(POWER((@x + 35000) / 400, 2)) + 7656;

    RETURN @result;
END;

GO
/****** Object:  UserDefinedFunction [dbo].[calculateViewScore]    Script Date: 12/5/2024 12:52:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[calculateViewScore]
(
    @input FLOAT 
)
RETURNS FLOAT
AS
BEGIN
    DECLARE @score FLOAT;

    -- Calculate the score using the provided formula
    SET @score = 100000 * (LOG(@input + 40000) / LOG(2)) - 1528772;

    RETURN @score;
END;

GO
/****** Object:  UserDefinedFunction [dbo].[fDateTimeFromEpoch]    Script Date: 12/5/2024 12:52:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [dbo].[fDateTimeFromEpoch] (@epoch_sec bigINT)
RETURNS DATETIME
AS
BEGIN
    return CONVERT(DATETIME, DATEADD(SECOND, @epoch_sec, '19700101 00:00:00'), 120)
END

GO
/****** Object:  UserDefinedFunction [dbo].[fEpochFromDateTime]    Script Date: 12/5/2024 12:52:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [dbo].[fEpochFromDateTime] (@datt DATEtime)
RETURNS bigint
AS
BEGIN
    return 	CAST(DATEDIFF(s, '19700101', @datt) AS BIGINT) 
END;


GO
/****** Object:  Table [bm].[Setting]    Script Date: 12/5/2024 12:52:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [bm].[Setting](
	[Name] [varchar](50) NOT NULL,
	[NumericValue] [numeric](14, 2) NULL,
	[NTextValue] [ntext] NULL,
	[DateTimeValue] [datetime] NULL,
	[Comment] [varchar](111) NULL,
 CONSTRAINT [PK_Setting] PRIMARY KEY CLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AppUser]    Script Date: 12/5/2024 12:52:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AppUser](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[Username] [varchar](33) NOT NULL,
	[Password] [varchar](22) NOT NULL,
	[Name] [nvarchar](66) NULL,
	[Bio] [varchar](444) NULL,
	[AvatarId] [int] NULL,
	[CoverId] [int] NULL,
	[Email] [nvarchar](111) NOT NULL,
	[Landline] [bigint] NULL,
	[Mobile] [bigint] NULL,
	[Website] [nvarchar](111) NULL,
	[Skype] [nvarchar](111) NULL,
	[Viber] [nvarchar](111) NULL,
	[Whatsapp] [nvarchar](111) NULL,
	[Telegram] [nvarchar](111) NULL,
	[Instagram] [nvarchar](111) NULL,
	[TikTok] [nvarchar](111) NULL,
	[Facebook] [nvarchar](111) NULL,
	[LinkedIn] [nvarchar](111) NULL,
	[Vimeo] [nvarchar](111) NULL,
	[Rumble] [nvarchar](111) NULL,
	[Twitter] [nvarchar](111) NULL,
	[YouTube] [nvarchar](111) NULL,
	[Joined] [date] NOT NULL,
	[EmailVerificationCode] [int] NOT NULL,
	[NuEmail] [varchar](111) NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Follow]    Script Date: 12/5/2024 12:52:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Follow](
	[UserId] [int] NOT NULL,
	[TargetId] [int] NOT NULL,
	[Created] [timestamp] NOT NULL,
 CONSTRAINT [PK_Follow] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[TargetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Photo]    Script Date: 12/5/2024 12:52:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Photo](
	[PhotoId] [int] IDENTITY(1,1) NOT NULL,
	[Data] [varbinary](max) NOT NULL,
 CONSTRAINT [PK_Photo] PRIMARY KEY CLUSTERED 
(
	[PhotoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Repost]    Script Date: 12/5/2024 12:52:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Repost](
	[UserId] [int] NOT NULL,
	[StatementId] [int] NOT NULL,
	[Epoch] [bigint] NOT NULL,
 CONSTRAINT [PK_Repost] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[StatementId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SLike]    Script Date: 12/5/2024 12:52:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SLike](
	[UserId] [int] NOT NULL,
	[StatementId] [int] NOT NULL,
	[Timestamp] [timestamp] NULL,
 CONSTRAINT [PK_Like] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[StatementId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Statement]    Script Date: 12/5/2024 12:52:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Statement](
	[StatementId] [int] IDENTITY(1,1) NOT NULL,
	[AuthorId] [int] NOT NULL,
	[Message] [nvarchar](max) NOT NULL,
	[RenderedMessage] [ntext] NULL,
	[SocialNet] [varchar](11) NULL,
	[ReplyTo] [int] NULL,
	[ViewCount] [int] NULL,
	[LikeCount] [int] NULL,
	[ReplyCount] [int] NULL,
	[RepostCount] [int] NULL,
	[IsHighlight] [bit] NOT NULL,
	[Pinned] [tinyint] NULL,
	[Epoch] [bigint] NOT NULL,
 CONSTRAINT [PK_Statement] PRIMARY KEY CLUSTERED 
(
	[StatementId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[StatementShown]    Script Date: 12/5/2024 12:52:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StatementShown](
	[TargetStatementId] [int] NOT NULL,
	[ViewerId] [int] NOT NULL,
	[Epoch] [bigint] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[vStatement]    Script Date: 12/5/2024 12:52:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE view [dbo].[vStatement] 
as 
select s.*, 
	Created = dbo.fDateTimeFromEpoch( Epoch ), 
	Username, 
	Name, 
	AvatarId 
	from Statement s 
		join AppUser u on u.UserId = s.AuthorId  







GO
/****** Object:  View [dbo].[vStatementWithStats]    Script Date: 12/5/2024 12:52:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vStatementWithStats] 
as 

select s.*, 
	LikeUserId = l.UserId, 
	RepostUserId = r.UserId 
from vStatement s 
	left outer join SLike l on s.StatementId = l.StatementId 
	left outer join Repost r on s.StatementId = r.StatementId 



GO
/****** Object:  View [dbo].[vAppUser]    Script Date: 12/5/2024 12:52:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[vAppUser] 
as 
select *,
	IamFollowingCount = (select count(*) from Follow f where f.UserId = u.UserId ),
	PeopleFollowMeCount= (select count(*) from Follow f where f.TargetId = u.UserId )
	from AppUser u



GO
/****** Object:  View [dbo].[vStatementShown]    Script Date: 12/5/2024 12:52:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vStatementShown]
as 
select TargetStatementId, ViewerId, ViewCount = count(*) from StatementShown group by TargetStatementId, ViewerId

GO
ALTER TABLE [dbo].[AppUser] ADD  CONSTRAINT [DF_AppUser_Joined]  DEFAULT (getdate()) FOR [Joined]
GO
ALTER TABLE [dbo].[Repost] ADD  CONSTRAINT [DF_Repost_Created]  DEFAULT ([dbo].[fEpochFromDateTime](getdate())) FOR [Epoch]
GO
ALTER TABLE [dbo].[Statement] ADD  CONSTRAINT [DF_Statement_IsHighlight]  DEFAULT ((0)) FOR [IsHighlight]
GO
ALTER TABLE [dbo].[Statement] ADD  CONSTRAINT [DF_Statement_Epoch]  DEFAULT ([dbo].[fEpochFromDateTime](getdate())) FOR [Epoch]
GO
ALTER TABLE [dbo].[StatementShown] ADD  CONSTRAINT [DF_StatementShown_Epoch]  DEFAULT ([dbo].[fEpochFromDateTime](getdate())) FOR [Epoch]
GO
ALTER TABLE [dbo].[AppUser]  WITH CHECK ADD  CONSTRAINT [FK_AppUser_Photo] FOREIGN KEY([AvatarId])
REFERENCES [dbo].[Photo] ([PhotoId])
GO
ALTER TABLE [dbo].[AppUser] CHECK CONSTRAINT [FK_AppUser_Photo]
GO
ALTER TABLE [dbo].[AppUser]  WITH CHECK ADD  CONSTRAINT [FK_AppUser_Photo1] FOREIGN KEY([CoverId])
REFERENCES [dbo].[Photo] ([PhotoId])
GO
ALTER TABLE [dbo].[AppUser] CHECK CONSTRAINT [FK_AppUser_Photo1]
GO
ALTER TABLE [dbo].[Follow]  WITH CHECK ADD  CONSTRAINT [FK_Follow_AppUser] FOREIGN KEY([UserId])
REFERENCES [dbo].[AppUser] ([UserId])
GO
ALTER TABLE [dbo].[Follow] CHECK CONSTRAINT [FK_Follow_AppUser]
GO
ALTER TABLE [dbo].[Follow]  WITH CHECK ADD  CONSTRAINT [FK_Follow_AppUser1] FOREIGN KEY([TargetId])
REFERENCES [dbo].[AppUser] ([UserId])
GO
ALTER TABLE [dbo].[Follow] CHECK CONSTRAINT [FK_Follow_AppUser1]
GO
ALTER TABLE [dbo].[Repost]  WITH CHECK ADD  CONSTRAINT [FK_Repost_AppUser] FOREIGN KEY([UserId])
REFERENCES [dbo].[AppUser] ([UserId])
GO
ALTER TABLE [dbo].[Repost] CHECK CONSTRAINT [FK_Repost_AppUser]
GO
ALTER TABLE [dbo].[Repost]  WITH CHECK ADD  CONSTRAINT [FK_Repost_Statement] FOREIGN KEY([StatementId])
REFERENCES [dbo].[Statement] ([StatementId])
GO
ALTER TABLE [dbo].[Repost] CHECK CONSTRAINT [FK_Repost_Statement]
GO
ALTER TABLE [dbo].[SLike]  WITH CHECK ADD  CONSTRAINT [FK_SLike_AppUser] FOREIGN KEY([UserId])
REFERENCES [dbo].[AppUser] ([UserId])
GO
ALTER TABLE [dbo].[SLike] CHECK CONSTRAINT [FK_SLike_AppUser]
GO
ALTER TABLE [dbo].[Statement]  WITH CHECK ADD  CONSTRAINT [FK_Statement_AppUser] FOREIGN KEY([AuthorId])
REFERENCES [dbo].[AppUser] ([UserId])
GO
ALTER TABLE [dbo].[Statement] CHECK CONSTRAINT [FK_Statement_AppUser]
GO
ALTER TABLE [dbo].[Statement]  WITH CHECK ADD  CONSTRAINT [FK_Statement_Statement] FOREIGN KEY([ReplyTo])
REFERENCES [dbo].[Statement] ([StatementId])
GO
ALTER TABLE [dbo].[Statement] CHECK CONSTRAINT [FK_Statement_Statement]
GO
USE [master]
GO
ALTER DATABASE [antiz] SET  READ_WRITE 
GO
