USE [master]
GO

IF (NOT EXISTS(SELECT NULL FROM sys.databases WHERE [name] = 'dirceuresende'))
BEGIN
    
	CREATE DATABASE [dirceuresende]
	GO
	
	ALTER AUTHORIZATION ON DATABASE::[dirceuresende] TO [sa_old]
	GO

END
