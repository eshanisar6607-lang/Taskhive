/* ============================================================ 
   TASKHIVE DATABASE 
   SQL SERVER DATABASE SCRIPT 
   ============================================================ */ 
 
USE master; 
GO 
 
/* ------------------------------------------------------------ 
   1. CREATE DATABASE 
   ------------------------------------------------------------ */ 
 
IF DB_ID(N'TaskHiveDB') IS NULL 
BEGIN 
    CREATE DATABASE TaskHiveDB; 
END 
GO 
 
USE TaskHiveDB; 
GO 
 
/* ============================================================ 
   2. USERS 
   ============================================================ */ 
 
CREATE TABLE dbo.Users 
( 
    UserId          UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_Users PRIMARY KEY 
        DEFAULT NEWID(), 
 
    FullName        NVARCHAR(100) NOT NULL, 
 
    Email           NVARCHAR(255) NOT NULL, 
 
    PasswordHash    NVARCHAR(500) NOT NULL, 
 
    ProfileImageUrl NVARCHAR(500) NULL, 
 
    CreatedAt       DATETIME2(0) NOT NULL 
        CONSTRAINT DF_Users_CreatedAt DEFAULT SYSUTCDATETIME(), 
 
    UpdatedAt       DATETIME2(0) NULL, 
 
    IsActive        BIT NOT NULL 
        CONSTRAINT DF_Users_IsActive DEFAULT 1, 
 
    CONSTRAINT UQ_Users_Email UNIQUE (Email) 
); 
GO 
 
 
/* ============================================================ 
   3. WORKSPACES 
   ============================================================ */ 
 
CREATE TABLE dbo.Workspaces 
( 
    WorkspaceId     UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_Workspaces PRIMARY KEY 
        DEFAULT NEWID(), 
 
    Name            NVARCHAR(150) NOT NULL, 
 
    Description     NVARCHAR(500) NULL, 
 
    OwnerId         UNIQUEIDENTIFIER NOT NULL, 
 
    CreatedAt       DATETIME2(0) NOT NULL 
        CONSTRAINT DF_Workspaces_CreatedAt DEFAULT SYSUTCDATETIME(), 
 
    UpdatedAt       DATETIME2(0) NULL, 
 
    IsActive        BIT NOT NULL 
        CONSTRAINT DF_Workspaces_IsActive DEFAULT 1, 
 
    CONSTRAINT FK_Workspaces_Owner 
        FOREIGN KEY (OwnerId) 
        REFERENCES dbo.Users(UserId) 
); 
GO 
 
 
/* ============================================================ 
   4. WORKSPACE MEMBERS 
   ============================================================ */ 
 
CREATE TABLE dbo.WorkspaceMembers 
( 
    WorkspaceMemberId UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_WorkspaceMembers PRIMARY KEY 
        DEFAULT NEWID(), 
 
    WorkspaceId       UNIQUEIDENTIFIER NOT NULL, 
 
    UserId            UNIQUEIDENTIFIER NOT NULL, 
 
    Role              NVARCHAR(20) NOT NULL 
        CONSTRAINT DF_WorkspaceMembers_Role DEFAULT N'MEMBER', 
 
    JoinedAt          DATETIME2(0) NOT NULL 
        CONSTRAINT DF_WorkspaceMembers_JoinedAt DEFAULT SYSUTCDATETIME(), 
 
    CONSTRAINT FK_WorkspaceMembers_Workspace 
        FOREIGN KEY (WorkspaceId) 
        REFERENCES dbo.Workspaces(WorkspaceId) 
        ON DELETE CASCADE, 
 
    CONSTRAINT FK_WorkspaceMembers_User 
        FOREIGN KEY (UserId) 
        REFERENCES dbo.Users(UserId) 
        ON DELETE CASCADE, 
 
    CONSTRAINT UQ_WorkspaceMembers_Workspace_User 
        UNIQUE (WorkspaceId, UserId), 
 
    CONSTRAINT CK_WorkspaceMembers_Role 
        CHECK (Role IN (N'OWNER', N'ADMIN', N'MEMBER')) 
); 
GO 
 
 
/* ============================================================ 
   5. PROJECTS 
   ============================================================ */ 
 
CREATE TABLE dbo.Projects 
( 
    ProjectId       UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_Projects PRIMARY KEY 
        DEFAULT NEWID(), 
 
    WorkspaceId     UNIQUEIDENTIFIER NOT NULL, 
 
    Name            NVARCHAR(150) NOT NULL, 
 
    Description     NVARCHAR(1000) NULL, 
 
    Status          NVARCHAR(30) NOT NULL 
        CONSTRAINT DF_Projects_Status DEFAULT N'PLANNING', 
 
    Progress        TINYINT NOT NULL 
        CONSTRAINT DF_Projects_Progress DEFAULT 0, 
 
    StartDate       DATE NULL, 
 
    DueDate         DATE NULL, 
 
    CreatedBy       UNIQUEIDENTIFIER NOT NULL, 
 
    CreatedAt       DATETIME2(0) NOT NULL 
        CONSTRAINT DF_Projects_CreatedAt DEFAULT SYSUTCDATETIME(), 
 
    UpdatedAt       DATETIME2(0) NULL, 
 
    CONSTRAINT FK_Projects_Workspace 
        FOREIGN KEY (WorkspaceId) 
        REFERENCES dbo.Workspaces(WorkspaceId) 
        ON DELETE CASCADE, 
 
    CONSTRAINT FK_Projects_CreatedBy 
        FOREIGN KEY (CreatedBy) 
        REFERENCES dbo.Users(UserId), 
 
    CONSTRAINT CK_Projects_Status 
        CHECK 
        ( 
            Status IN 
            ( 
                N'PLANNING', 
                N'IN_PROGRESS', 
                N'ON_HOLD', 
                N'COMPLETED' 
            ) 
        ), 
 
    CONSTRAINT CK_Projects_Progress 
        CHECK (Progress BETWEEN 0 AND 100), 
 
    CONSTRAINT CK_Projects_Dates 
        CHECK 
        ( 
            DueDate IS NULL 
            OR StartDate IS NULL 
            OR DueDate >= StartDate 
        ) 
); 
GO 
 
 
/* ============================================================ 
   6. PROJECT MEMBERS 
   ============================================================ */ 
 
CREATE TABLE dbo.ProjectMembers 
( 
    ProjectMemberId UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_ProjectMembers PRIMARY KEY 
        DEFAULT NEWID(), 
 
    ProjectId       UNIQUEIDENTIFIER NOT NULL, 
 
    UserId          UNIQUEIDENTIFIER NOT NULL, 
 
    JoinedAt        DATETIME2(0) NOT NULL 
        CONSTRAINT DF_ProjectMembers_JoinedAt DEFAULT SYSUTCDATETIME(), 
 
    CONSTRAINT FK_ProjectMembers_Project 
        FOREIGN KEY (ProjectId) 
        REFERENCES dbo.Projects(ProjectId) 
        ON DELETE CASCADE, 
 
    CONSTRAINT FK_ProjectMembers_User 
        FOREIGN KEY (UserId) 
        REFERENCES dbo.Users(UserId) 
        ON DELETE CASCADE, 
 
    CONSTRAINT UQ_ProjectMembers_Project_User 
        UNIQUE (ProjectId, UserId) 
); 
GO 
 
 
/* ============================================================ 
   7. TASKS 
   ============================================================ */ 
 
CREATE TABLE dbo.Tasks 
( 
    TaskId          UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_Tasks PRIMARY KEY 
        DEFAULT NEWID(), 
 
    ProjectId       UNIQUEIDENTIFIER NOT NULL, 
 
    Title           NVARCHAR(200) NOT NULL, 
 
    Description     NVARCHAR(MAX) NULL, 
 
    AssignedTo      UNIQUEIDENTIFIER NULL, 
 
    CreatedBy       UNIQUEIDENTIFIER NOT NULL, 
 
    Status          NVARCHAR(30) NOT NULL 
        CONSTRAINT DF_Tasks_Status DEFAULT N'TODO', 
 
    Priority        NVARCHAR(20) NOT NULL 
        CONSTRAINT DF_Tasks_Priority DEFAULT N'MEDIUM', 
 
    DueDate         DATETIME2(0) NULL, 
 
    CreatedAt       DATETIME2(0) NOT NULL 
        CONSTRAINT DF_Tasks_CreatedAt DEFAULT SYSUTCDATETIME(), 
 
    UpdatedAt       DATETIME2(0) NULL, 
 
    CompletedAt     DATETIME2(0) NULL, 
 
    CONSTRAINT FK_Tasks_Project 
        FOREIGN KEY (ProjectId) 
        REFERENCES dbo.Projects(ProjectId) 
        ON DELETE CASCADE, 
 
    CONSTRAINT FK_Tasks_AssignedTo 
        FOREIGN KEY (AssignedTo) 
        REFERENCES dbo.Users(UserId), 
 
    CONSTRAINT FK_Tasks_CreatedBy 
        FOREIGN KEY (CreatedBy) 
        REFERENCES dbo.Users(UserId), 
 
    CONSTRAINT CK_Tasks_Status 
        CHECK 
        ( 
            Status IN 
            ( 
                N'BACKLOG', 
                N'TODO', 
                N'IN_PROGRESS', 
                N'REVIEW', 
                N'COMPLETED' 
            ) 
        ), 
 
    CONSTRAINT CK_Tasks_Priority 
        CHECK 
        ( 
            Priority IN 
            ( 
                N'LOW', 
                N'MEDIUM', 
                N'HIGH', 
                N'URGENT' 
            ) 
        ) 
); 
GO 
 
 
/* ============================================================ 
   8. COMMENTS 
   ============================================================ */ 
 
CREATE TABLE dbo.Comments 
( 
    CommentId       UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_Comments PRIMARY KEY 
        DEFAULT NEWID(), 
 
    TaskId          UNIQUEIDENTIFIER NOT NULL, 
 
    UserId          UNIQUEIDENTIFIER NOT NULL, 
 
    CommentText     NVARCHAR(MAX) NOT NULL, 
 
    CreatedAt       DATETIME2(0) NOT NULL 
        CONSTRAINT DF_Comments_CreatedAt DEFAULT SYSUTCDATETIME(), 
 
    UpdatedAt       DATETIME2(0) NULL, 
 
    CONSTRAINT FK_Comments_Task 
        FOREIGN KEY (TaskId) 
        REFERENCES dbo.Tasks(TaskId) 
        ON DELETE CASCADE, 
 
    CONSTRAINT FK_Comments_User 
        FOREIGN KEY (UserId) 
        REFERENCES dbo.Users(UserId) 
); 
GO 
 
 
/* ============================================================ 
   9. TASK LABELS 
   ============================================================ */ 
 
CREATE TABLE dbo.TaskLabels 
( 
    LabelId         UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_TaskLabels PRIMARY KEY 
        DEFAULT NEWID(), 
 
    ProjectId       UNIQUEIDENTIFIER NOT NULL, 
 
    Name            NVARCHAR(50) NOT NULL, 
 
    CreatedAt       DATETIME2(0) NOT NULL 
        CONSTRAINT DF_TaskLabels_CreatedAt DEFAULT SYSUTCDATETIME(), 
 
    CONSTRAINT FK_TaskLabels_Project 
        FOREIGN KEY (ProjectId) 
        REFERENCES dbo.Projects(ProjectId) 
        ON DELETE CASCADE, 
 
    CONSTRAINT UQ_TaskLabels_Project_Name 
        UNIQUE (ProjectId, Name) 
); 
GO 
 
 
/* ============================================================ 
   10. TASK ↔ LABEL RELATIONSHIP 
   ============================================================ */ 
 
CREATE TABLE dbo.TaskLabelMappings 
( 
    TaskId          UNIQUEIDENTIFIER NOT NULL, 
 
    LabelId         UNIQUEIDENTIFIER NOT NULL, 
 
    CONSTRAINT PK_TaskLabelMappings 
        PRIMARY KEY (TaskId, LabelId), 
 
    CONSTRAINT FK_TaskLabelMappings_Task 
        FOREIGN KEY (TaskId) 
        REFERENCES dbo.Tasks(TaskId) 
        ON DELETE CASCADE, 
 
    CONSTRAINT FK_TaskLabelMappings_Label 
        FOREIGN KEY (LabelId) 
        REFERENCES dbo.TaskLabels(LabelId) 
        
); 
GO 
 
 
/* ============================================================ 
   11. INVITATIONS 
   ============================================================ */ 
 
CREATE TABLE dbo.Invitations 
( 
    InvitationId    UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_Invitations PRIMARY KEY 
        DEFAULT NEWID(), 
 
    WorkspaceId     UNIQUEIDENTIFIER NOT NULL, 
 
    Email           NVARCHAR(255) NOT NULL, 
 
    InvitedBy       UNIQUEIDENTIFIER NOT NULL, 
 
    Role            NVARCHAR(20) NOT NULL 
        CONSTRAINT DF_Invitations_Role DEFAULT N'MEMBER', 
 
    Status          NVARCHAR(20) NOT NULL 
        CONSTRAINT DF_Invitations_Status DEFAULT N'PENDING', 
 
    Token           UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT DF_Invitations_Token DEFAULT NEWID(), 
 
    ExpiresAt       DATETIME2(0) NOT NULL, 
 
    CreatedAt       DATETIME2(0) NOT NULL 
        CONSTRAINT DF_Invitations_CreatedAt DEFAULT SYSUTCDATETIME(), 
 
    CONSTRAINT FK_Invitations_Workspace 
        FOREIGN KEY (WorkspaceId) 
        REFERENCES dbo.Workspaces(WorkspaceId) 
        ON DELETE CASCADE, 
 
    CONSTRAINT FK_Invitations_InvitedBy 
        FOREIGN KEY (InvitedBy) 
        REFERENCES dbo.Users(UserId), 
 
    CONSTRAINT UQ_Invitations_Token 
        UNIQUE (Token), 
 
    CONSTRAINT CK_Invitations_Role 
        CHECK (Role IN (N'ADMIN', N'MEMBER')), 
 
    CONSTRAINT CK_Invitations_Status 
        CHECK 
        ( 
            Status IN 
            ( 
                N'PENDING', 
                N'ACCEPTED', 
                N'REVOKED', 
                N'EXPIRED' 
            ) 
        ) 
); 
GO 
 
 
/* ============================================================ 
   12. NOTIFICATIONS 
   ============================================================ */ 
 
CREATE TABLE dbo.Notifications 
( 
    NotificationId  UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_Notifications PRIMARY KEY 
        DEFAULT NEWID(), 
 
    UserId          UNIQUEIDENTIFIER NOT NULL, 
 
    Title           NVARCHAR(200) NOT NULL, 
 
    Message         NVARCHAR(1000) NOT NULL, 
 
    Type            NVARCHAR(50) NULL, 
 
    RelatedTaskId   UNIQUEIDENTIFIER NULL, 
 
    RelatedProjectId UNIQUEIDENTIFIER NULL, 
 
    IsRead          BIT NOT NULL 
        CONSTRAINT DF_Notifications_IsRead DEFAULT 0, 
 
    CreatedAt       DATETIME2(0) NOT NULL 
        CONSTRAINT DF_Notifications_CreatedAt DEFAULT SYSUTCDATETIME(), 
 
    CONSTRAINT FK_Notifications_User 
        FOREIGN KEY (UserId) 
        REFERENCES dbo.Users(UserId) 
        ON DELETE CASCADE, 
 
    CONSTRAINT FK_Notifications_Task 
        FOREIGN KEY (RelatedTaskId) 
        REFERENCES dbo.Tasks(TaskId), 
 
    CONSTRAINT FK_Notifications_Project 
        FOREIGN KEY (RelatedProjectId) 
        REFERENCES dbo.Projects(ProjectId) 
); 
GO 
 
 
/* ============================================================ 
   13. ACTIVITY LOGS 
   ============================================================ */ 
 
CREATE TABLE dbo.ActivityLogs 
( 
    ActivityLogId   UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_ActivityLogs PRIMARY KEY 
        DEFAULT NEWID(), 
 
    WorkspaceId     UNIQUEIDENTIFIER NOT NULL, 
 
    UserId          UNIQUEIDENTIFIER NOT NULL, 
 
    Action          NVARCHAR(100) NOT NULL, 
 
    EntityType      NVARCHAR(50) NULL, 
 
    EntityId        UNIQUEIDENTIFIER NULL, 
 
    Details         NVARCHAR(1000) NULL, 
 
    CreatedAt       DATETIME2(0) NOT NULL 
        CONSTRAINT DF_ActivityLogs_CreatedAt DEFAULT SYSUTCDATETIME(), 
 
    CONSTRAINT FK_ActivityLogs_Workspace 
        FOREIGN KEY (WorkspaceId) 
        REFERENCES dbo.Workspaces(WorkspaceId) 
        ON DELETE CASCADE, 
 
    CONSTRAINT FK_ActivityLogs_User 
        FOREIGN KEY (UserId) 
        REFERENCES dbo.Users(UserId) 
); 
GO 
 
 
/* ============================================================ 
   14. FILES 
   ============================================================ */ 
 
CREATE TABLE dbo.Files 
( 
    FileId          UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_Files PRIMARY KEY 
        DEFAULT NEWID(), 
 
    WorkspaceId     UNIQUEIDENTIFIER NOT NULL, 
 
    UploadedBy      UNIQUEIDENTIFIER NOT NULL, 
 
    TaskId          UNIQUEIDENTIFIER NULL, 
 
    ProjectId       UNIQUEIDENTIFIER NULL, 
 
    OriginalName    NVARCHAR(255) NOT NULL, 
 
    StoredName      NVARCHAR(255) NOT NULL, 
 
    FilePath        NVARCHAR(1000) NOT NULL, 
 
    ContentType     NVARCHAR(150) NULL, 
 
    FileSize        BIGINT NOT NULL, 
 
    UploadedAt      DATETIME2(0) NOT NULL 
        CONSTRAINT DF_Files_UploadedAt DEFAULT SYSUTCDATETIME(), 
 
    CONSTRAINT FK_Files_Workspace 
        FOREIGN KEY (WorkspaceId) 
        REFERENCES dbo.Workspaces(WorkspaceId) 
        ON DELETE CASCADE, 
 
    CONSTRAINT FK_Files_User 
        FOREIGN KEY (UploadedBy) 
        REFERENCES dbo.Users(UserId), 
 
    CONSTRAINT FK_Files_Task 
        FOREIGN KEY (TaskId) 
        REFERENCES dbo.Tasks(TaskId), 
 
    CONSTRAINT FK_Files_Project 
        FOREIGN KEY (ProjectId) 
        REFERENCES dbo.Projects(ProjectId), 
 
    CONSTRAINT CK_Files_FileSize 
        CHECK (FileSize >= 0) 
); 
GO 
 
 
/* ============================================================ 
   15. REFRESH TOKENS 
   ============================================================ */ 
 
 CREATE TABLE dbo.RefreshTokens 
( 
    RefreshTokenId  UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT PK_RefreshTokens PRIMARY KEY 
        DEFAULT NEWID(), 
 
    UserId          UNIQUEIDENTIFIER NOT NULL, 
 
    Token           NVARCHAR(500) NOT NULL, 
 
    ExpiresAt       DATETIME2(0) NOT NULL, 
 
    CreatedAt       DATETIME2(0) NOT NULL 
        CONSTRAINT DF_RefreshTokens_CreatedAt DEFAULT SYSUTCDATETIME(), 
 
    RevokedAt       DATETIME2(0) NULL, 
 
    CONSTRAINT FK_RefreshTokens_User 
        FOREIGN KEY (UserId) 
        REFERENCES dbo.Users(UserId) 
        ON DELETE CASCADE, 
 
    CONSTRAINT UQ_RefreshTokens_Token 
        UNIQUE (Token) 
);
GO

 
 
/* ============================================================ 
   16. USEFUL INDEXES 
   ============================================================ */ 
 
CREATE INDEX IX_Workspaces_OwnerId 
    ON dbo.Workspaces(OwnerId); 
GO 
 
CREATE INDEX IX_WorkspaceMembers_UserId 
    ON dbo.WorkspaceMembers(UserId); 
GO 
 
CREATE INDEX IX_Projects_WorkspaceId 
    ON dbo.Projects(WorkspaceId); 
GO 
 
CREATE INDEX IX_ProjectMembers_UserId 
    ON dbo.ProjectMembers(UserId); 
GO 
 
CREATE INDEX IX_Tasks_ProjectId 
    ON dbo.Tasks(ProjectId); 
GO 
 
CREATE INDEX IX_Tasks_AssignedTo 
    ON dbo.Tasks(AssignedTo); 
GO 
 
CREATE INDEX IX_Comments_TaskId 
    ON dbo.Comments(TaskId); 
GO 
 
CREATE INDEX IX_Notifications_UserId 
    ON dbo.Notifications(UserId); 
GO 
 
CREATE INDEX IX_ActivityLogs_WorkspaceId 
    ON dbo.ActivityLogs(WorkspaceId); 
GO 
 
CREATE INDEX IX_Files_WorkspaceId 
    ON dbo.Files(WorkspaceId); 
GO 
 
CREATE INDEX IX_RefreshTokens_UserId 
    ON dbo.RefreshTokens(UserId); 
GO 
 
 
/* ============================================================ 
   DATABASE CREATED SUCCESSFULLY 
   ============================================================ */ 
 
PRINT '============================================================'; 
PRINT 'TaskHiveDB created successfully.'; 
PRINT 'All tables, relationships, constraints and indexes created.'; 
PRINT '============================================================'; 
GO 

USE TaskHiveDB;

SELECT 
    name,
    definition
FROM sys.check_constraints
WHERE name = 'CK_Task_Status';
