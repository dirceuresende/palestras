
sp_configure 'advanced options', 1
GO

RECONFIGURE
GO

sp_configure 'xp_cmdshell', 1
GO

RECONFIGURE
GO


CREATE PROCEDURE xpcmdshell.stpArquivo_Existe (
    @Ds_Arquivo VARCHAR(255),
    @Saida BIT OUTPUT
)
AS BEGIN

    DECLARE @Query VARCHAR(8000) = 'IF EXIST "' + @Ds_Arquivo + '" ( echo 1 ) ELSE ( echo 0 )'

    DECLARE @Retorno TABLE (
        Linha INT IDENTITY(1, 1),
        Resultado VARCHAR(MAX)
    )

    INSERT INTO @Retorno
    EXEC master.sys.xp_cmdshell 
        @command_string = @Query

    SELECT @Saida = Resultado
    FROM @Retorno
    WHERE Linha = 1

END
GO




CREATE PROCEDURE xpcmdshell.stpArquivo_Listar (
    @Ds_Diretorio VARCHAR(255)
)
AS BEGIN
    
    DECLARE @Query VARCHAR(8000) = 'dir/ -C /4 /N "' + @Ds_Diretorio + '"'

    DECLARE @Retorno TABLE (
        Linha INT IDENTITY(1, 1),
        Resultado VARCHAR(MAX)
    )

    DECLARE @Tabela_Final TABLE (
        Linha INT IDENTITY(1, 1),
        Dt_Criacao DATETIME,
        Fl_Tipo BIT,
        Qt_Tamanho INT,
        Ds_Arquivo VARCHAR(255)
    )

    INSERT INTO @Retorno
    EXEC master.sys.xp_cmdshell 
        @command_string = @Query


    INSERT INTO @Tabela_Final(Dt_Criacao, Fl_Tipo, Qt_Tamanho, Ds_Arquivo)
    SELECT 
        CONVERT(DATETIME, LEFT(Resultado, 17), 103) AS Dt_Criacao,
        0 AS Fl_Tipo, 
        0 AS Qt_Tamanho,
        SUBSTRING(Resultado, 37, LEN(Resultado)) AS Ds_Arquivo
    FROM 
        @Retorno
    WHERE 
        Resultado IS NOT NULL
        AND Linha >= 6
        AND Linha < (SELECT MAX(Linha) FROM @Retorno) - 2
        AND Resultado LIKE '%<DIR>%'
        AND SUBSTRING(Resultado, 37, LEN(Resultado)) NOT IN ('.', '..')
    ORDER BY
        Ds_Arquivo
        

    INSERT INTO @Tabela_Final(Dt_Criacao, Fl_Tipo, Qt_Tamanho, Ds_Arquivo)
    SELECT 
        CONVERT(DATETIME, LEFT(Resultado, 17), 103) AS Dt_Criacao,
        1 AS Fl_Tipo, 
        LTRIM(SUBSTRING(LTRIM(Resultado), 18, 19)) AS Qt_Tamanho,
        SUBSTRING(Resultado, CHARINDEX(LTRIM(SUBSTRING(LTRIM(Resultado), 18, 19)), Resultado, 18) + LEN(LTRIM(SUBSTRING(LTRIM(Resultado), 18, 19))) + 1, LEN(Resultado)) AS Ds_Arquivo
    FROM 
        @Retorno
    WHERE 
        Resultado IS NOT NULL
        AND Linha >= 6
        AND Linha < (SELECT MAX(Linha) FROM @Retorno) - 2
        AND Resultado NOT LIKE '%<DIR>%'
    ORDER BY
        Ds_Arquivo

        
    --SELECT * FROM @Retorno
    SELECT * FROM @Tabela_Final


END
GO





CREATE PROCEDURE xpcmdshell.stpArquivo_Ler (
    @Ds_Arquivo VARCHAR(255)
)
AS BEGIN
    
    DECLARE @Query VARCHAR(8000) = 'powershell.exe -ExecutionPolicy Bypass -Command "Get-Content ""' + @Ds_Arquivo + '"""'

    DECLARE @Retorno TABLE (
        Linha INT IDENTITY(1, 1),
        Resultado VARCHAR(MAX)
    )

    INSERT INTO @Retorno
    EXEC master.sys.xp_cmdshell 
        @command_string = @Query
    
    SELECT * FROM @Retorno
    
END
GO


CREATE PROCEDURE xpcmdshell.stpEscreve_Arquivo (
    @Ds_Arquivo VARCHAR(255),
    @Ds_Texto VARCHAR(MAX),
    @Fl_Sobrescrever BIT = 0
)
AS BEGIN
    
    SET NOCOUNT ON

    DECLARE @Query VARCHAR(8000) = 'ECHO ' + @Ds_Texto + (CASE WHEN @Fl_Sobrescrever = 1 THEN ' > ' ELSE ' >> ' END) + ' ' + @Ds_Arquivo + '"'

    DECLARE @Retorno TABLE ( Resultado VARCHAR(MAX) )
    
    INSERT INTO @Retorno
    EXEC master.sys.xp_cmdshell
        @command_string = @Query
    
END
GO


CREATE PROCEDURE xpcmdshell.stpApaga_Arquivo (
    @Ds_Arquivo VARCHAR(255)
)
AS BEGIN
    
    SET NOCOUNT ON

    DECLARE @Query VARCHAR(8000) = 'del /F /Q "' + @Ds_Arquivo + '"'

    DECLARE @Retorno TABLE ( Resultado VARCHAR(MAX) )

    INSERT INTO @Retorno
    EXEC master.sys.xp_cmdshell 
        @command_string = @Query
    
END
GO


CREATE PROCEDURE xpcmdshell.stpCopia_Arquivo (
    @Ds_Arquivo VARCHAR(255),
    @Ds_Diretorio VARCHAR(255),
    @Fl_Sobrescrever BIT = 0
)
AS BEGIN
    

    SET NOCOUNT ON


    DECLARE 
        @Query VARCHAR(8000),
        @Nm_Arquivo_Destino VARCHAR(500) = @Ds_Diretorio + REVERSE(LEFT(REVERSE(@Ds_Arquivo),CHARINDEX('\', REVERSE(@Ds_Arquivo), 1) - 1)),
        @Resultado VARCHAR(MAX)

    
    IF (@Fl_Sobrescrever = 0)
        SET @Query = 'IF EXIST "' + @Nm_Arquivo_Destino + '" ( ECHO Arquivo já existe ) ELSE ( copy "' + @Ds_Arquivo + '" "' + @Ds_Diretorio + '")'
    ELSE
        SET @Query = 'copy ' + (CASE WHEN @Fl_Sobrescrever = 1 THEN '/Y' ELSE '' END) + ' "' + @Ds_Arquivo + '" "' + @Ds_Diretorio + '"'


    DECLARE @Retorno TABLE (
        Linha INT IDENTITY(1, 1),
        Resultado VARCHAR(MAX)
    )

    INSERT INTO @Retorno
    EXEC master.sys.xp_cmdshell 
        @command_string = @Query
    

    SELECT @Resultado = LTRIM(RTRIM(Resultado))
    FROM @Retorno
    WHERE Linha = 1
    
    PRINT @Resultado

END
GO


CREATE PROCEDURE xpcmdshell.stpMove_Arquivo (
    @Ds_Arquivo VARCHAR(255),
    @Ds_Diretorio VARCHAR(255),
    @Fl_Sobrescrever BIT = 0
)
AS BEGIN
    

    SET NOCOUNT ON


    DECLARE 
        @Query VARCHAR(8000),
        @Nm_Arquivo_Destino VARCHAR(500) = @Ds_Diretorio + REVERSE(LEFT(REVERSE(@Ds_Arquivo),CHARINDEX('\', REVERSE(@Ds_Arquivo), 1) - 1)),
        @Resultado VARCHAR(MAX)

    
    IF (@Fl_Sobrescrever = 0)
        SET @Query = 'IF EXIST "' + @Nm_Arquivo_Destino + '" ( ECHO Arquivo já existe ) ELSE ( move "' + @Ds_Arquivo + '" "' + @Ds_Diretorio + '")'
    ELSE
        SET @Query = 'move ' + (CASE WHEN @Fl_Sobrescrever = 1 THEN '/Y' ELSE '' END) + ' "' + @Ds_Arquivo + '" "' + @Ds_Diretorio + '"'


    DECLARE @Retorno TABLE (
        Linha INT IDENTITY(1, 1),
        Resultado VARCHAR(MAX)
    )

    INSERT INTO @Retorno
    EXEC master.sys.xp_cmdshell 
        @command_string = @Query
    

    SELECT @Resultado = LTRIM(RTRIM(Resultado))
    FROM @Retorno
    WHERE Linha = 1
    
    PRINT @Resultado

END
GO


CREATE PROCEDURE xpcmdshell.stpCria_Diretorio (
    @Ds_Diretorio VARCHAR(255)
)
AS BEGIN
    
    SET NOCOUNT ON

    DECLARE @Query VARCHAR(8000) = 'mkdir "' + @Ds_Diretorio + '"'

    DECLARE @Retorno TABLE ( Resultado VARCHAR(MAX) )

    INSERT INTO @Retorno
    EXEC master.sys.xp_cmdshell 
        @command_string = @Query
    
END
GO




CREATE PROCEDURE xpcmdshell.stpApaga_Diretorio (
    @Ds_Diretorio VARCHAR(255),
    @Fl_Recursivo BIT = 0
)
AS BEGIN
    
    SET NOCOUNT ON

    DECLARE @Query VARCHAR(8000) = 'rmdir' + (CASE WHEN @Fl_Recursivo = 1 THEN ' /S' ELSE '' END) + ' "' + @Ds_Diretorio + '"'

    DECLARE @Retorno TABLE ( Resultado VARCHAR(MAX) )

    INSERT INTO @Retorno
    EXEC master.sys.xp_cmdshell 
        @command_string = @Query
    
END
GO
