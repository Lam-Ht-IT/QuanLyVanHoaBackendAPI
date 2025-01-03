﻿--region Handles Database
ALTER DATABASE DB_QuanLyVanHoa
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;

DROP DATABASE DB_QuanLyVanHoa 


CREATE DATABASE DB_QuanLyVanHoa
USE DB_QuanLyVanHoa
GO
--endregion 

--region Rename Database
ALTER DATABASE [QuanLyVanHoa] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE [QuanLyVanHoa] MODIFY NAME = DB_QuanLyVanHoa;

ALTER DATABASE QuanLyVanHoa
ALTER DATABASE DB_QuanLyVanHoa SET MULTI_USER;
--endregion

--region Authorization Mangement System
--region Stored procedures of Users
CREATE TABLE Sys_User (	
	UserID INT PRIMARY KEY IDENTITY(1,1),
	UserName NVARCHAR(50),
	FullName NVARCHAR (100) null,
	Email NVARCHAR(50),
	Password NVARCHAR(100),
	Status BIT ,
	Note NVARCHAR(100),
);
GO


-- Get All Users
ALTER PROCEDURE UMS_GetListPaging
    @UserName NVARCHAR(50) = NULL, -- Updated to match the column size
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    -- Calculate the total number of records matching the search criteria
    DECLARE @TotalRecords INT;
    SELECT @TotalRecords = COUNT(*)
    FROM Sys_User
    WHERE @UserName IS NULL OR UserName LIKE '%' + @UserName + '%';

    -- Return data for the current page
    SELECT 
        UserID,
        UserName,
		FullName,
        Email,       -- Added Email field
        Password,
        Status,      -- Added Status field
        Note		 -- Added Note field
    FROM Sys_User
    WHERE @UserName IS NULL OR UserName LIKE '%' + @UserName + '%'
    ORDER BY UserID  -- Can be adjusted based on sorting requirements
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;

    -- Return the total number of records
    SELECT @TotalRecords AS TotalRecords;
END
GO

-- Get User by UserID
CREATE PROCEDURE UMS_GetByID
    @UserID int
AS
BEGIN
    SELECT * FROM Sys_User WHERE UserID = @UserID;
END
GO

--Get by UserName
CREATE PROC UMS_GetByUserName
	@UserName NVARCHAR(50)
AS
BEGIN
	SELECT * FROM Sys_User su WHERE su.UserName = @UserName
END	


GO
-- Get User By Refresh Token
CREATE PROC UMS_GetByRefreshToken
	@RefreshToken NVARCHAR(500)
AS
BEGIN
	SELECT * FROM Sys_User  WHERE @RefreshToken = RefreshToken
END
GO

--Get by Email
CREATE PROCEDURE UMS_GetByEmail
    @Email NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT * FROM Sys_User
    WHERE Email = @Email;
END;
GO

-- Create User
ALTER PROCEDURE UMS_Create
    @UserName NVARCHAR(50),
	@FullName NVARCHAR (100),
    @Email NVARCHAR(50),
    @Password NVARCHAR(100),
    @Status BIT,
    @Note NVARCHAR(100) = 'Regular user'
AS
BEGIN
    -- Insert new user record
    INSERT INTO Sys_User (UserName, Email, Password, Status, Note)
    VALUES (@UserName, @Email, @Password, @Status, @Note);
END
GO

-- Update User
ALTER PROCEDURE UMS_Update
    @UserID INT,
    @UserName NVARCHAR(50),
	@FullName NVARCHAR(100),
    @Email NVARCHAR(50),
    @Password NVARCHAR(100),
    @Status BIT,
    @Note NVARCHAR(100)
AS
BEGIN
    -- Update existing user record
    UPDATE Sys_User
    SET 
        UserName = @UserName,
        Email = @Email,
        Password = @Password,
        Status = @Status,
        Note = @Note,
		FullName = @FullName
    WHERE UserID = @UserID;
END
GO

-- Delete User
ALTER PROCEDURE [dbo].[UMS_Delete]
    @UserID INT
AS
BEGIN
    DELETE FROM Sys_UserInGroup
    WHERE UserID = @UserID;
	DELETE FROM Session
	WHERE UserID = @UserID
    DELETE FROM Sys_User
	WHERE UserID = @UserID;
END

GO
-- Veryfy Login
create PROCEDURE VerifyLogin
    @UserName NVARCHAR(50),
    @Password NVARCHAR(100)
AS
BEGIN
    SELECT *
    FROM Sys_User
    WHERE UserName = @UserName AND Password = @Password;
END
GO
--endregion

--region Stored procedures of UserGroups
CREATE TABLE Sys_Group (
    GroupID INT PRIMARY KEY IDENTITY(1,1),
    GroupName NVARCHAR(50),
    Description NVARCHAR(100)
);
GO
-- Get All Group
create PROCEDURE GMS_GetListPaging
    @GroupName NVARCHAR(50) = NULL, -- Updated to match the column size
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    -- Calculate the total number of records matching the search criteria
    DECLARE @TotalRecords INT;
    SELECT @TotalRecords = COUNT(*)
    FROM Sys_Group sug
    WHERE @GroupName IS NULL OR GroupName LIKE '%' + @GroupName + '%';

    -- Return data for the current page
    SELECT 
        sug.GroupID,
        sug.GroupName,
        sug.Description  
    FROM Sys_Group sug
    WHERE @GroupName IS NULL OR GroupName LIKE '%' + @GroupName + '%'
    ORDER BY sug.GroupID  -- Can be adjusted based on sorting requirements
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;

    -- Return the total number of records
    SELECT @TotalRecords AS TotalRecords;
END
GO
-- Get Group By ID
CREATE PROC GMS_GetByID
	@GroupID INT 
AS 
BEGIN
	SELECT * FROM Sys_Group sg WHERE  sg.GroupID = @GroupID
END
GO

-- Create Group 
CREATE PROCEDURE GMS_Create
    @GroupName NVARCHAR(50),
    @Description NVARCHAR(100)
AS
BEGIN
    -- Insert a new record into Sys_Group
    INSERT INTO Sys_Group (GroupName, Description)
    VALUES (@GroupName, @Description);
END
GO

-- Update Group
CREATE PROCEDURE GMS_Update
    @GroupID INT,
    @GroupName NVARCHAR(50),
    @Description NVARCHAR(100)
AS
BEGIN
    -- Update the existing record in Sys_Group
    UPDATE Sys_Group
    SET GroupName = @GroupName,
        Description = @Description
    WHERE GroupID = @GroupID;
END
GO

-- Delete Group
CREATE PROCEDURE GMS_Delete
    @GroupID INT
AS
BEGIN
    -- Delete the record from Sys_Group
    DELETE FROM Sys_Group
    WHERE GroupID = @GroupID;
END
GO
--endregion

--region Stored procedures of Function
CREATE TABLE Sys_Function (
    FunctionID INT PRIMARY KEY IDENTITY(1,1),
    FunctionName NVARCHAR(50),
    Description NVARCHAR(100),
);
GO
-- GetListPaging of Function
CREATE PROCEDURE FMS_GetListPaging
    @FunctionName NVARCHAR(50) = NULL, -- Updated to match the column size
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    -- Calculate the total number of records matching the search criteria
    DECLARE @TotalRecords INT;
    SELECT @TotalRecords = COUNT(*)
    FROM Sys_Function sf
    WHERE @FunctionName IS NULL OR FunctionName LIKE '%' + @FunctionName + '%';

    -- Return data for the current page
    SELECT 
        FunctionID,
        FunctionName,
        Description      
       
    FROM Sys_Function sf
    WHERE @FunctionName IS NULL OR FunctionName LIKE '%' + @FunctionName + '%'
    ORDER BY FunctionID  -- Can be adjusted based on sorting requirements
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;

    -- Return the total number of records
    SELECT @TotalRecords AS TotalRecords;
END
GO

-- Get Function by ID
create PROC FMS_GetByID
	@FunctionID int
AS
BEGIN
	SELECT * FROM Sys_Function sf WHERE sf.FunctionID = @FunctionID
END
GO

-- Create Function
CREATE PROCEDURE FMS_Create
    @FunctionName NVARCHAR(50),
    @Description NVARCHAR(100)
AS
BEGIN
    -- Insert a new record into Sys_Function
    INSERT INTO Sys_Function (FunctionName, Description)
    VALUES (@FunctionName, @Description);
END
GO

-- Update Function
CREATE PROCEDURE FMS_Update
    @FunctionID INT,
    @FunctionName NVARCHAR(50),
    @Description NVARCHAR(100)
AS
BEGIN
    -- Update the existing record in Sys_Function
    UPDATE Sys_Function
    SET FunctionName = @FunctionName,
        Description = @Description
    WHERE FunctionID = @FunctionID;
END
GO

-- Delete Function
ALTER PROCEDURE [dbo].[FMS_Delete]
    @FunctionID INT
AS
BEGIN
    -- Delete the record from Sys_Function
	DELETE FROM Sys_FunctionInGroup
	WHERE FunctionID = @FunctionID;
    DELETE FROM Sys_Function
    WHERE FunctionID = @FunctionID;
END

--endregion

--region Stored procedures of UserInGroup
CREATE TABLE Sys_UserInGroup (
	UserInGroupID INT PRIMARY KEY IDENTITY(1,1) ,
    UserID INT NOT NULL,
    GroupID INT NOT NULL,
    FOREIGN KEY (UserID) REFERENCES Sys_User(UserID),
    FOREIGN KEY (GroupID) REFERENCES Sys_Group(GroupID)
);
GO

CREATE PROCEDURE UIG_GetAll
AS
BEGIN
    SELECT UserInGroupID, UserID, GroupID
    FROM Sys_UserInGroup;
END;
GO

CREATE PROCEDURE UIG_GetByGroupID
    @GroupID INT
AS
BEGIN
    SELECT UserInGroupID, UserID, GroupID
    FROM Sys_UserInGroup
    WHERE GroupID = @GroupID;
END;
GO	

CREATE PROCEDURE UIG_GetByUserID
    @UserID INT
AS
BEGIN
    SELECT UserInGroupID, UserID, GroupID
    FROM Sys_UserInGroup
    WHERE UserID = @UserID;
END;
GO	

CREATE PROCEDURE UIG_GetByID
    @UserInGroupID INT
AS
BEGIN
    SELECT UserInGroupID, UserID, GroupID
    FROM Sys_UserInGroup
    WHERE UserInGroupID = @UserInGroupID;
END;
GO

-- Add User to Group
CREATE PROC UIG_Create  
	@UserID INT ,
	@GroupID INT
AS
BEGIN
	INSERT INTO Sys_UserInGroup (UserID, GroupID)
	VALUES (@UserID,@GroupID);
END
GO

CREATE PROCEDURE UIG_Update
    @UserInGroupID INT,
    @UserID INT,
    @GroupID INT
AS
BEGIN
    UPDATE Sys_UserInGroup
    SET UserID = @UserID, GroupID = @GroupID
    WHERE UserInGroupID = @UserInGroupID;
END;
GO

create PROCEDURE UIG_Delete
    @UserInGroupID INT
AS
BEGIN
    DELETE FROM Sys_UserInGroup
    WHERE UserInGroupID = @UserInGroupID;
END;
GO	
--endregion

--region Stored procedures of FunctionInGroup
CREATE TABLE Sys_FunctionInGroup (
	FunctionInGroupID INT PRIMARY KEY IDENTITY(1,1),
    FunctionID INT,
    GroupID INT,
	Permission INT NOT NULL, 
    FOREIGN KEY (FunctionID) REFERENCES Sys_Function(FunctionID),
    FOREIGN KEY (GroupID) REFERENCES Sys_Group(GroupID)
);
GO

CREATE PROCEDURE FIG_GetAll
AS
BEGIN
    SELECT FunctionInGroupID, FunctionID, GroupID, Permission
    FROM Sys_FunctionInGroup;
END
GO

CREATE PROCEDURE FIG_GetByGroupID
    @GroupID INT
AS
BEGIN
    SELECT FunctionInGroupID, FunctionID, GroupID, Permission
    FROM Sys_FunctionInGroup
    WHERE GroupID = @GroupID;
END
GO

CREATE PROCEDURE FIG_GetByFunctionID
    @FunctionID INT
AS
BEGIN
    SELECT FunctionInGroupID, FunctionID, GroupID, Permission
    FROM Sys_FunctionInGroup
    WHERE FunctionID = @FunctionID;
END
GO

CREATE PROCEDURE FIG_GetByID
    @FunctionInGroupID INT
AS
BEGIN
    SELECT FunctionInGroupID, FunctionID, GroupID, Permission
    FROM Sys_FunctionInGroup
    WHERE FunctionInGroupID = @FunctionInGroupID;
END
GO

CREATE PROCEDURE FIG_Create
    @FunctionID INT,
    @GroupID INT,
    @Permission INT
AS
BEGIN
    INSERT INTO Sys_FunctionInGroup (FunctionID, GroupID, Permission)
    VALUES (@FunctionID, @GroupID, @Permission);
END;
GO	

CREATE PROCEDURE FIG_Update
    @FunctionID INT,
    @GroupID INT,
    @Permission INT
AS
BEGIN
    UPDATE Sys_FunctionInGroup
    SET Permission = @Permission
    WHERE FunctionID = @FunctionID AND GroupID = @GroupID;
END;
GO	

CREATE PROCEDURE FIG_Delete
    @FunctionInGroupID INT
AS
BEGIN
    DELETE FROM Sys_FunctionInGroup
    WHERE FunctionInGroupID = @FunctionInGroupID;
END
GO	

CREATE PROCEDURE FIG_GetAllUserPermissions
    @UserName NVARCHAR(50),
    @FunctionName NVARCHAR(50)
AS
BEGIN
    SELECT Permission
    FROM Sys_FunctionInGroup fg
    INNER JOIN Sys_Function f ON fg.FunctionID = f.FunctionID
    INNER JOIN Sys_UserInGroup ug ON fg.GroupID = ug.GroupID
    INNER JOIN Sys_User u ON ug.UserID = u.UserID
    WHERE u.UserName = @UserName AND f.FunctionName = @FunctionName
END
GO	

CREATE PROCEDURE FIG_GetAllUserFunctionsAndPermissions
    @UserName NVARCHAR(50)
AS
BEGIN
    SELECT f.FunctionName, fg.Permission
    FROM Sys_FunctionInGroup fg
    INNER JOIN Sys_Function f ON fg.FunctionID = f.FunctionID
    INNER JOIN Sys_UserInGroup ug ON fg.GroupID = ug.GroupID
    INNER JOIN Sys_User u ON ug.UserID = u.UserID
    WHERE u.UserName = @UserName
END
GO	

--endregion

--region Stored procedures of RefreshToken
CREATE TABLE Session
(
    SessionID INT IDENTITY PRIMARY KEY,
    UserID INT FOREIGN KEY REFERENCES Sys_User(UserID),
    RefreshToken NVARCHAR(255) NOT NULL,
    ExpiryDate DATETIME NOT NULL,
    IsRevoked BIT NOT NULL DEFAULT 0,   -- Đánh dấu refresh token này đã bị thu hồi hay chưa
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
);
GO


CREATE PROCEDURE CreateSession
    @UserID INT,
    @RefreshToken NVARCHAR(255),
    @ExpiryDate DATETIME
AS
BEGIN
    -- Tạo phiên (Session) mới cho người dùng với refresh token
    INSERT INTO Session (UserID, RefreshToken, ExpiryDate, IsRevoked, CreatedAt)
    VALUES (@UserID, @RefreshToken, @ExpiryDate, 0, GETDATE());
END
GO


CREATE PROCEDURE GetSessionByRefreshToken
    @RefreshToken NVARCHAR(255)
AS
BEGIN
    SELECT SessionID, UserID, RefreshToken, ExpiryDate, IsRevoked, CreatedAt
    FROM Session
    WHERE RefreshToken = @RefreshToken AND IsRevoked = 0 AND ExpiryDate > GETDATE();
END
GO

CREATE PROCEDURE UpdateSessionRefreshToken
    @SessionID INT,
    @NewRefreshToken NVARCHAR(255),
    @NewExpiryDate DATETIME
AS
BEGIN
    UPDATE Session
    SET RefreshToken = @NewRefreshToken, ExpiryDate = @NewExpiryDate, CreatedAt = GETDATE()
    WHERE SessionID = @SessionID AND IsRevoked = 0;
END
GO


CREATE PROCEDURE RevokeSession
    @SessionID INT
AS
BEGIN
    UPDATE Session
    SET IsRevoked = 1, CreatedAt = GETDATE()
    WHERE SessionID = @SessionID;
END
GO

CREATE PROCEDURE RevokeAllSessions
    @UserID INT
AS
BEGIN
    UPDATE Session
    SET IsRevoked = 1, CreatedAt = GETDATE()
    WHERE UserID = @UserID AND IsRevoked = 0;
END
GO

CREATE PROCEDURE DeleteAllSessions
    @UserID INT
AS
BEGIN
    DELETE FROM Session
    WHERE UserID = @UserID;
END
GO



--endregion
--endregion

--region Category Mangement System
--region Stored procedures of DonViTinh
CREATE TABLE DM_DonViTinh
(
	DonViTinhID INT PRIMARY KEY IDENTITY (1,1),
	TenDonViTinh NVARCHAR (100),
	MaDonViTinh NVARCHAR (100),
	TrangThai BIT,
	GhiChu NVARCHAR(300),
);
GO

CREATE PROC DVT_GetAll
@TenDonViTinh NVARCHAR(100) = NULL,
@PageNumber INT = 1,
@PageSize INT = 20
AS
BEGIN
    -- Tính tổng số bản ghi phù hợp với điều kiện tìm kiếm
    DECLARE @TotalRecords INT;
    SELECT @TotalRecords = COUNT(*)
    FROM DM_DonViTinh
    WHERE @TenDonViTinh IS NULL OR TenDonViTinh LIKE '%' + @TenDonViTinh + '%';

    -- Trả về dữ liệu cho trang hiện tại
    SELECT 
        DonViTinhID,
        TenDonViTinh,
        MaDonViTinh,
		TrangThai,
		GhiChu
    FROM DM_DonViTinh
    WHERE @TenDonViTinh IS NULL OR TenDonViTinh LIKE '%' + @TenDonViTinh + '%'
    ORDER BY DonViTinhID
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;

    -- Trả về tổng số bản ghi
    SELECT @TotalRecords AS TotalRecords;
END
GO

CREATE PROC DVT_GetByID
	@DonViTinhID INT
AS	
BEGIN
	SELECT*FROM DM_DonViTinh WHERE DonViTinhID=@DonViTinhID;
END
GO

CREATE PROC DVT_Insert
	@TenDonViTinh NVARCHAR(100),
	@MaDonViTinh NVARCHAR(100),
	@TrangThai BIT,
	@GhiChu NVARCHAR(100)
AS
BEGIN
	INSERT INTO DM_DonViTinh (TenDonViTinh,MaDonViTinh,TrangThai,GhiChu) VALUES (@TenDonViTinh,@MaDonViTinh,@TrangThai,@GhiChu);
END
GO

CREATE PROC DVT_Update
	@DonViTinhID INT,
	@TenDonViTinh NVARCHAR(100),
	@MaDonViTinh NVARCHAR(100),
	@TrangThai BIT,
	@GhiChu NVARCHAR(100)
AS
BEGIN
	UPDATE DM_DonViTinh
	SET TenDonViTinh = @TenDonViTinh, MaDonViTinh = @MaDonViTinh, TrangThai = @TrangThai, GhiChu = @GhiChu WHERE DonViTinhID = @DonViTinhID;
END
GO	

CREATE PROC DVT_Delete
	@DonViTinhID INT
AS
BEGIN 
	DELETE FROM DM_DonViTinh WHERE DonViTinhID = @DonViTinhID;
END
GO
--endregion

--region Stored procedures LoaiDiTich
CREATE TABLE DM_LoaiDiTich(
	LoaiDiTichID INT PRIMARY KEY IDENTITY(1,1),
	LoaiDiTichChaID INT DEFAULT 0,
	TenLoaiDiTich NVARCHAR(100),
	MaLoaiDiTich NVARCHAR(100) DEFAULT '',
	TrangThai BIT DEFAULT 0,
	GhiChu NVARCHAR(300),
	Loai INT DEFAULT 4
);
GO

CREATE PROC LDT_GetAll
@TenLoaiDiTich NVARCHAR(100) = NULL,
@PageNumber INT = 1,
@PageSize INT = 20
AS
BEGIN
    -- Tính tổng số bản ghi phù hợp với điều kiện tìm kiếm
    DECLARE @TotalRecords INT;
    SELECT @TotalRecords = COUNT(*)
    FROM DM_LoaiDiTich
    WHERE @TenLoaiDiTich IS NULL OR TenLoaiDiTich LIKE '%' + @TenLoaiDiTich + '%';

    -- Trả về dữ liệu cho trang hiện tại
    SELECT 
        *
    FROM DM_LoaiDiTich
    WHERE @TenLoaiDiTich IS NULL OR TenLoaiDiTich LIKE '%' + @TenLoaiDiTich + '%'
    ORDER BY LoaiDiTichID
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;

    -- Trả về tổng số bản ghi
    SELECT @TotalRecords AS TotalRecords;
END
GO


CREATE PROC LDT_GetByID
	@LoaiDiTichID INT
AS	
BEGIN
	SELECT*FROM DM_LoaiDiTich WHERE LoaiDiTichID=@LoaiDiTichID;
END
GO

CREATE PROC LDT_Insert
	@TenLoaiDiTich NVARCHAR(100),
	@GhiChu NVARCHAR(100)
AS
BEGIN
	INSERT INTO DM_LoaiDiTich (TenLoaiDiTich,GhiChu) VALUES (@TenLoaiDiTich,@GhiChu);
END
GO

CREATE PROC LDT_Update
	@LoaiDiTichID INT,
	@TenLoaiDiTich NVARCHAR(100),
	@GhiChu NVARCHAR(100)
AS
BEGIN
	UPDATE DM_LoaiDiTich
	SET TenLoaiDiTich = @TenLoaiDiTich, GhiChu = @GhiChu WHERE LoaiDiTichID = @LoaiDiTichID;
END
GO	

CREATE PROC LDT_Delete
	@LoaiDiTichID INT
AS
BEGIN 
	DELETE FROM DM_LoaiDiTich WHERE LoaiDiTichID = @LoaiDiTichID;
END
GO
--endregion

--region Stored procedures of DiTichXepHang
CREATE TABLE DM_DiTichXepHang (
	DiTichXepHangID INT IDENTITY(1,1),
	DiTichXepHangChaID INT DEFAULT 0,
	TenDiTich NVARCHAR(100),
	MaDiTich NVARCHAR(100)  DEFAULT '',
	TrangThai BIT  DEFAULT 0,
	GhiChu NVARCHAR(300),
	Loai INT DEFAULT 0
);
GO

CREATE PROC DTXH_GetAll
    @TenDiTich NVARCHAR(100) = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    -- Tính tổng số bản ghi phù hợp với điều kiện tìm kiếm
    DECLARE @TotalRecords INT;
    SELECT @TotalRecords = COUNT(*)
    FROM DM_DITICHXEPHANG
    WHERE @TenDiTich IS NULL OR TenDiTich LIKE '%' + @TenDiTich + '%';

    -- Trả về dữ liệu cho trang hiện tại
    SELECT 
        DiTichXepHangID,
		DiTichXepHangChaID,
        TenDiTich,
        MaDiTich,
        TrangThai,
        GhiChu,
        Loai
    FROM DM_DITICHXEPHANG
    WHERE @TenDiTich IS NULL OR TenDiTich LIKE '%' + @TenDiTich + '%'
    ORDER BY GhiChu
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;

    -- Trả về tổng số bản ghi
    SELECT @TotalRecords AS TotalRecords;
END
GO

create PROC DTXH_GetByID
    @DiTichXepHangID INT
AS	
BEGIN
    SELECT 
        DiTichXepHangID,
		DiTichXepHangChaID,
        TenDiTich,
        MaDiTich,
        TrangThai,
        GhiChu,
        Loai
    FROM DM_DITICHXEPHANG
    WHERE DiTichXepHangID = @DiTichXepHangID;
END
GO	

CREATE PROC DTXH_Insert
    @TenDiTich NVARCHAR(100),
    @GhiChu NVARCHAR(100)
AS
BEGIN
    INSERT INTO DM_DITICHXEPHANG (TenDiTich, GhiChu) 
    VALUES (@TenDiTich, @GhiChu);
END
GO

CREATE PROC DTXH_Update
    @DiTichXepHangID INT,
    @TenDiTich NVARCHAR(100),
    @GhiChu NVARCHAR(100)
AS
BEGIN
    UPDATE DM_DITICHXEPHANG
    SET 
        TenDiTich = @TenDiTich,
        GhiChu = @GhiChu
    WHERE DiTichXepHangID = @DiTichXepHangID;
END
GO

create PROC DTXH_Delete
    @DiTichXepHangID INT
AS
BEGIN 
    DELETE FROM DM_DITICHXEPHANG 
    WHERE DiTichXepHangID = @DiTichXepHangID;
END
GO
--endregion

--region Stored procedures of DM_KyBaoCao
CREATE TABLE DM_KyBaoCao (
	KyBaoCaoID INT IDENTITY(1,1) PRIMARY KEY,
	KyBaoCaoChaID INT DEFAULT 0,
	TenKyBaoCao NVARCHAR(100) NOT NULL,
	MaKyBaoCao NVARCHAR(100) DEFAULT '',
    TrangThai BIT NOT NULL,
    GhiChu NVARCHAR(300),
    LoaiKyBaoCao INT DEFAULT 2
); 
GO 

create PROCEDURE KBC_GetAll
    @TenKyBaoCao NVARCHAR(100) = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;

    -- Tính tổng số bản ghi phù hợp với điều kiện tìm kiếm (không phân biệt chữ hoa, chữ thường)
    DECLARE @TotalRecords INT;
    SELECT @TotalRecords = COUNT(*)
    FROM DM_KyBaoCao dkbc
    WHERE @TenKyBaoCao IS NULL OR LOWER(TenKyBaoCao) LIKE '%' + LOWER(@TenKyBaoCao) + '%';

    -- Trả về dữ liệu cho trang hiện tại
    SELECT 
        KyBaoCaoID,
		KyBaoCaoChaID,
        TenKyBaoCao,
        TrangThai,
        GhiChu,
        LoaiKyBaoCao
    FROM DM_KyBaoCao
    WHERE @TenKyBaoCao IS NULL OR LOWER(TenKyBaoCao) LIKE '%' + LOWER(@TenKyBaoCao) + '%'
    ORDER BY KyBaoCaoID
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;

    -- Trả về tổng số bản ghi
    SELECT @TotalRecords AS TotalRecords;
END;
GO	

create PROC KBC_GetByID
	@KyBaoCaoID INT
AS
BEGIN
	SELECT * FROM DM_KyBaoCao dkbc  WHERE dkbc.KyBaoCaoID = @KyBaoCaoID 
END
GO

create PROCEDURE KBC_Insert
    @TenKyBaoCao NVARCHAR(100),
    @TrangThai BIT,
    @GhiChu NVARCHAR(100) 
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO DM_KyBaoCao (TenKyBaoCao, TrangThai, GhiChu)
    VALUES (@TenKyBaoCao, @TrangThai, @GhiChu);

    -- Trả về ID của bản ghi vừa tạo
    SELECT SCOPE_IDENTITY() AS KyBaoCaoID;
END;
GO	

create PROCEDURE KBC_Update
    @KyBaoCaoID INT,
    @TenKyBaoCao NVARCHAR(100),
    @TrangThai BIT,
    @GhiChu NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE DM_KyBaoCao
    SET 
        TenKyBaoCao = @TenKyBaoCao,
        TrangThai = @TrangThai,
        GhiChu = @GhiChu
    WHERE 
        KyBaoCaoID = @KyBaoCaoID;

    -- Trả về số bản ghi đã được cập nhật
    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

create PROCEDURE KBC_Delete
    @KyBaoCaoID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM DM_KyBaoCao
    WHERE KyBaoCaoID = @KyBaoCaoID;

    -- Trả về số bản ghi đã bị xóa
    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO	

--endregion
--endregion

--region Comprehensive Management Of Report Templates
--region Stored Procedure of Report Form Management
CREATE TABLE BC_MauPhieu(
	MauPhieuID INT PRIMARY KEY IDENTITY (1,1),
	TenMauPhieu NVARCHAR (100),
	MaMauPhieu NVARCHAR (100),
	LoaiMauPhieuID INT FOREIGN KEY (LoaiMauPhieuID) REFERENCES DM_LoaiMauPhieu (LoaiMauPhieuID),
	NgayTao DATETIME DEFAULT CURRENT_TIMESTAMP,
	NguoiTao NVARCHAR (100) DEFAULT NULL
)
GO

-- GetAll MauPhieu
CREATE PROC MP_GetAll
	@TenMauPhieu NVARCHAR(100) = Null,
	@PageNumber INT = 1,
	@PageSize INT = 20
AS
BEGIN	
	-- Tính tổng số bản ghi phù hợp với điều kiện tìm kiếm
	DECLARE @TotalRecords INT;
	SELECT @TotalRecords = COUNT(*) FROM BC_MauPhieu WHERE LOWER(@TenMauPhieu) IS NULL OR TenMauPhieu LIKE '%' + LOWER(@TenMauPhieu) + '%';

	-- Trả về dữ liệu cho trang hiện tại
	SELECT 
		bmp.MauPhieuID,bmp.TenMauPhieu, bmp.MaMauPhieu,bmp.LoaiMauPhieuID,bmp.NgayTao,bmp.NguoiTao
	FROM BC_MauPhieu bmp
	WHERE @TenMauPhieu IS NULL OR  LOWER(@TenMauPhieu) LIKE '%' + LOWER(TenMauPhieu) + '%'
	ORDER BY bmp.MauPhieuID
	OFFSET (@PageNumber - 1) * @PageSize ROWS
	FETCH NEXT @PageSize ROWS ONLY

	-- Trả về tổng số bản ghi
	SELECT @TotalRecords AS TotalRecords
END
GO

CREATE PROC MP_GetByID 
	@MauPhieuID INT
AS
BEGIN
	SELECT * FROM BC_MauPhieu 
END
GO

CREATE PROC MP_Insert
	@TenMauPhieu NVARCHAR (100),
	@MaMauPhieu  NVARCHAR (100),
	@LoaiMauPhieuID INT
AS
BEGIN
	INSERT INTO BC_MauPhieu (TenMauPhieu, MaMauPhieu, LoaiMauPhieuID)
	VALUES (@TenMauPhieu, @MaMauPhieu, @LoaiMauPhieuID);
END
GO

CREATE PROC MP_Update
	@MauPhieuID INT ,
	@TenMauPhieu NVARCHAR (100),
	@MaMauPhieu  NVARCHAR (100),
	@LoaiMauPhieuID INT
AS
BEGIN
	UPDATE BC_MauPhieu
	SET TenMauPhieu = @TenMauPhieu,  LoaiMauPhieuID = @LoaiMauPhieuID
	WHERE MauPhieuID = @MauPhieuID
END	
GO	

CREATE PROC MP_Delete
	@MauPhieuID int
AS
BEGIN
	DELETE FROM BC_MauPhieu  WHERE MauPhieuID = @MauPhieuID
END
GO	

--endregion	

--region Stored procedures of DM_LoaiMauPieu
CREATE TABLE DM_LoaiMauPhieu
(
	LoaiMauPhieuID INT PRIMARY KEY IDENTITY(1,1),
	LoaiMauPhieuChaID INT DEFAULT 0,
	TenLoaiMauPhieu NVARCHAR(100),
	MaLoaiMauPhieu NVARCHAR(100),
	TrangThai BIT DEFAULT 0,
	GhiChu NVARCHAR(300),
	Loai INT DEFAULT 3
);
GO 

ALTER TABLE DM_ChiTieu
ADD CONSTRAINT FK_DM_ChiTieu_DM_LoaiMauPhieu
FOREIGN KEY (LoaiMauPhieuID) REFERENCES DM_LoaiMauPhieu(LoaiMauPhieuID)
ON DELETE CASCADE;
GO

CREATE PROC LMP_GetAll
@TenLoaiMauPhieu NVARCHAR(100) = NULL,
@PageNumber INT = 1,
@PageSize INT = 20
AS
BEGIN
    -- Tính tổng số bản ghi phù hợp với điều kiện tìm kiếm
    DECLARE @TotalRecords INT;
    SELECT @TotalRecords = COUNT(*)
    FROM DM_LoaiMauPhieu
    WHERE @TenLoaiMauPhieu IS NULL OR TenLoaiMauPhieu LIKE '%' + @TenLoaiMauPhieu + '%';

    -- Trả về dữ liệu cho trang hiện tại
    SELECT 
        LoaiMauPhieuID,
		LoaiMauPhieuChaID,
        TenLoaiMauPhieu,
        MaLoaiMauPhieu,
		TrangThai,
		GhiChu,
		Loai
    FROM DM_LoaiMauPhieu
    WHERE @TenLoaiMauPhieu IS NULL OR TenLoaiMauPhieu LIKE '%' + @TenLoaiMauPhieu + '%'
    ORDER BY LoaiMauPhieuID
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;

    -- Trả về tổng số bản ghi
    SELECT @TotalRecords AS TotalRecords;
END
GO

CREATE PROC LMP_GetByID
	@LoaiMauPhieuID INT
AS	
BEGIN
	SELECT*FROM DM_LoaiMauPhieu WHERE LoaiMauPhieuID=@LoaiMauPhieuID;
END
GO

CREATE PROC LMP_Insert
	@TenLoaiMauPhieu NVARCHAR(100),
	@MaLoaiMauPhieu NVARCHAR(100),
	@GhiChu NVARCHAR(100)
AS
BEGIN
	INSERT INTO DM_LoaiMauPhieu (TenLoaiMauPhieu,MaLoaiMauPhieu,GhiChu) VALUES (@TenLoaiMauPhieu,@MaLoaiMauPhieu,@GhiChu);
END
GO

CREATE PROC LMP_Update
	@LoaiMauPhieuID INT,
	@TenLoaiMauPhieu NVARCHAR(100),
	@MaLoaiMauPhieu NVARCHAR(100),
	@GhiChu NVARCHAR(100)
AS
BEGIN
	UPDATE DM_LoaiMauPhieu
	SET TenLoaiMauPhieu = @TenLoaiMauPhieu, MaLoaiMauPhieu = @MaLoaiMauPhieu, GhiChu = @GhiChu WHERE LoaiMauPhieuID = @LoaiMauPhieuID;
END
GO	

CREATE PROC LMP_Delete
	@LoaiMauPhieuID INT
AS
BEGIN 
	DELETE FROM DM_LoaiMauPhieu WHERE LoaiMauPhieuID = @LoaiMauPhieuID;
END
GO
--endregion

--region Store Procedure of Report Criteria 
CREATE TABLE BC_TieuChi(
	TieuChiBaoCaoID INT PRIMARY KEY IDENTITY (1,1),
	TieuChiID INT FOREIGN KEY (TieuChiID) REFERENCES DM_TieuChi (TieuChiID),
	MauPhieuID INT FOREIGN KEY(MauPhieuID) REFERENCES BC_MauPhieu (MauPhieuID),
	HienThi BIT DEFAULT 1,
	GhiChu NVARCHAR(300) NULL
);
GO

-- Lấy tất cả BC_TieuChi
CREATE PROCEDURE BCTC_GetAll
AS
BEGIN
    SELECT * FROM BC_TieuChi;
END;
GO

CREATE PROC BCTC_GetByID
	@TieuChiBaoCao INT 
AS 
BEGIN
	SELECT *FROM BC_TieuChi btc WHERE btc.TieuChiBaoCaoID = @TieuChiBaoCao
END
GO	

-- Thêm mới BC_TieuChi
CREATE PROCEDURE BCTC_Insert 
	@MauPhieuID INT,
    @TieuChiID INT,
	@HienThi BIT
AS
BEGIN
    INSERT INTO BC_TieuChi (TieuChiID, MauPhieuID, HienThi)
    VALUES (@TieuChiID, @MauPhieuID, @HienThi);
END;
GO

-- Cập nhật BC_TieuChi
CREATE PROCEDURE BCTC_Update 
    @TieuChiBaoCaoID INT,
    @TieuChiID INT,
    @MauPhieuID INT,
	@HienThi BIT 
AS
BEGIN
    UPDATE BC_TieuChi
    SET HienThi = @HienThi
    WHERE TieuChiBaoCaoID = @TieuChiBaoCaoID;
END;
GO

-- Xóa BC_TieuChi
CREATE PROCEDURE BCTC_Delete 
    @TieuChiBaoCaoID INT
AS
BEGIN
    DELETE FROM BC_TieuChi WHERE TieuChiBaoCaoID = @TieuChiBaoCaoID;
END;
GO

--endregion

--region Stored Procedure of Report Target
CREATE TABLE BC_ChiTieu(
	ChiTieuBaoCaoID INT PRIMARY KEY IDENTITY (1,1),
	MauPhieuID INT FOREIGN KEY REFERENCES BC_MauPhieu(MauPhieuID),
    ChiTieuID INT FOREIGN KEY REFERENCES DM_ChiTieu(ChiTieuID),
	HienThi BIT DEFAULT 1
);
GO


-- Lấy tất cả BC_ChiTieu
CREATE PROCEDURE BCCT_GetAll
AS
BEGIN
    SELECT * FROM BC_ChiTieu;
END;
GO

CREATE PROC BCCT_GetByID 
	@ChiTieuBaoCaoID INT
AS
BEGIN
	SELECT * FROM BC_ChiTieu WHERE	ChiTieuBaoCaoID = @ChiTieuBaoCaoID
END	
GO

-- Thêm mới BC_ChiTieu
CREATE PROCEDURE BCCT_Insert 
    @ChiTieuID INT,
    @MauPhieuID INT,
	@HienThi BIT
AS
BEGIN
    INSERT INTO BC_ChiTieu (ChiTieuID, MauPhieuID, HienThi)
    VALUES (@ChiTieuID, @MauPhieuID, @HienThi);
END;
GO

-- Cập nhật BC_ChiTieu
CREATE PROCEDURE BCCT_Update
    @ChiTieuBaoCaoID INT,
    @ChiTieuID INT,
    @MauPhieuID INT,
	@HienThi INT
AS
BEGIN
    UPDATE BC_ChiTieu
    SET HienThi = @HienThi
    WHERE ChiTieuBaoCaoID = @ChiTieuBaoCaoID;
END;
GO

-- Xóa BC_ChiTieu
CREATE PROCEDURE BCCT_Delete
    @ChiTieuBaoCaoID INT
AS
BEGIN
    DELETE FROM BC_ChiTieu WHERE ChiTieuBaoCaoID = @ChiTieuBaoCaoID;
END;
GO



--endregion

--region Stored Procedure of BC_ChiTietMauPhieu
CREATE TABLE BC_ChiTietMauPhieu(
	ChiTietMauPhieuID int PRIMARY KEY IDENTITY(1,1),
	MauPhieuID INT FOREIGN KEY (MauPhieuID) REFERENCES BC_MauPhieu(MauPhieuID),
	TieuChiIDs NVARCHAR(MAX),
	ChitieuID INT FOREIGN KEY (ChitieuID) REFERENCES DM_ChiTieu (ChiTieuID),
	NoiDung NVARCHAR (300),
	GopCot BIT NULL,
    GopTuCot INT NULL,
    GopDenCot INT NULL,
    SoCotGop INT NULL,
	GhiChu NVARCHAR (300) DEFAULT NULL	
);
GO

-- Lấy tất cả BC_ChiTietMauPhieu
CREATE PROCEDURE BCCTMP_GetAll
AS
BEGIN
    SELECT * FROM BC_ChiTietMauPhieu;
END;
GO

CREATE PROC BCCTMP_GetByID
	@ChiTietMauPhieuID INT
AS
BEGIN
	SELECT *FROM BC_ChiTietMauPhieu bctmp WHERE bctmp.ChiTietMauPhieuID = @ChiTietMauPhieuID
END
GO

-- Thêm mới BC_ChiTietMauPhieu
CREATE PROCEDURE BCCTMP_Insert (
    @MauPhieuID INT,
    @TieuChiID INT,
    @ChiTieuID INT,
    @NoiDung NVARCHAR(MAX),
    @GhiChu NVARCHAR(MAX) = NULL
)
AS
BEGIN
    INSERT INTO BC_ChiTietMauPhieu (MauPhieuID, TieuChiID, ChiTieuID, NoiDung, GhiChu)
    VALUES (@MauPhieuID, @TieuChiID, @ChiTieuID, @NoiDung, @GhiChu);
END;
GO

-- Cập nhật BC_ChiTietMauPhieu
CREATE PROCEDURE BCCTMP_Update (
    @ChiTietMauPhieuID INT,
    @MauPhieuID INT,
    @TieuChiID INT,
    @ChiTieuID INT,
    @NoiDung NVARCHAR(MAX),
    @GhiChu NVARCHAR(MAX) = NULL
)
AS
BEGIN
    UPDATE BC_ChiTietMauPhieu
    SET MauPhieuID = @MauPhieuID, TieuChiID = @TieuChiID, ChiTieuID = @ChiTieuID, NoiDung = @NoiDung, GhiChu = @GhiChu
    WHERE ChiTietMauPhieuID = @ChiTietMauPhieuID;
END;
GO

-- Xóa BC_ChiTietMauPhieu
CREATE PROCEDURE BCCTMP_Delete (
    @ChiTietMauPhieuID INT
)
AS
BEGIN
    DELETE FROM BC_ChiTietMauPhieu WHERE ChiTietMauPhieuID = @ChiTietMauPhieuID;
END;
GO



--endregion

--region Stored procedures of ChiTieu
CREATE TABLE DM_ChiTieu (
    ChiTieuID INT PRIMARY KEY IDENTITY(1,1),
    MaChiTieu NVARCHAR(100) NOT NULL,        
    TenChiTieu NVARCHAR(100) NOT NULL,      
    ChiTieuChaID INT NULL,                  
    GhiChu NVARCHAR(300) DEFAULT '',               
    TrangThai BIT DEFAULT 0,                 
    LoaiMauPhieuID INT NOT NULL,                 
    FOREIGN KEY (ChiTieuChaID) REFERENCES DM_ChiTieu(ChiTieuID)
);  
GO 

CREATE PROCEDURE CT_GetAll
    @TenChiTieu NVARCHAR(100) = NULL
    --,@PageNumber INT = 1,
    --@PageSize INT = 100
AS
BEGIN
    -- Kiểm tra biến đầu vào
    --IF @PageNumber < 1 SET @PageNumber = 1;
    --IF @PageSize < 1 SET @PageSize = 100;

    -- CTE để xử lý phân cấp và tìm kiếm
    WITH RecursiveCTE AS (
        -- Anchor member: Bắt đầu với các node gốc (nơi ChiTieuChaID là NULL)
        SELECT 
            ChiTieuID,
			ChiTieuChaID,
            MaChiTieu,
            TenChiTieu,
            GhiChu,
            TrangThai,
            LoaiMauPhieuID,
            0 AS Level,
            CAST('/' + CONVERT(NVARCHAR(50), ChiTieuID) AS NVARCHAR(50)) AS Hierarchy
        FROM 
            DM_ChiTieu
        WHERE 
            ChiTieuChaID IS NULL

        UNION ALL

        -- Recursive member: Join the table with itself to find children
        SELECT 
            c.ChiTieuID,
			c.ChiTieuChaID,
            c.MaChiTieu,
            c.TenChiTieu,
            c.GhiChu,
            c.TrangThai,
            c.LoaiMauPhieuID,
            cte.Level + 1 AS Level,
            CAST(cte.Hierarchy + '/' + CONVERT(NVARCHAR(50), c.ChiTieuID) AS NVARCHAR(50)) AS Hierarchy
        FROM 
            DM_ChiTieu c
        INNER JOIN 
            RecursiveCTE cte ON c.ChiTieuChaID = cte.ChiTieuID
    ),
    -- CTE phụ để lọc các phần tử khớp với từ khóa tìm kiếm
    FilteredCTE AS (
        SELECT 
            ChiTieuID,
			ChiTieuChaID,
            MaChiTieu,
            TenChiTieu,
            GhiChu,
            TrangThai,
            LoaiMauPhieuID,
            Level,
            Hierarchy
        FROM 
            RecursiveCTE
        WHERE 
            @TenChiTieu IS NULL
            OR LOWER(TenChiTieu) LIKE '%' + LOWER(@TenChiTieu) + '%'
    ),
    -- CTE phụ để xác định các phần tử cha và phần tử con của các phần tử cần thiết
    AllParentsCTE AS (
        SELECT 
            c.*
        FROM 
            FilteredCTE fc
        INNER JOIN 
            RecursiveCTE c ON c.ChiTieuID = fc.ChiTieuChaID
        UNION ALL
        SELECT 
            c.*
        FROM 
            AllParentsCTE p
        INNER JOIN 
            RecursiveCTE c ON c.ChiTieuID = p.ChiTieuChaID
    ),
    AllChildrenCTE AS (
        SELECT 
            c.*
        FROM 
            FilteredCTE fc
        INNER JOIN 
            RecursiveCTE c ON c.ChiTieuChaID = fc.ChiTieuID
        UNION ALL
        SELECT 
            c.*
        FROM 
            AllChildrenCTE p
        INNER JOIN 
            RecursiveCTE c ON c.ChiTieuChaID = p.ChiTieuID
    ),
    -- Kết hợp tất cả các phần tử cần thiết và loại bỏ các bản ghi trùng lặp
    CombinedCTE AS (
        SELECT DISTINCT * FROM FilteredCTE
        UNION
        SELECT DISTINCT * FROM AllParentsCTE
        UNION
        SELECT DISTINCT * FROM AllChildrenCTE
    )
    -- Truy vấn phân cấp với phân trang và tính toán tổng số bản ghi
    SELECT 
        ChiTieuID,
		ChiTieuChaID,
        MaChiTieu,
        TenChiTieu,
        GhiChu,
        TrangThai,
        LoaiMauPhieuID,
        Level,
        Hierarchy
        --,TotalRecords = (SELECT COUNT(*) FROM CombinedCTE)
    FROM 
        CombinedCTE
    ORDER BY 
       ChiTieuID, Hierarchy
    --OFFSET (@PageNumber - 1) * @PageSize ROWS 
    --FETCH NEXT @PageSize ROWS ONLY
    OPTION (MAXRECURSION 0);
END;
GO

CREATE PROCEDURE CT_GetAll 
    @TenChiTieu NVARCHAR(100) = NULL
AS
BEGIN
    -- CTE để xử lý phân cấp và tìm kiếm
    WITH RecursiveCTE AS (
        -- Anchor member: Bắt đầu với các node gốc (nơi ChiTieuChaID là NULL)
        SELECT 
            ChiTieuID,
			ChiTieuChaID,
            MaChiTieu,
            TenChiTieu,
            GhiChu,
            TrangThai,
            LoaiMauPhieuID,
            0 AS Level,
            CAST('/' + CONVERT(NVARCHAR(50), ChiTieuID) AS NVARCHAR(50)) AS Hierarchy
        FROM 
            DM_ChiTieu
        WHERE 
            ChiTieuChaID IS NULL

        UNION ALL

        -- Recursive member: Join the table with itself to find children
        SELECT 
            c.ChiTieuID,
			c.ChiTieuChaID,
            c.MaChiTieu,
            c.TenChiTieu,
            c.GhiChu,
            c.TrangThai,
            c.LoaiMauPhieuID,
            cte.Level + 1 AS Level,
            CAST(cte.Hierarchy + '/' + CONVERT(NVARCHAR(50), c.ChiTieuID) AS NVARCHAR(50)) AS Hierarchy
        FROM 
            DM_ChiTieu c
        INNER JOIN 
            RecursiveCTE cte ON c.ChiTieuChaID = cte.ChiTieuID
    ),
    -- CTE phụ để lọc các phần tử khớp với từ khóa tìm kiếm
    FilteredCTE AS (
        SELECT 
            ChiTieuID,
			ChiTieuChaID,
            MaChiTieu,
            TenChiTieu,
            GhiChu,
            TrangThai,
            LoaiMauPhieuID,
            Level,
            Hierarchy
        FROM 
            RecursiveCTE
        WHERE 
            @TenChiTieu IS NULL
            OR LOWER(TenChiTieu) LIKE '%' + LOWER(@TenChiTieu) + '%'
    ),
    -- CTE phụ để xác định các phần tử cha và phần tử con của các phần tử cần thiết
    AllParentsCTE AS (
        SELECT 
            c.*
        FROM 
            FilteredCTE fc
        INNER JOIN 
            RecursiveCTE c ON c.ChiTieuID = fc.ChiTieuChaID
        UNION ALL
        SELECT 
            c.*
        FROM 
            AllParentsCTE p
        INNER JOIN 
            RecursiveCTE c ON c.ChiTieuID = p.ChiTieuChaID
    ),
    AllChildrenCTE AS (
        SELECT 
            c.*
        FROM 
            FilteredCTE fc
        INNER JOIN 
            RecursiveCTE c ON c.ChiTieuChaID = fc.ChiTieuID
        UNION ALL
        SELECT 
            c.*
        FROM 
            AllChildrenCTE p
        INNER JOIN 
            RecursiveCTE c ON c.ChiTieuChaID = p.ChiTieuID
    ),
    -- Kết hợp tất cả các phần tử cần thiết và loại bỏ các bản ghi trùng lặp
    CombinedCTE AS (
        SELECT DISTINCT * FROM FilteredCTE
        UNION
        SELECT DISTINCT * FROM AllParentsCTE
        UNION
        SELECT DISTINCT * FROM AllChildrenCTE
    )
    -- Truy vấn phân cấp với tổng số bản ghi
    SELECT 
        ChiTieuID,
		ChiTieuChaID,
        MaChiTieu,
        TenChiTieu,
        GhiChu,
        TrangThai,
        LoaiMauPhieuID,
        Level,
        Hierarchy
    FROM 
        CombinedCTE
    ORDER BY 
       ChiTieuID, Hierarchy
    OPTION (MAXRECURSION 0);
END;
GO

CREATE PROCEDURE CT_GetByID
    @ChiTieuID INT
AS
BEGIN
    SELECT * FROM DM_ChiTieu WHERE ChiTieuID = @ChiTieuID;
END; 
GO

CREATE PROCEDURE CT_Insert
    @MaChiTieu NVARCHAR(100),
    @TenChiTieu NVARCHAR(100),
    @ChiTieuChaID INT null,
    @GhiChu NVARCHAR(100),
    @LoaiMauPhieuID INT
AS
BEGIN
    INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, GhiChu, LoaiMauPhieuID)
    VALUES (@MaChiTieu, @TenChiTieu, @ChiTieuChaID, @GhiChu, @LoaiMauPhieuID);
    
    SELECT SCOPE_IDENTITY() AS NewChiTieuID;  -- Return the newly created ID
END;
GO

-- Thêm chỉ tiêu con với LoaiMauPhieuID từ chỉ tiêu cha
CREATE PROCEDURE CT_InsertChildren 
	@MaChiTieu NVARCHAR(100),
    @ChiTieuChaID INT,
    @TenChiTieu NVARCHAR(100),
	@GhiChu NVARCHAR(300)

AS
BEGIN
    DECLARE @LoaiMauPhieuID INT;

    -- Lấy LoaiMauPhieuID từ chỉ tiêu cha
    SELECT @LoaiMauPhieuID = LoaiMauPhieuID 
    FROM DM_ChiTieu 
    WHERE ChiTieuID = @ChiTieuChaID;

    -- Thêm chỉ tiêu con với LoaiMauPhieuID từ chỉ tiêu cha
    INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID, TrangThai)
    VALUES (@MaChiTieu, @TenChiTieu, @ChiTieuChaID, @LoaiMauPhieuID, 1);
END;
GO
-- Tạo procedure để lấy các chỉ tiêu phân cấp theo LoaiMauPhieuID
CREATE PROCEDURE CT_GetByLoaiMauPhieuID 
    @LoaiMauPhieuID INT
AS
BEGIN
    -- CTE để lấy tất cả các chỉ tiêu phân cấp
    WITH CTE_ChiTieu AS (
        -- Lấy các chỉ tiêu gốc (không có chỉ tiêu cha)
        SELECT 
            ChiTieuID, 
            TenChiTieu, 
			MaChiTieu,
            ChiTieuChaID, 
            LoaiMauPhieuID, 
            TrangThai,
			GhiChu
        FROM DM_ChiTieu
        WHERE LoaiMauPhieuID = @LoaiMauPhieuID AND ChiTieuChaID IS NULL

        UNION ALL

        -- Đệ quy để lấy các chỉ tiêu con, cháu,...
        SELECT 
            ct.ChiTieuID, 
            ct.TenChiTieu,
			ct.MaChiTieu,
            ct.ChiTieuChaID, 
            ct.LoaiMauPhieuID, 
            ct.TrangThai,
			ct.GhiChu
        FROM DM_ChiTieu ct
        INNER JOIN CTE_ChiTieu cte ON ct.ChiTieuChaID = cte.ChiTieuID
    )

    -- Truy vấn kết quả từ CTE
    SELECT *
    FROM CTE_ChiTieu
    ORDER BY ChiTieuChaID, ChiTieuID;
END;
GO

CREATE PROCEDURE CT_Update
    @ChiTieuID INT,
	@ChiTieuChaID INT NULL,
    @MaChiTieu NVARCHAR(100),
    @TenChiTieu NVARCHAR(100),
    @LoaiMauPhieuID INT,
	@GhiChu NVARCHAR(100)
AS
BEGIN
    UPDATE DM_ChiTieu
    SET MaChiTieu = @MaChiTieu,
        TenChiTieu = @TenChiTieu,
        ChiTieuChaID = @ChiTieuChaID,
        GhiChu = @GhiChu,
        LoaiMauPhieuID = @LoaiMauPhieuID
    WHERE ChiTieuID = @ChiTieuID;
END;
GO

CREATE PROCEDURE CT_Delete
    @ChiTieuID INT
AS
BEGIN
    -- Check if the element has children
    IF EXISTS (
        SELECT 1
        FROM DM_ChiTieu
        WHERE ChiTieuChaID = @ChiTieuID
    )
    BEGIN
        -- Delete children recursively
        WITH RecursiveCTE AS (
            SELECT 
                ChiTieuID,
                ChiTieuChaID
            FROM 
                DM_ChiTieu
            WHERE 
                ChiTieuChaID = @ChiTieuID

            UNION ALL

            SELECT 
                c.ChiTieuID,
                c.ChiTieuChaID
            FROM 
                DM_ChiTieu c
            INNER JOIN 
                RecursiveCTE p ON c.ChiTieuChaID = p.ChiTieuID
        )
        DELETE FROM DM_ChiTieu
        WHERE ChiTieuID IN (SELECT ChiTieuID FROM RecursiveCTE);
    END

    -- Delete the parent element
    DELETE FROM DM_ChiTieu
    WHERE ChiTieuID = @ChiTieuID;
END;
GO
--endregion

--region Stored procedures of DM_TieuChi
CREATE TABLE DM_TieuChi (
	TieuChiID INT PRIMARY KEY IDENTITY(1,1),
	MaTieuChi NVARCHAR(100),
	TenTieuChi NVARCHAR(100) NOT NULL,
	TieuChiChaID INT NULL,
	CONSTRAINT FK_TieuChi_TieuChiCha FOREIGN KEY (TieuChiChaID) REFERENCES DM_TieuChi(TieuChiID),
	GhiChu NVARCHAR(300) DEFAULT '',
	KieuDuLieuCot INT,
	TrangThai BIT DEFAULT 0,
	LoaiTieuChi INT,
	CapDo INT
);
GO 

-- Procedure to retrieve all criteria with paging and hierarchical data
CREATE PROCEDURE TC_GetAll
    @TenTieuChi NVARCHAR(100) = NULL
    --,@PageNumber INT = 1,
    --@PageSize INT = 20
AS
BEGIN
    -- Validate input parameters
    --IF @PageNumber < 1 SET @PageNumber = 1;
    --IF @PageSize < 1 SET @PageSize = 20;

    -- Recursive Common Table Expression (CTE) to build the hierarchy
    WITH RecursiveCTE AS (
        -- Anchor member: Start with root nodes (where TieuChiChaID is NULL)
        SELECT 
            TieuChiID,
            TieuChiChaID,
            MaTieuChi,
            TenTieuChi,
            GhiChu,
            KieuDuLieuCot,
            TrangThai,
            LoaiTieuChi,
            1 AS CapDo,  -- Set level to 1 for root nodes
            CAST('/' + CONVERT(NVARCHAR(50), TieuChiID) AS NVARCHAR(50)) AS Hierarchy  -- Build hierarchy path
        FROM 
            DM_TieuChi
        WHERE 
            TieuChiChaID IS NULL

        UNION ALL

        -- Recursive member: Join to find child nodes
        SELECT 
            c.TieuChiID,
            c.TieuChiChaID,
            c.MaTieuChi,
            c.TenTieuChi,
            c.GhiChu,
            c.KieuDuLieuCot,
            c.TrangThai,
            c.LoaiTieuChi,
            p.CapDo + 1 AS CapDo,  -- Increase level for child nodes
            CAST(p.Hierarchy + '/' + CONVERT(NVARCHAR(50), c.TieuChiID) AS NVARCHAR(50)) AS Hierarchy  -- Extend hierarchy path
        FROM 
            DM_TieuChi c
        INNER JOIN 
            RecursiveCTE p ON c.TieuChiChaID = p.TieuChiID
    ),
    -- Filter results based on search criteria
    FilteredCTE AS (
        SELECT 
            TieuChiID,
            TieuChiChaID,
            MaTieuChi,
            TenTieuChi,
            GhiChu,
            KieuDuLieuCot,
            TrangThai,
            LoaiTieuChi,
            CapDo,
            Hierarchy
        FROM 
            RecursiveCTE
        WHERE 
            @TenTieuChi IS NULL
            OR LOWER(TenTieuChi) LIKE '%' + LOWER(@TenTieuChi) + '%'  -- Case-insensitive search
    ),
    -- CTE to identify parent elements of the filtered results
    AllParentsCTE AS (
        SELECT 
            c.*
        FROM 
            FilteredCTE fc
        INNER JOIN 
            RecursiveCTE c ON c.TieuChiID = fc.TieuChiChaID
        UNION ALL
        SELECT 
            c.*
        FROM 
            AllParentsCTE p
        INNER JOIN 
            RecursiveCTE c ON c.TieuChiChaID = p.TieuChiChaID
    ),
    -- CTE to identify child elements of the filtered results
    AllChildrenCTE AS (
        SELECT 
            c.*
        FROM 
            FilteredCTE fc
        INNER JOIN 
            RecursiveCTE c ON c.TieuChiChaID = fc.TieuChiID
        UNION ALL
        SELECT 
            c.*
        FROM 
            AllChildrenCTE p
        INNER JOIN 
            RecursiveCTE c ON c.TieuChiChaID = p.TieuChiID
    ),
    -- Combine all relevant elements (filtered, parents, and children) and remove duplicates
    CombinedCTE AS (
        SELECT DISTINCT * FROM FilteredCTE
        UNION
        SELECT DISTINCT * FROM AllParentsCTE
        UNION
        SELECT DISTINCT * FROM AllChildrenCTE
    )
    -- Final query with pagination and total records count
    SELECT 
        TieuChiID,
        TieuChiChaID,
        MaTieuChi,
        TenTieuChi,
        GhiChu,
        KieuDuLieuCot,
        TrangThai,
        LoaiTieuChi,
        CapDo,
        Hierarchy
        --,TotalRecords = (SELECT COUNT(*) FROM CombinedCTE)  -- Total record count
    FROM 
        CombinedCTE
    ORDER BY 
        Hierarchy  -- Order by hierarchy path
    --OFFSET (@PageNumber - 1) * @PageSize ROWS 
    --FETCH NEXT @PageSize ROWS ONLY  -- Pagination
    OPTION (MAXRECURSION 0);  -- Prevent recursion depth limit
END;
GO

CREATE PROC TC_GetByID
	@TieuChiID INT
AS
BEGIN
	SELECT *FROM DM_TieuChi  WHERE TieuChiID = @TieuChiID;
END
GO

CREATE PROC TC_Insert
	@MaTieuChi NVARCHAR(100),
    @TenTieuChi NVARCHAR(100),
    @TieuChiChaID INT = NULL,
    @KieuDuLieuCot INT = NULL,
    @LoaiTieuChi INT = NULL
AS
BEGIN
    DECLARE @CapDo INT;

    -- Kiểm tra nếu TieuChiChaID là NULL thì đối tượng là gốc, CapDo sẽ là 1
    IF @TieuChiChaID IS NULL
    BEGIN
        SET @CapDo = 1;
    END
    ELSE
    BEGIN
        -- Lấy CapDo của TieuChiCha và tăng lên 1 để xác định cấp độ của tiêu chí hiện tại
        SELECT @CapDo = CapDo + 1 
        FROM DM_TieuChi 
        WHERE TieuChiID = @TieuChiChaID;

        -- Nếu không tìm thấy TieuChiChaID thì báo lỗi
        IF @CapDo IS NULL
        BEGIN
            RAISERROR('Không tìm thấy Tiêu Chí Cha với ID đã cung cấp.', 16, 1);
            RETURN;
        END
    END

    -- Thêm tiêu chí mới vào bảng DM_TieuChi
    INSERT INTO DM_TieuChi (MaTieuChi, TenTieuChi, TieuChiChaID, KieuDuLieuCot, LoaiTieuChi, CapDo)
    VALUES (@MaTieuChi, @TenTieuChi, @TieuChiChaID, @KieuDuLieuCot, @LoaiTieuChi, @CapDo);
END;
GO

CREATE PROCEDURE TC_Update
    @TieuChiID INT,
    @MaTieuChi NVARCHAR(100),
    @TenTieuChi NVARCHAR(100),
    @TieuChiChaID INT = NULL,
    @GhiChu NVARCHAR(100) = NULL,
    @KieuDuLieuCot INT = NULL,
    @LoaiTieuChi INT = NULL
AS
BEGIN
    UPDATE DM_TieuChi
    SET 
        MaTieuChi = @MaTieuChi,
        TenTieuChi = @TenTieuChi,
        TieuChiChaID = @TieuChiChaID,
        GhiChu = @GhiChu,
        KieuDuLieuCot = @KieuDuLieuCot,
        LoaiTieuChi = @LoaiTieuChi
    WHERE TieuChiID = @TieuChiID;
END;
GO

CREATE PROCEDURE TC_Delete
    @TieuChiID INT
AS
BEGIN
    -- Check if the element has children
    IF EXISTS (
        SELECT 1
        FROM DM_TieuChi
        WHERE TieuChiChaID = @TieuChiID
    )
    BEGIN
        -- Delete children recursively
        WITH RecursiveCTE AS (
            SELECT 
                TieuChiID,
                TieuChiChaID
            FROM 
                DM_TieuChi
            WHERE 
                TieuChiChaID = @TieuChiID

            UNION ALL

            SELECT 
                c.TieuChiID,
                c.TieuChiChaID
            FROM 
                DM_TieuChi c
            INNER JOIN 
                RecursiveCTE p ON c.TieuChiChaID = p.TieuChiID
        )
        DELETE FROM DM_TieuChi
        WHERE TieuChiID IN (SELECT TieuChiID FROM RecursiveCTE);
    END

    -- Delete the parent element
    DELETE FROM DM_TieuChi
    WHERE TieuChiID = @TieuChiID;
END;
GO
--endregion
--endregion

--region Insert Table
--region Insert records into Categories
INSERT INTO DM_DITICHXEPHANG ( TenDiTich,GhiChu ) VALUES
( N'Di Tích Quốc Gia','3' ),
( N'Di Tích Quốc Gia Đặc Biệt','2' ),
( N'Di Tích Cấp Tỉnh','1' )
GO
INSERT INTO DM_DonViTinh (TenDonViTinh, MaDonViTinh, TrangThai, GhiChu)
VALUES (N'Kilogram', N'KG', 1, N'Đơn vị đo khối lượng'),
(N'Hộp', N'HOP', 1, N'Đơn vị đo đếm đóng gói'),
(N'Mét', N'M', 1, N'Đơn vị đo chiều dài'),
(N'Lit', N'L', 1, N'Đơn vị đo thể tích'),
(N'Cái', N'CAI', 1, N'Đơn vị đếm số lượng');
GO
INSERT INTO DM_TieuChi (MaTieuChi, TenTieuChi, TieuChiChaID, KieuDuLieuCot, LoaiTieuChi)
VALUES
('TOP_QHTN', N'Quốc hiệu tiêu ngữ', NULL, 3, 1),
('TOP_DVCQ', N'Đơn vị chủ quản', NULL, 3, 1),
('TOP_DVTHBC', N'Đơn vị thực hiện báo cáo',NULL, 3, 1),
('TOP_TDBC', N'Tiêu đê báo cáo', NULL, 3, 1),
('TOP_PHANNGAYTHANG', N'Phần ngày tháng', NULL, 3, 1),
('TOP_DVT', N'Đơn vị tính', NULL, 3, 1),
('TOP_PHULUC', N'Phụ lục', NULL, 3, 1),
('BODY_STT', N'STT', NULL, 3, 2),
('BODY_ND', N'Nội dung', NULL, 3, 2),
('BODY_GHICHU', N'Ghi chú', NULL, 3, 2),
('BODY_THANGNAM', N'Tháng/năm', NULL, 3, 2),
('BOT_LUUNHAN', N'Lưu nhận', NULL, 3, 3),
('BOT_PHANNGAYTHANG', N'Phần ngày tháng', NULL, 3, 3),
('BOT_CHUCDANH', N'Chức danh', NULL, 3, 3),
('BOT_NGUOIKY', N'Người ký', NULL, 3, 3),
('BODY_T', N'Tỉnh', 11, 3, 2),
('BODY_H', N'Huyện', 11, 3, 2),
('BODY_X', N'Xã', 11, 3, 2);
GO
INSERT INTO DM_LoaiMauPhieu (LoaiMauPhieuChaID, TenLoaiMauPhieu, MaLoaiMauPhieu, TrangThai, GhiChu, Loai)
VALUES (0, N'BIỂU MẪU SỐ LIỆU SỐ 001-DSVH DỮ LIỆU CƠ BẢN VỀ DI SẢN VĂN HÓA', '001-DSVH', 0, '', 3);

INSERT INTO DM_LoaiMauPhieu (LoaiMauPhieuChaID, TenLoaiMauPhieu, MaLoaiMauPhieu, TrangThai, GhiChu, Loai)
VALUES (0, N'BIỂU MẪU SỐ LIỆU SỐ 002-VHCS SỐ LIỆU CƠ BẢN VỀ VĂN HÓA CƠ SỞ', '002-VHCS', 0, '', 3);

INSERT INTO DM_LoaiMauPhieu (LoaiMauPhieuChaID, TenLoaiMauPhieu, MaLoaiMauPhieu, TrangThai, GhiChu, Loai)
VALUES (0, N'BIỂU MẪU SỐ LIỆU SỐ 003-VHDT SỐ LIỆU CƠ BẢN VỀ VĂN HÓA DÂN TỘC', '003-VHDT', 0, '', 3);

INSERT INTO DM_LoaiMauPhieu (LoaiMauPhieuChaID, TenLoaiMauPhieu, MaLoaiMauPhieu, TrangThai, GhiChu, Loai)
VALUES (0, N'BIỂU MẪU SỐ LIỆU SỐ 004-TV SỐ LIỆU CƠ BẢN VỀ THƯ VIỆN', '004-TV', 0, '', 3);

INSERT INTO DM_LoaiMauPhieu (LoaiMauPhieuChaID, TenLoaiMauPhieu, MaLoaiMauPhieu, TrangThai, GhiChu, Loai)
VALUES (0, N'BIỂU MẪU SỐ LIỆU SỐ 005-ĐA SỐ LIỆU CƠ BẢN VỀ ĐIỆN ẢNH', '005-ĐA', 0, '', 3);

INSERT INTO DM_LoaiMauPhieu (LoaiMauPhieuChaID, TenLoaiMauPhieu, MaLoaiMauPhieu, TrangThai, GhiChu, Loai)
VALUES (0, N'BIỂU MẪU SỐ LIỆU SỐ 006-NTBD SỐ LIỆU CƠ BẢN VỀ NGHỆ THUẬT BIỂU DIỄN', '006-NTBD', 0, '', 3);

INSERT INTO DM_LoaiMauPhieu (LoaiMauPhieuChaID, TenLoaiMauPhieu, MaLoaiMauPhieu, TrangThai, GhiChu, Loai)
VALUES (0, N'BIỂU MẪU SỐ LIỆU SỐ 007-MTNTAL SỐ LIỆU CƠ BẢN VỀ MỸ THUẬT, NHIẾP ẢNH VÀ TRIỂN LÃM', '007-MTNTAL', 0, '', 3);

INSERT INTO DM_LoaiMauPhieu (LoaiMauPhieuChaID, TenLoaiMauPhieu, MaLoaiMauPhieu, TrangThai, GhiChu, Loai)
VALUES (0, N'BIỂU MẪU SỐ LIỆU SỐ 008-GĐ SỐ LIỆU CƠ BẢN VỀ GIA ĐÌNH', '008-GĐ', 0, '', 3);

INSERT INTO DM_LoaiMauPhieu (LoaiMauPhieuChaID, TenLoaiMauPhieu, MaLoaiMauPhieu, TrangThai, GhiChu, Loai)
VALUES (0, N'BIỂU MẪU SỐ LIỆU SỐ 009-TDTT SỐ LIỆU CƠ BẢN VỀ THỂ DỤC, THỂ THAO', '009-TDTT', 0, '', 3);

INSERT INTO DM_LoaiMauPhieu (LoaiMauPhieuChaID, TenLoaiMauPhieu, MaLoaiMauPhieu, TrangThai, GhiChu, Loai)
VALUES (0, N'BIỂU MẪU SỐ LIỆU SỐ 010-TTR SỐ LIỆU CƠ BẢN VỀ THANH TRA', '010-TTR', 0, '', 3);
GO
--region Insert Category ChiTieu
--region Root Level ChiTieus
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT001', N'DI TÍCH', NULL, 1);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT002', N'Số lượng thư viện', NULL, 2);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES
('CT003', N'Nhân lực thư viện', NULL, 3);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT004', N'Bảo tàng', NULL, 4);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT005', N'Số lượng xin cấp xin phép triển lãm', NULL, 5);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT006', N'Số lượng họa sĩ, nhà điêu khắc, nghệ sĩ nhiếp ảnh', NULL, 6);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT007', N'Gia Đình', NULL, 7);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT008', N'Bạo lực gia đình', NULL, 8);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT009', N'Các biện pháp phòng, chống bạo lực gia', NULL, 9);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT0010', N'Số vận động viên cấp cao', NULL, 10);
--endregion

--region Childen level 1
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT1_1', N'Tổng số Di tích xếp hạng cấp tỉnh:', 1, 1);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT1_2', N'Tổng số Di tích xếp hạng quốc gia:', 1, 1);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT1_3', N'Tổng số Di tích quốc gia đặc biệt được xếp hạng:', 1, 1);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT2_1', N'Tổng số thư viện công cộng hiện có', 2, 2);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT2_2', N'Số thư viện công cộng thành lập trong năm', 2, 2);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT2_3', N'Số thư viện công cộng cấp huyện trực thuộc UBND', 2, 2);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT2_4', N'Số thư viện tư nhân có phục vụ cộng đồng', 2, 2);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT2_5', N'Số thư viện cộng đồng', 2, 2);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES
('CT3_1', N'Số lượng người làm công tác thư viện hiện có Số thư viện công cộng thành lập trong năm', 3, 3);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES
('CT3_2', N'Chất lượng nguồn nhân lực:', 3, 3);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT4_1', N'Tổng số bảo tàng trực thuộc:', 4, 4);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT4_2', N'Tổng số hiện vật có trong từng bảo tàng:', 4, 4);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT4_3', N'Tổng số sưu tập hiện vật trong từng bảo tàng', 4, 4);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT4_4', N'Tổng số khách tham quan trong năm của từng bảo tàng:', 4, 4);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT4_5', N'Tổng thu từ phí tham quan trong năm của từng bảo tàng (nếu có):', 4, 4);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT4_6', N'Tổng số trưng bày chuyên đề của từng bảo tàng:', 4, 4);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT5_1', N'Triển lãm mỹ thuật', 5, 5),
('CT5_2', N'Triển lãm nhiếp ảnh', 5, 5),
('CT5_3', N'Các Triển lãm không vì mục đích thương mại', 5, 5),
('CT5_4', N'Số lượng giấy phép/ văn bản phê duyệt nội dung tác phẩm mỹ thuật, nhiếp ảnh xuất, nhập khẩu', 5, 5);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT6_1', N'Mỹ thuật', 6, 6),
('CT6_2', N'Nhiếp ảnh', 6, 6);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT7_1', N'Tổng số hộ gia đình', 7, 7);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT8_1', N'Tổng số hộ có bạo lực gia đình', 8, 8);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT8_2', N'Tổng số vụ bạo lực gia đình', 8, 8);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT8_3', N'Hình thức bạo lực', 8, 8);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT8_4', N'Người gây bạo lực gia đình và biện pháp xử lý', 8, 8);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT8_5', N'Biện pháp xử lý', 8, 8);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT8_6', N'Nạn nhân bị bạo lực gia đình và biện pháp hỗ trợ', 8, 8);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT9_1', N'Mô hình phòng, chống bạo lực gia đình', 9, 9);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT9_2', N'Mô hình hoạt động độc lập', 9, 9);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT10_1', N'Cấp kiện tướng', 10, 10);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT10_2', N'Cấp 1', 10, 10);
--endregion

--region children level 2
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT1_1_1', N'Di tích lịch sử:', 11, 1);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT1_1_2', N'Di tích kiến trúc nghệ thuật:', 11, 1);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT1_1_3', N'Di tích khảo cổ:', 11, 1);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT1_1_4', N'Danh lam thắng cảnh:', 11, 1);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT1_1_5', N'Số Di tích cấp tỉnh được xếp hạng trong năm:', 11, 1);

INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT1_2_1', N'Di tích lịch sử:', 12, 1);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT1_2_2', N'Di tích kiến trúc nghệ thuật:', 12, 1);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT1_2_3', N'Di tích khảo cổ:', 12, 1);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT1_2_4', N'Danh lam thắng cảnh:', 12, 1);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT1_2_5', N'Số Di tích quốc gia được xếp hạng trong năm:', 12, 1);

INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT1_3_1', N'Số Di tích quốc gia đặc biệt được xếp hạng trong', 13, 1);

INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES
('CT3_2_1', N'Về trình độ học vấn:', 20, 3);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES
('CT3_2_2', N'Về chuyên môn ngành thư viện', 20, 3);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES
('CT3_2_3', N'Số lượt cán bộ được đào tạo, tập huấn trong năm', 20, 3);


INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT4_2_1', N'Số hiện vật bảo tàng mới được sưu tầm trong năm (của từng bảo tàng):', 22, 4);

INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT4_3_1', N'Số sưu tập hiện vật được hình thành trong năm của từng bảo tàng:', 23, 4);

-- Insert các "thằng cháu" của Triển lãm mỹ thuật
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT5_1_1', N'Trong nước', 27, 5),
('CT5_1_2', N'Ra nước ngoài', 27, 5);

-- Insert các "thằng cháu" của Triển lãm nhiếp ảnh
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT5_2_1', N'Trong nước', 28, 5),
('CT5_2_2', N'Ra nước ngoài', 28, 5);

-- Insert các "thằng cháu" của Các Triển lãm không vì mục đích thương mại
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT5_3_1', N'Trong nước', 29, 5),
('CT5_3_2', N'Ra nước ngoài', 29, 5);

-- Insert các "thằng cháu" của Mỹ thuật
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT6_1_1', N'Họa sĩ Hội Mỹ thuật địa phương', 31, 6),
('CT6_1_2', N'Nhà điêu khắc Hội Mỹ thuật địa phương', 31, 6);

-- Insert các "thằng cháu" của Nhiếp ảnh
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT6_2_1', N'Hội viên hội nhiếp ảnh địa phương', 32, 6);

INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT7_1_1', N'Số hộ gia đình chỉ có cha hoặc mẹ sống chung với con', 33, 7);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT7_1_2', N'Số hộ gia đình 1 thế hệ (vợ, chồng)', 33, 7);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT7_1_3', N'Số hộ gia đình 2 thế hệ', 33, 7);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT7_1_4', N'Số hộ gia đình 3 thế hệ trở lên', 33, 7);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT7_1_5', N'Số hộ gia đình khác', 33, 7);

INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT8_3_1', N'Tinh thần', 36, 8);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT8_3_2', N'Thân thể', 36, 8);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT8_3_3', N'Tình dục', 36, 8);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT8_3_4', N'Kinh tế', 36, 8);

INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT8_4_1', N'Giới tính', 37, 8);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT8_4_2', N'Độ tuổi', 37, 8);

INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT8_5_1', N'Góp ý, phê bình trong cộng đồng dân cư', 38, 8);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT8_5_2', N'Áp dụng biện pháp cấm tiếp xúc', 38, 8);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT8_5_3', N'Áp dụng các biện pháp giáo dục', 38, 8);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT8_5_4', N'Xử phạt vi phạm hành chính', 38, 8);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT8_5_5', N'Xử lý hình sự (phạt tù)', 38, 8);


INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT8_6_1', N'Giới tính', 39, 8);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT8_6_2', N'Độ tuổi', 39, 8);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT8_6_3', N'Biện pháp hỗ trợ', 39, 8);

INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT9_2_1', N'Số Câu lạc bộ gia đình phát triển bền vững', 41, 9);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT9_2_2', N'Số Nhóm phòng, chống bạo lực gia đình', 41, 9);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT9_2_3', N'Số địa chỉ tin cậy ở cộng đồng', 41, 9);
INSERT INTO DM_ChiTieu (MaChiTieu, TenChiTieu, ChiTieuChaID, LoaiMauPhieuID)
VALUES 
('CT9_2_4', N'Số đường dây nóng', 41, 9);
--endregion
--endregion
GO
INSERT INTO DM_LoaiDiTich (TenLoaiDiTich, GhiChu)
VALUES (N'Di tích kiến trúc nghệ thuật', '1'),
(N'Di tích lịch sử cách mạng', '2'),
(N'Di tich lịch sử văn hóa', '3')
GO
INSERT INTO DM_KyBaoCao (TenKyBaoCao, TrangThai, GhiChu, LoaiKyBaoCao)
VALUES 
(N'Kỳ báo cáo tháng 1', 1, N'1', 1),
(N'Kỳ báo cáo tháng 2', 1, N'2', 1),
(N'Kỳ báo cáo tháng 3', 1, N'3', 2),
(N'Kỳ báo cáo quý 1', 1, N'1,2,3', 1),
(N'Kỳ báo cáo quý 2', 1, N'4,5,6', 1),
(N'Kỳ báo cáo quý 3', 1, N'7,8,9', 2),
(N'Kỳ báo cáo quý 4', 1, N'10,11,12', 2),
(N'Kỳ báo cáo năm 2023', 1, N'2023', 3),
(N'Kỳ báo cáo năm 2024', 0, N'2024', 3),
(N'Kỳ báo cáo dự án X', 1, N'Báo cáo tiến độ dự án X', 4);
--endregion

--region Insert records into  Authorization Management
-- Thêm người dùng
INSERT INTO Sys_User (UserName, Email, Password, Status, Note)
VALUES
('admin', 'admin@example.com', 'admin', 1, 'Admin user'),
('user1', 'user1@example.com', 'user1', 1, 'Regular user');
GO	

--Thêm chức năng
INSERT INTO Sys_Function (FunctionName, Description)
	VALUES ('ManageUsers', N'Quản lý người dùng'),
	('ManageMonumentRanking', N'Quản lý di tích xếp hạng'),
	('ManageUnitofMeasure', N'Quản lý đơn vị tính'),
	('ManageReportingPeriod', N'Quản lý kỳ báo cáo'),
	('ManageTypeofMonument', N'Quản lý loại di tích'),
	('ManageFormType', N'Quản lý mẫu phiếu'),
	('ManageCriteria', N'Quản lý tiêu chí'),
	('ManageTarget', N'Quản lý chỉ tiêu'),
	('ManageReportForm', N'Quản lý mẫu phiếu báo cáo'),
	('ManageAuthorization', N'Quản lý ủy quyền');
GO
SELECT * FROM Sys_Function

-- Thêm nhóm
INSERT INTO Sys_Group (GroupName, Description)
VALUES
('AdminGroup', N'Nhóm quản trị'),
('UserGroup', N'Nhóm người dùng');
GO
-- Thêm người dùng vào nhóm
INSERT INTO Sys_UserInGroup (UserID, GroupID)
VALUES
(1, 1),  -- admin vào AdminGroup
(2, 2);  -- user1 vào UserGroup
GO	


-- Thêm chức năng vào nhóm và phân quyền
INSERT INTO Sys_FunctionInGroup (FunctionID, GroupID, Permission)
VALUES
(1, 1, 15),
(1, 2, 0),
(2, 1, 15),
(2, 2, 7),
(3, 1, 15),
(3, 2, 7),
(4, 1, 15),
(4, 2, 7),
(5, 1, 15),
(5, 2, 7),
(6, 1, 15),
(6, 2, 7),
(7, 1, 15),
(7, 2, 7),
(8, 1, 15),
(8, 2, 7),
(9,1,15),
(9,2,7),
(10,1,15),
(10,2,0)
GO  
--endregion
--endregion

--region Query
	DELETE FROM Sys_User;
	DBCC CHECKIDENT ('Sys_User', RESEED, 0);
	DELETE FROM Sys_Function;
	DBCC CHECKIDENT ('Sys_Function', RESEED, 0);
	DELETE FROM Sys_Group;
	DBCC CHECKIDENT ('Sys_Group', RESEED, 0);
	DELETE FROM Sys_UserInGroup;
	DBCC CHECKIDENT ('Sys_UserInGroup', RESEED, 0);
	DELETE FROM Sys_FunctionInGroup;
	DBCC CHECKIDENT ('Sys_FunctionInGroup', RESEED, 0);
	DELETE FROM DM_LoaiMauPhieu
	DBCC CHECKIDENT ('DM_LoaiMauPhieu', RESEED, 0);
	DELETE FROM DM_ChiTieu
	DBCC CHECKIDENT ('DM_ChiTieu', RESEED, 0);
	DELETE FROM DM_LoaiDiTich
	DBCC CHECKIDENT ('DM_LoaiDiTich', RESEED, 0);
	DELETE FROM DM_TieuChi
	DBCC CHECKIDENT ('DM_TieuChi', RESEED, 0);
	DELETE FROM DM_DiTichXepHang
	DBCC CHECKIDENT ('DM_DiTichXepHang', RESEED, 0);
	DELETE FROM DM_DonViTinh
	DBCC CHECKIDENT ('DM_DonViTinh', RESEED, 0);
	DELETE FROM DM_KyBaoCao
	DBCC CHECKIDENT ('DM_KyBaoCao', RESEED, 0);
	
	DELETE FROM DM_TieuChi WHERE TieuChiID = 20
	DELETE FROM Sys_User WHERE UserID = 38

	-- Reset giá trị IDENTITY về giá trị mặc định (1)
GO




DROP TABLE BC_MauPhieu
DROP TABLE BC_CauHinhGop
DROP TABLE BC_ChiTietMauPhieu
DROP TABLE BC_TieuChi
DROP TABLE BC_ChiTieu



SELECT * FROM Sys_Function sf
SELECT * FROM Sys_FunctionInGroup sfig
SELECT * FROM Sys_UserInGroup suig
SELECT * FROM Sys_User su
SELECT * FROM Sys_Group sg


SELECT * FROM DM_KyBaoCao dkbc
SELECT * FROM DM_DiTichXepHang 
SELECT * FROM DM_DonViTinh 
SELECT * FROM DM_LoaiDiTich
SELECT * FROM DM_LoaiMauPhieu 

SELECT *FROM  BC_ChiTietMauPhieu bctmp
SELECT * FROM BC_MauPhieu
SELECT * FROM BC_TieuChi
SELECT * FROM BC_ChiTieu
SELECT * FROM DM_TieuChi dtc
SELECT * FROM DM_ChiTieu dtc



UPDATE Sys_User
SET Password = 'user1' WHERE UserID = 2

UPDATE Sys_FunctionInGroup 
SET  Permission = 15 WHERE FunctionInGroupID = 1

UPDATE Sys_Function 
SET FunctionName = 'ManageMonumentRanking'  WHERE FunctionID = 2


EXEC TC_Delete @TieuChiID = 1
EXEC CT_GetAll @TenChiTieu = ''
EXEC TC_GetAll @TenTieuChi = ''
EXEC FIG_GetUserPermissions @UserName = 'admin', @FunctionName = 'ManageTargets' 
EXEC UMS_GetByRefreshToken @RefreshToken = ''
SELECT * FROM	Sys_User su
EXEC CT_Delete @ChiTieuID = 2
EXEC CT_Delete 113

-- Các tiêu chí gốc (CapDo = 1)
EXEC TC_Insert 'TOP_QHTN', N'Quốc hiệu tiêu ngữ', NULL, 3, 1;
EXEC TC_Insert 'TOP_DVCQ', N'Đơn vị chủ quản', NULL, 3, 1;
EXEC TC_Insert 'TOP_DVTHBC', N'Đơn vị thực hiện báo cáo', NULL, 3, 1;
EXEC TC_Insert 'TOP_TDBC', N'Tiêu đê báo cáo', NULL, 3, 1;
EXEC TC_Insert 'TOP_PHANNGAYTHANG', N'Phần ngày tháng', NULL, 3, 1;
EXEC TC_Insert 'TOP_DVT', N'Đơn vị tính', NULL, 3, 1;
EXEC TC_Insert 'TOP_PHULUC', N'Phụ lục', NULL, 3, 1;
EXEC TC_Insert 'BODY_STT', N'STT', NULL, 1, 2;
EXEC TC_Insert 'BODY_ND', N'Nội dung', NULL, 3, 2;
EXEC TC_Insert 'BODY_GHICHU', N'Ghi chú', NULL, 3, 2;
EXEC TC_Insert 'BODY_THANGNAM', N'Tháng/năm', NULL, 3, 2;
EXEC TC_Insert 'BOT_LUUNHAN', N'Lưu nhận', NULL, 3, 3;
EXEC TC_Insert 'BOT_PHANNGAYTHANG', N'Phần ngày tháng', NULL, 3, 3;
EXEC TC_Insert 'BOT_CHUCDANH', N'Chức danh', NULL, 3, 3;
EXEC TC_Insert 'BOT_NGUOIKY', N'Người ký', NULL, 3, 3;

-- Các tiêu chí con của BODY_ND (CapDo = 2 vì có TieuChiChaID là 11)
EXEC TC_Insert 'BODY_T', N'Tỉnh', 11,  1, 2;
EXEC TC_Insert 'BODY_H', N'Huyện', 11,  1, 2;
EXEC TC_Insert 'BODY_X', N'Xã', 11,  1, 2;




ALTER TABLE BC_ChiTietMauPhieu
ADD TieuChiIDs NVARCHAR(MAX);


ALTER TABLE BC_ChiTietMauPhieu
DROP COLUMN TieuChiID;

--endregion
