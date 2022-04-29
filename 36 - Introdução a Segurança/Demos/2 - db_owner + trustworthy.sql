USE [master]
GO

ALTER DATABASE [dirceuresende] SET TRUSTWORTHY ON
GO

CREATE LOGIN [teste_trustworthy] WITH PASSWORD = 'dirceu', CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF, DEFAULT_DATABASE=[master]
GO

USE [dirceuresende]
GO

CREATE USER [teste_trustworthy] FOR LOGIN [teste_trustworthy]
GO

ALTER ROLE [db_owner] ADD MEMBER [teste_trustworthy]
GO


---------------------- conecta com usuário teste_trustworthy ---------------------------------


USE [dirceuresende]
GO

EXECUTE AS USER = 'dbo'
GO

SELECT
    USER_NAME() AS [USER_NAME],
    USER AS [USER],
    SESSION_USER AS [SESSION_USER],
    SUSER_SNAME() AS [SUSER_SNAME],
    SUSER_NAME() AS [SUSER_NAME],
	ORIGINAL_LOGIN() AS [ORIGINAL_LOGIN],
    IS_SRVROLEMEMBER('sysadmin') AS [IS_SYSADMIN],
	IS_SRVROLEMEMBER('securityadmin') AS [IS_SECURITYADMIN]


ALTER SERVER ROLE [sysadmin] ADD MEMBER [teste_trustworthy]
GO