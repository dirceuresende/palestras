CREATE SCHEMA [excel]
GO

CREATE PROCEDURE [excel].[stpImporta_Excel](
    @Caminho VARCHAR(5000), 
    @Aba VARCHAR(200), 
    @Colunas VARCHAR(5000)
)
AS
BEGIN

    DECLARE @Exec VARCHAR(MAX)

    SET @Exec = 'SELECT * from OPENROWSET (''Microsoft.ACE.OLEDB.12.0'', ''Excel 12.0;Database='
        + @Caminho
        + ';'',	''SELECT '
        + @Colunas
        + ' FROM ['
        + @Aba
        + '$]'') A'

    EXEC(@Exec)
 
END
GO


CREATE PROCEDURE [excel].[stpInsere_em_Excel](
    @Caminho VARCHAR(MAX), 
    @Aba varchar(200), 
    @Tabela varchar(200), 
    @Colunas varchar(MAX)
)
AS
BEGIN

    IF (@Colunas = '*')
    BEGIN
    
        SELECT 
            @Colunas = isnull(nullif(@Colunas,'*') + ',','') + b.name
        FROM 
            sysobjects a WITH(NOLOCK)
            JOIN syscolumns b WITH(NOLOCK) ON a.id = b.id
        WHERE 
            a.xtype = 'U'
            AND a.name = @Tabela

    END		
    

    DECLARE @Exec VARCHAR(MAX)

    SET @Exec = 'INSERT INTO OPENROWSET (''Microsoft.ACE.OLEDB.12.0'', ''Excel 12.0;Database='
        + @Caminho
        + ';'',	''SELECT '
        + @Colunas
        + ' FROM ['
        + @Aba
        + '$]'') '
        + 'SELECT '
        + @Colunas
        + ' FROM '
        + @Tabela

    EXEC(@Exec)
 
END
GO



CREATE FUNCTION [dbo].[fncQuebra_Texto] (
    @str NVARCHAR(4000) ,
    @separator CHAR(1)
)
RETURNS TABLE
AS
RETURN
(
    WITH tokens ( p, a, b )
    AS ( 
        SELECT   1, 1, CHARINDEX(@separator, @str)
        UNION ALL
        SELECT   p + 1, b + 1, CHARINDEX(@separator, @str, b + 1)
        FROM     tokens
        WHERE    b > 0
    )
    SELECT  
        p - 1 zeroBasedOccurance ,
        SUBSTRING(@str, a, CASE WHEN b > 0 THEN b - a ELSE 4000 END) AS s
    FROM    
        tokens
);
GO



CREATE PROCEDURE [excel].[stpAtualiza_em_Excel](
    @Caminho varchar(max), 
    @Aba varchar(200), 
    @Tabela varchar(200), 
    @Colunas_Join varchar(max), 
    @Colunas_Update varchar(max)
)
AS
BEGIN
        
    DECLARE 
        @join VARCHAR(MAX) ,
        @update VARCHAR(MAX);


    SELECT  
        @join = ISNULL(@join + ' and ', '') + 'a.' + LTRIM(RTRIM(s)) + ' = b.' + LTRIM(RTRIM(s))
    FROM    
        dbo.fncQuebra_Texto(@Colunas_Join, ',') AS a;
    

    SELECT  
        @update = ISNULL(@update + ',', '') + 'a.' + LTRIM(RTRIM(s)) + ' = b.' + LTRIM(RTRIM(s))
    FROM    
        dbo.fncQuebra_Texto(@Colunas_Update, ',') AS a;
    
    
    DECLARE @Exec VARCHAR(MAX)
    
    SET @Exec = 'UPDATE A '
        + 'SET '
        + @update
        + ' FROM OPENROWSET (''Microsoft.ACE.OLEDB.12.0'', ''Excel 12.0;Database='
        + @Caminho
        + ';'',	''Select * From ['
        + @Aba
        + '$]'') A'
        + ' JOIN '
        + @Tabela
        + ' b'
        + ' ON '
        + @join

    EXEC(@Exec)
 
END
GO

