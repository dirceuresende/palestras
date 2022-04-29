CREATE PROCEDURE [dbo].[SaveDelimitedColumns]
    @PCWrite VARCHAR(1000) = NULL,
    @DBFetch VARCHAR(4000),
    @DBWhere VARCHAR(2000) = NULL,
    @DBThere VARCHAR(2000) = NULL,
    @DBUltra BIT = 1,
    @Delimiter VARCHAR(100) = 'CHAR(44)', -- Default is ,
    @TextQuote VARCHAR(100) = 'CHAR(34)', -- Default is "  Use SPACE(0) for none.
    @Header BIT = 0, -- Output header. Default is 0.
    @NullQuoted BIT = 0,
    @DateTimeStyle TINYINT = 120 -- CONVERT Date Time Style. Default is ODBC canonical yyyy-mm-dd hh:mi:ss(24h)
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @Return INT;
    DECLARE @Retain INT;
    DECLARE @Status INT;

    SET @Status = 0;

    DECLARE @TPre VARCHAR(10);

    DECLARE @TDo3 TINYINT;
    DECLARE @TDo4 TINYINT;

    SET @TPre = '';

    SET @TDo3 = LEN(@TPre);
    SET @TDo4 = LEN(@TPre) + 1;

    DECLARE @DBAE VARCHAR(40);
    DECLARE @Task VARCHAR(6000);
    DECLARE @Bank VARCHAR(4000);
    DECLARE @Cash VARCHAR(2000);
    DECLARE @Risk VARCHAR(2000);
    DECLARE @Next VARCHAR(8000);
    DECLARE @Save VARCHAR(8000);
    DECLARE @Work VARCHAR(8000);
    DECLARE @Wish VARCHAR(MAX);

    DECLARE @Name VARCHAR(100);
    DECLARE @Same VARCHAR(100);

    DECLARE @Rank SMALLINT;
    DECLARE @Kind VARCHAR(20);
    DECLARE @Mask BIT;
    DECLARE @Bond BIT;
    DECLARE @Size INT;
    DECLARE @Wide SMALLINT;
    DECLARE @More SMALLINT;

    DECLARE @DBAI VARCHAR(2000);
    DECLARE @DBAO VARCHAR(8000);
    DECLARE @DBAU VARCHAR(MAX);

    DECLARE @Fuse INT;
    DECLARE @File INT;

    DECLARE @HeaderString VARCHAR(8000);
    DECLARE @HeaderDone INT;

    SET @DBAE = '##SaveFile' + RIGHT(CONVERT(VARCHAR(10), @@SPID + 100000), 5);

    SET @Task = 'IF EXISTS (SELECT * FROM tempdb.dbo.sysobjects WHERE name = ' + CHAR(39) + @DBAE + CHAR(39) + ') DROP TABLE ' + @DBAE;

    EXECUTE ( @Task );

    SET @Bank = @TPre + @DBFetch;

    IF NOT EXISTS
    (
        SELECT
            *
        FROM
            sysobjects
        WHERE
            RTRIM(type) = 'U'
            AND name = @Bank
    )
    BEGIN
        SET @Bank = CASE WHEN LEFT(LTRIM(@DBFetch), 6) = 'SELECT' THEN '(' + @DBFetch + ')' ELSE @DBFetch END;
        SET @Bank = REPLACE(@Bank, CHAR(94), CHAR(39));
        SET @Bank = REPLACE(@Bank, CHAR(45) + CHAR(45), CHAR(32));
        SET @Bank = REPLACE(@Bank, CHAR(47) + CHAR(42), CHAR(32));
    END;

    IF @DBWhere IS NOT NULL
    BEGIN
        SET @Cash = REPLACE(@DBWhere, 'WHERE', CHAR(32));
        SET @Cash = REPLACE(@Cash, CHAR(94), CHAR(39));
        SET @Cash = REPLACE(@Cash, CHAR(45) + CHAR(45), CHAR(32));
        SET @Cash = REPLACE(@Cash, CHAR(47) + CHAR(42), CHAR(32));
    END;

    IF @DBThere IS NOT NULL
    BEGIN
        SET @Risk = REPLACE(@DBThere, 'ORDER BY', CHAR(32));
        SET @Risk = REPLACE(@Risk, CHAR(94), CHAR(39));
        SET @Risk = REPLACE(@Risk, CHAR(45) + CHAR(45), CHAR(32));
        SET @Risk = REPLACE(@Risk, CHAR(47) + CHAR(42), CHAR(32));
    END;

    SET @DBAI = '';
    SET @DBAO = '';
    SET @DBAU = '';

    SET @Task = 'SELECT * INTO ' + @DBAE + ' FROM (' + @Bank + ') AS T WHERE 0 = 1';
    
    IF @Status = 0
        EXECUTE ( @Task );
    SET @Return = @@ERROR;
    IF @Status = 0
        SET @Status = @Return;

    -- For all columns (Fields) in the table.
    DECLARE Fields CURSOR FAST_FORWARD FOR
    SELECT
        '[' + C.name + ']',
        C.colid,
        T.name,
        C.isnullable,
        C.iscomputed,
        C.length,
        C.prec,
        C.scale
    FROM
        tempdb.dbo.sysobjects AS O
        JOIN tempdb.dbo.syscolumns AS C ON O.id = C.id
        JOIN tempdb.dbo.systypes AS T ON C.xusertype = T.xusertype
    WHERE
        O.name = @DBAE
    ORDER BY
        C.colid;

    SET @Retain = @@ERROR;
    IF @Status = 0
        SET @Status = @Retain;

    OPEN Fields;

    SET @Retain = @@ERROR;
    IF @Status = 0
        SET @Status = @Retain;

    FETCH NEXT FROM Fields
    INTO
        @Same,
        @Rank,
        @Kind,
        @Mask,
        @Bond,
        @Size,
        @Wide,
        @More;

    SET @Retain = @@ERROR;
    IF @Status = 0
        SET @Status = @Retain;

    -- Convert to character for header.
    SET @HeaderString = '';
    DECLARE @sql NVARCHAR(4000);
    DECLARE @cDelimiter NVARCHAR(9);
    DECLARE @cTextQuote NVARCHAR(9);
    DECLARE @TypeFound BIT;
    SET @sql = N'select @cDelimiter = ' + @Delimiter;
    EXEC sp_executesql @sql, N'@cDelimiter varchar(9) output', @cDelimiter OUTPUT;
    SET @sql = N'select @cTextQuote = ' + @TextQuote;
    EXEC sp_executesql @sql, N'@cTextQuote varchar(9) output', @cTextQuote OUTPUT;

    WHILE @@FETCH_STATUS = 0
          AND @Status = 0
    BEGIN
        SET @TypeFound = 0;

        -- Build header.
        IF LEN(@HeaderString) > 0
            SET @HeaderString = @HeaderString + @cDelimiter + ISNULL(@cTextQuote + REPLACE(@Same, @cTextQuote, REPLICATE(@cTextQuote, 2)) + @cTextQuote, SPACE(0));
        IF LEN(@HeaderString) = 0
            SET @HeaderString = ISNULL(@cTextQuote + REPLACE(@Same, @cTextQuote, REPLICATE(@cTextQuote, 2)) + @cTextQuote, SPACE(0));

        IF @Kind IN ( 'char', 'nchar', 'varchar', 'nvarchar', 'text', 'ntext', 'sysname', 'xml' )
        BEGIN
            IF @NullQuoted = 0
            BEGIN
                IF @Rank = 1
                    SET @DBAU = ' ISNULL(' + @TextQuote + '+REPLACE(' + @Same + ' COLLATE SQL_Latin1_General_CP1_CI_AI,' + @TextQuote + ',REPLICATE(' + @TextQuote + ',2))+' + @TextQuote + ',SPACE(0))';
                IF @Rank > 1
                    SET @DBAU = @DBAU + '+' + @Delimiter + '+ISNULL(' + @TextQuote + '+REPLACE(' + @Same + ' COLLATE SQL_Latin1_General_CP1_CI_AI,' + @TextQuote + ',REPLICATE(' + @TextQuote + ',2))+' + @TextQuote + ',SPACE(0))';
            END;
            IF @NullQuoted = 1
            BEGIN
                IF @Rank = 1
                    SET @DBAU = ' ISNULL(' + @TextQuote + '+REPLACE(' + @Same + ' COLLATE SQL_Latin1_General_CP1_CI_AI,' + @TextQuote + ',REPLICATE(' + @TextQuote + ',2))+' + @TextQuote + ',' + @TextQuote + '+' + @TextQuote + ')';
                IF @Rank > 1
                    SET @DBAU = @DBAU + '+' + @Delimiter + '+ISNULL(' + @TextQuote + '+REPLACE(' + @Same + ' COLLATE SQL_Latin1_General_CP1_CI_AI,' + @TextQuote + ',REPLICATE(' + @TextQuote + ',2))+' + @TextQuote + ',' + @TextQuote + '+' + @TextQuote + ')';
            END;
            SET @TypeFound = 1;
        END;

        IF @Kind IN ( 'bit', 'tinyint', 'smallint', 'int', 'bigint' )
        BEGIN
            IF @NullQuoted = 0
            BEGIN
                IF @Rank = 1
                    SET @DBAU = ' ISNULL(CONVERT(varchar(128),' + @Same + '),SPACE(0))';
                IF @Rank > 1
                    SET @DBAU = @DBAU + '+' + @Delimiter + '+ISNULL(CONVERT(varchar(128),' + @Same + '),SPACE(0))';
            END;
            IF @NullQuoted = 1
            BEGIN
                IF @Rank = 1
                    SET @DBAU = ' ISNULL(CONVERT(varchar(128),' + @Same + '),' + @TextQuote + '+' + @TextQuote + ')';
                IF @Rank > 1
                    SET @DBAU = @DBAU + '+' + @Delimiter + '+ISNULL(CONVERT(varchar(128),' + @Same + '),' + @TextQuote + '+' + @TextQuote + ')';
            END;
            SET @TypeFound = 1;
        END;

        IF @Kind IN ( 'numeric', 'decimal', 'money', 'smallmoney', 'float', 'real' )
        BEGIN
            IF @NullQuoted = 0
            BEGIN
                IF @Rank = 1
                    SET @DBAU = ' ISNULL(CONVERT(varchar(128),' + @Same + '),SPACE(0))';
                IF @Rank > 1
                    SET @DBAU = @DBAU + '+' + @Delimiter + '+ISNULL(CONVERT(varchar(128),' + @Same + '),SPACE(0))';
            END;
            IF @NullQuoted = 1
            BEGIN
                IF @Rank = 1
                    SET @DBAU = ' ISNULL(CONVERT(varchar(128),' + @Same + '),' + @TextQuote + '+' + @TextQuote + ')';
                IF @Rank > 1
                    SET @DBAU = @DBAU + '+' + @Delimiter + '+ISNULL(CONVERT(varchar(128),' + @Same + '),' + @TextQuote + '+' + @TextQuote + ')';
            END;
            SET @TypeFound = 1;
        END;

        IF @Kind IN ( 'uniqueidentifier', 'geometry', 'geography' )
        BEGIN
            IF @NullQuoted = 0
            BEGIN
                IF @Rank = 1
                    SET @DBAU = ' ISNULL(' + @TextQuote + '+CONVERT(varchar(128),' + @Same + ')+' + @TextQuote + ',SPACE(0))';
                IF @Rank > 1
                    SET @DBAU = @DBAU + '+' + @Delimiter + '+ISNULL(' + @TextQuote + '+CONVERT(varchar(128),' + @Same + ')+' + @TextQuote + ',SPACE(0))';
            END;
            IF @NullQuoted = 1
            BEGIN
                IF @Rank = 1
                    SET @DBAU = ' ISNULL(' + @TextQuote + '+CONVERT(varchar(128),' + @Same + ')+' + @TextQuote + ',' + @TextQuote + '+' + @TextQuote + ')';
                IF @Rank > 1
                    SET @DBAU = @DBAU + '+' + @Delimiter + '+ISNULL(' + @TextQuote + '+CONVERT(varchar(128),' + @Same + ')+' + @TextQuote + ',' + @TextQuote + '+' + @TextQuote + ')';
            END;
            SET @TypeFound = 1;
        END;

        IF @Kind IN ( 'datetime2', 'datetime', 'smalldatetime', 'time', 'date', 'datetimeoffset' )
        BEGIN
            IF @NullQuoted = 0
            BEGIN
                IF @Rank = 1
                    SET @DBAU = ' ISNULL(' + @TextQuote + '+CONVERT(varchar(128),' + @Same + ',' + CONVERT(VARCHAR(3), @DateTimeStyle) + ')+' + @TextQuote + ',SPACE(0))';
                IF @Rank > 1
                    SET @DBAU = @DBAU + '+' + @Delimiter + '+ISNULL(' + @TextQuote + '+CONVERT(varchar(128),' + @Same + ',' + CONVERT(VARCHAR(3), @DateTimeStyle) + ')+' + @TextQuote + ',SPACE(0))';
            END;
            IF @NullQuoted = 1
            BEGIN
                IF @Rank = 1
                    SET @DBAU = ' ISNULL(' + @TextQuote + '+CONVERT(varchar(128),' + @Same + ',' + CONVERT(VARCHAR(3), @DateTimeStyle) + ')+' + @TextQuote + ',' + @TextQuote + '+' + @TextQuote + ')';
                IF @Rank > 1
                    SET @DBAU = @DBAU + '+' + @Delimiter + '+ISNULL(' + @TextQuote + '+CONVERT(varchar(128),' + @Same + ',' + CONVERT(VARCHAR(3), @DateTimeStyle) + ')+' + @TextQuote + ',' + @TextQuote + '+' + @TextQuote + ')';
            END;
            SET @TypeFound = 1;
        END;

        IF @TypeFound = 0
        BEGIN
            SET @Retain = 'ERROR: Data type ' + UPPER(@Kind) + ' was used but not supported by SaveDelimitedColumns.';
            SET @Status = @Retain;
        END;

        FETCH NEXT FROM Fields
        INTO
            @Same,
            @Rank,
            @Kind,
            @Mask,
            @Bond,
            @Size,
            @Wide,
            @More;

        SET @Retain = @@ERROR;
        IF @Status = 0
            SET @Status = @Retain;
    END;

    CLOSE Fields;
    DEALLOCATE Fields;

    IF LEN(@DBAU) = 0
        SET @DBAU = '*';

    IF @PCWrite IS NOT NULL
       AND ( @DBUltra = 0 )
       AND ( @Header = 1 )
    BEGIN
        SET @HeaderString = REPLACE(@HeaderString, '"', '""');
        SET @DBAI = ' SELECT ' + CHAR(39) + @HeaderString + CHAR(39) + ' UNION ALL SELECT ';
    END;
    ELSE
        SET @DBAI = ' SELECT ';

    SET @DBAO = ' FROM (' + @Bank + ') AS T' + CASE WHEN @DBWhere IS NULL THEN '' ELSE ' WHERE (' + @Cash + ') AND 0 = 0' END + CASE WHEN @DBThere IS NULL THEN '' ELSE ' ORDER BY ' + @Risk END;

    -- Output where @DBUltra = 0 (Uses XP_CMDSHELL \ BCP)
    IF @PCWrite IS NOT NULL
       AND @DBUltra = 0
    BEGIN
        SET @Wish = 'USE ' + DB_NAME() + @DBAI + @DBAU + @DBAO;
        SET @Work = 'BCP "' + @Wish + '" QUERYOUT "' + @PCWrite + '" -w -T -S "' + @@SERVERNAME + '" ';
        -- PRINT @Work
        EXECUTE @Return = master.dbo.xp_cmdshell @Work, NO_OUTPUT;
        SET @Retain = @@ERROR;
        IF @Status = 0
            SET @Status = @Retain;
        IF @Status = 0
            SET @Status = @Return;

        IF @Status <> 0
            GOTO ABORT;
    END;

    -- Output where @DBUltra = 1 (Uses Ole Automation)
    IF @PCWrite IS NOT NULL
       AND @DBUltra = 1
    BEGIN
        IF @Status = 0
            EXECUTE @Return = sp_OACreate 'Scripting.FileSystemObject', @Fuse OUTPUT;
        SET @Retain = @@ERROR;
        IF @Status = 0
            SET @Status = @Retain;
        IF @Status = 0
            SET @Status = @Return;

        IF @Status = 0
            EXECUTE @Return = sp_OAMethod @Fuse, 'CreateTextFile', @File OUTPUT, @PCWrite, -1;
        SET @Retain = @@ERROR;
        IF @Status = 0
            SET @Status = @Retain;
        IF @Status = 0
            SET @Status = @Return;

        IF @Status <> 0
            GOTO ABORT;
    END;

    SET @DBAI = 'DECLARE Records CURSOR GLOBAL FAST_FORWARD FOR' + @DBAI;

    
    IF @Status = 0
        EXECUTE ( @DBAI + @DBAU + @DBAO );
    SET @Return = @@ERROR;
    IF @Status = 0
        SET @Status = @Return;

    OPEN Records;
    SET @Retain = @@ERROR;
    IF @Status = 0
        SET @Status = @Retain;

    FETCH NEXT FROM Records
    INTO
        @Next;
    SET @Retain = @@ERROR;
    IF @Status = 0
        SET @Status = @Retain;

    -- Header.
    SET @HeaderDone = 0;
    WHILE @@FETCH_STATUS = 0
          AND @Status = 0
    BEGIN
        IF @PCWrite IS NOT NULL
           AND @DBUltra = 1
        BEGIN
            -- Write header (FILE).
            IF ( @Header = 1 )
               AND ( @HeaderDone = 0 )
            BEGIN
                SET @Save = @HeaderString + CHAR(13) + CHAR(10);
                IF @Status = 0
                    EXECUTE @Return = sp_OAMethod @File, 'Write', NULL, @Save;
                SET @HeaderDone = 1;
            END;

            -- Write the data (FILE).
            SET @Save = @Next + CHAR(13) + CHAR(10);
            IF @Status = 0
                EXECUTE @Return = sp_OAMethod @File, 'Write', NULL, @Save;
            IF @Status = 0
                SET @Status = @Return;
        END;

        IF @PCWrite IS NULL
        BEGIN
            -- Print header (TEXT).
            IF ( @Header = 1 )
               AND ( @HeaderDone = 0 )
            BEGIN
                PRINT @HeaderString + CHAR(13) + CHAR(10);
                SET @HeaderDone = 1;
            END;
            PRINT @Next;
        END;

        FETCH NEXT FROM Records
        INTO
            @Next;
        SET @Retain = @@ERROR;
        IF @Status = 0
            SET @Status = @Retain;
    END;

    CLOSE Records;
    DEALLOCATE Records;

    -- Close output file (Ole Automation)
    IF @PCWrite IS NOT NULL
       AND @DBUltra = 1
    BEGIN
        EXECUTE @Return = sp_OAMethod @File, 'Close', NULL;
        IF @Status = 0
            SET @Status = @Return;

        EXECUTE @Return = sp_OADestroy @File;
        IF @Status = 0
            SET @Status = @Return;

        EXECUTE @Return = sp_OADestroy @Fuse;
        IF @Status = 0
            SET @Status = @Return;
    END;

    ABORT: -- This label is referenced when OLE automation fails.

    IF @Status = 1 OR @Status NOT BETWEEN 0 AND 50000
        RAISERROR('SaveDelimitedColumns Windows Error [%d]', 16, 1, @Status);

    SET @Task = 'IF EXISTS (SELECT * FROM tempdb.dbo.sysobjects WHERE name = ' + CHAR(39) + @DBAE + CHAR(39) + ') DROP TABLE ' + @DBAE;
    EXECUTE ( @Task );

    RETURN ( @Status );

END;
GO

