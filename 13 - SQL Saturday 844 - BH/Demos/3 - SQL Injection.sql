USE [dirceuresende]
GO

--------------- vamos criar uma Stored Procedure normal -----------------

CREATE OR ALTER PROCEDURE dbo.stpConsulta_Tabela (
	@Nome VARCHAR(128)
)
AS
BEGIN

	DECLARE @Query VARCHAR(MAX) = 'SELECT * FROM sys.all_objects WHERE name = ''' + @nome + ''''
	
	PRINT(@Query)
	EXEC(@Query)

END
GO


-- SP funcionando normalmente..
EXEC stpConsulta_Tabela @Nome = 'objects'
EXEC stpConsulta_Tabela @Nome = 'tables'


-- E agora, o nosso SQL Injection :D
EXEC stpConsulta_Tabela @Nome = '''; SELECT * FROM sys.databases; SELECT * FROM sys.database_principals; SELECT * FROM sys.tables;--'


--------------- oh não! E agora? -----------------


CREATE OR ALTER PROCEDURE dbo.stpConsulta_Tabela (
	@Nome VARCHAR(128)
)
AS
BEGIN

	DECLARE @Query NVARCHAR(MAX) = 'SELECT * FROM sys.all_objects WHERE name = @nome' -- Tem que ser NVARCHAR
	
	EXEC sys.sp_executesql 
		@stmt = @Query,
		@params = N'@nome VARCHAR(128)',
		@nome = @Nome	

END
GO


-- Vamos testar de novo..
EXEC stpConsulta_Tabela @Nome = 'objects'
EXEC stpConsulta_Tabela @Nome = 'tables'


-- E agora, o nosso SQL Injection :D
EXEC stpConsulta_Tabela @Nome = '''; SELECT * FROM sys.databases; SELECT * FROM sys.database_principals; SELECT * FROM sys.tables;--'