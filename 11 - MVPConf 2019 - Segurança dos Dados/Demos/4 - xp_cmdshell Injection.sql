USE [dirceuresende]
GO

-- Ativa o xp_cmdshell
sp_configure 'xp_cmdshell', 1
RECONFIGURE


-- Cria a nossa SP
CREATE OR ALTER PROCEDURE stpCria_Diretorio (
	@Diretorio VARCHAR(255)
)
AS
BEGIN
	
	DECLARE @Comando VARCHAR(4000) = 'mkdir "' + @Diretorio + '"'

	PRINT @Comando
	EXEC xp_cmdshell @Comando

END



EXEC dbo.stpCria_Diretorio @Diretorio = 'C:\Temporario\Teste' -- varchar(255)



EXEC dbo.stpCria_Diretorio @Diretorio = 'C:\Temporario\Dirceu" && echo "Injection!!!" > C:\Temporario\Injection.txt && REM "' -- varchar(255)
