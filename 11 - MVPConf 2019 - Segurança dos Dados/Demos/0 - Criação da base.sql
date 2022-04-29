IF (NOT EXISTS(SELECT NULL FROM sys.databases WHERE [name] = 'dirceuresende'))
BEGIN
	
	CREATE DATABASE [dirceuresende]
	GO

END
