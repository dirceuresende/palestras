sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'Ole Automation Procedures', 1;
GO
RECONFIGURE;
GO
sp_configure 'Agent XPs', 1;
GO
RECONFIGURE;
GO
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO


CREATE FUNCTION [ole].[fncArquivo_Existe_FSO_FSO] (@strArquivo VARCHAR(1000))
RETURNS INT 
AS 
BEGIN

    DECLARE	
        @hr INT,
        @objFileSystem INT,
        @retorno INT,
        @source VARCHAR(250),
        @description VARCHAR(2000)


    EXEC @hr = sp_OACreate
        'Scripting.FileSystemObject',
        @objFileSystem OUT
        
    IF @hr <> 0
    BEGIN
    
        EXEC sp_OAGetErrorInfo
            @objFileSystem,
            @source OUT,
            @description OUT
            
        RETURN 0
        
    END

    EXEC @hr = sp_OAMethod
        @objFileSystem,
        'FileExists',
        @retorno OUT,
        @strArquivo
        
    IF (@hr <> 0)
    BEGIN
    
        EXEC sp_OAGetErrorInfo
            @objFileSystem,
            @source OUT,
            @description OUT
            
        EXEC sp_OADestroy
            @objFileSystem
            
        RETURN 0
        
    END
    
    
    EXEC sp_OADestroy
        @objFileSystem
        
        
    RETURN @retorno

END
GO


CREATE FUNCTION [ole].[fncLer_Arquivo_FSO] (@Ds_Arquivo VARCHAR(256))
RETURNS @Tabela_Final TABLE (Ds_Linha VARCHAR(8000))
AS
BEGIN
 
    DECLARE @OLEResult INT
    DECLARE @FileSystemObject INT
    DECLARE @FileID INT
    DECLARE @Message VARCHAR (8000)
 
    DECLARE @Tabela TABLE ( Ds_Linha varchar(8000) )
 
    EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FileSystemObject OUT
    IF @OLEResult <> 0
    BEGIN
        SET @Message = 'Scripting.FileSystemObject - Error code: ' + CONVERT (VARCHAR, @OLEResult)
        INSERT INTO @Tabela_Final SELECT @Message
        RETURN
    END
 
    EXEC @OLEResult = sp_OAMethod @FileSystemObject, 'OpenTextFile', @FileID OUT, @Ds_Arquivo, 1, 1
    IF @OLEResult <> 0
    BEGIN
        SET @Message = 'OpenTextFile - Error code: ' + CONVERT (VARCHAR, @OLEResult)
        INSERT INTO @Tabela_Final SELECT @Message
        RETURN
    END
 
    EXECUTE @OLEResult = sp_OAMethod @FileID, 'ReadLine', @Message OUT
 
    WHILE (@OLEResult >= 0)
    BEGIN
 
        INSERT INTO @Tabela(Ds_Linha) VALUES( @Message )
        EXECUTE @OLEResult = sp_OAMethod @FileID, 'ReadLine', @Message OUT
 
    END
 
    EXECUTE @OLEResult = sp_OADestroy @FileID
    EXECUTE @OLEResult = sp_OADestroy @FileSystemObject
    
    
    INSERT INTO @Tabela_Final
    SELECT Ds_Linha FROM @Tabela
    
    
    RETURN
    
END
GO


CREATE PROCEDURE [ole].[stpApaga_Arquivo_FSO] (@strArquivo VARCHAR(1000))
AS 
BEGIN

    DECLARE	
        @hr INT,
        @objFileSystem INT,
        @source VARCHAR(250),
        @description VARCHAR(2000)


    EXEC @hr = sp_OACreate
        'Scripting.FileSystemObject',
        @objFileSystem OUT
        
    IF @hr <> 0
    BEGIN
    
        EXEC sp_OAGetErrorInfo
            @objFileSystem,
            @source OUT,
            @description OUT
        
    END

    
    IF (ole.fncArquivo_Existe_FSO_FSO(@strArquivo) = 1)
    BEGIN
    
        EXEC @hr = sp_OAMethod
            @objFileSystem,
            'DeleteFile',
            NULL,
            @strArquivo
            
    END
    
    
    IF (@hr <> 0)
    BEGIN
    
        EXEC sp_OAGetErrorInfo
            @objFileSystem,
            @source OUT,
            @description OUT
            
        EXEC sp_OADestroy
            @objFileSystem
        
    END
    
    
    EXEC sp_OADestroy
        @objFileSystem
    

END
GO



CREATE PROCEDURE [ole].[stpCopia_Arquivo_FSO] (
    @strOrigem VARCHAR(MAX),
    @strDestino VARCHAR(MAX),
    @sobrescrever INT = 0
)
AS
BEGIN

    IF (ole.fncArquivo_Existe_FSO(@strOrigem) = 1 AND @strOrigem != @strDestino)
    BEGIN

        DECLARE	
            @hr INT,
            @objFileSystem INT,
            @source VARCHAR(250),
            @description VARCHAR(2000)


        EXEC @hr = sp_OACreate
            'Scripting.FileSystemObject',
            @objFileSystem OUT
            
            
        IF @hr <> 0
        BEGIN
        
            EXEC sp_OAGetErrorInfo
                @objFileSystem,
                @source OUT,
                @description OUT
                
            RAISERROR('Object Creation Failed 0x%x, %s, %s',16,1,@hr,@source,@description)
            
            RETURN
        END

        
        IF (ole.fncArquivo_Existe_FSO(@strDestino) = 1)
            IF (@sobrescrever = 1) 
                EXEC ole.stpApaga_Arquivo_FSO @strDestino
            ELSE
            BEGIN
                PRINT 'O arquivo de destino já existe e o parâmetro sobrescrever foi definido como NÃO'
                RETURN
            END
            
        
        
        EXEC @hr = sp_OAMethod
            @objFileSystem,
            'CopyFile',
            NULL,
            @strOrigem,
            @strDestino
            
        IF (@hr <> 0)
        BEGIN
        
            EXEC sp_OAGetErrorInfo
                @objFileSystem,
                @source OUT,
                @description OUT
                
            EXEC sp_OADestroy
                @objFileSystem
                
            RAISERROR('Method Failed 0x%x, %s, %s',16, 1, @hr, @source, @description)
            
            PRINT @source
            PRINT @description
            
            RETURN
            
        END
        
        
        EXEC sp_OADestroy
            @objFileSystem
        
    END
    ELSE
        PRINT 'O arquivo de origem não existe ou é igual ao arquivo de destino'

END 
GO



CREATE PROCEDURE [ole].[stpEscreve_Arquivo_FSO] (
    @String VARCHAR(MAX),
    @Ds_Arquivo VARCHAR(1501)
)
AS
BEGIN

    DECLARE
        @objFileSystem INT,
        @objTextStream INT,
        @objErrorObject INT,
        @strErrorMessage VARCHAR(1000),
        @Command VARCHAR(1000),
        @hr INT

    SET NOCOUNT ON

    SELECT
        @strErrorMessage = 'opening the File System Object'
    
    EXECUTE @hr = sp_OACreate
        'Scripting.FileSystemObject',
        @objFileSystem OUT

    
    IF @hr = 0
        SELECT
            @objErrorObject = @objFileSystem,
            @strErrorMessage = 'Creating file "' + @Ds_Arquivo + '"'
    
    
    IF @hr = 0
        EXECUTE @hr = sp_OAMethod
            @objFileSystem,
            'CreateTextFile',
            @objTextStream OUT,
            @Ds_Arquivo,
            2,
            True

    IF @hr = 0
        SELECT
            @objErrorObject = @objTextStream,
            @strErrorMessage = 'writing to the file "' + @Ds_Arquivo + '"'
    
    
    IF @hr = 0
        EXECUTE @hr = sp_OAMethod
            @objTextStream,
            'Write',
            NULL,
            @String

    
    IF @hr = 0
        SELECT
            @objErrorObject = @objTextStream,
            @strErrorMessage = 'closing the file "' + @Ds_Arquivo + '"'
    
    
    IF @hr = 0
        EXECUTE @hr = sp_OAMethod
            @objTextStream,
            'Close'

    
    IF @hr <> 0
    BEGIN
    
        DECLARE
            @source VARCHAR(255),
            @Description VARCHAR(255),
            @Helpfile VARCHAR(255),
            @HelpID INT
    
        EXECUTE sp_OAGetErrorInfo
            @objErrorObject,
            @source OUTPUT,
            @Description OUTPUT,
            @Helpfile OUTPUT,
            @HelpID OUTPUT
        
        
        SELECT
            @strErrorMessage = 'Error whilst ' + COALESCE(@strErrorMessage, 'doing something') + ', ' + COALESCE(@Description, '')
        
        
        RAISERROR (@strErrorMessage,16,1)
        
    END
    
    
    EXECUTE sp_OADestroy
        @objTextStream
    
    EXECUTE sp_OADestroy
        @objTextStream
        
END
GO



CREATE PROCEDURE [ole].stpInformacoes_Arquivo_FSO(@strArquivo VARCHAR(255))
AS
BEGIN

    DECLARE
        @hr INT,
        @objFileSystem INT,
        @objFile INT,
        @ErrorObject INT,
        @ErrorMessage VARCHAR(255),
        @Path VARCHAR(255),--
        @ShortPath VARCHAR(255),
        @Type VARCHAR(100),
        @DateCreated DATETIME,
        @DateLastAccessed DATETIME,
        @DateLastModified DATETIME,
        @Attributes INT,
        @size INT
 
 
    SET nocount ON
 
    SELECT
        @hr = 0,
        @ErrorMessage = 'opening the file system object '
    
    EXEC @hr = sp_OACreate
        'Scripting.FileSystemObject',
        @objFileSystem OUT
        
    IF @hr = 0
        SELECT
            @ErrorMessage = 'accessing the file ''' + @strArquivo + '''',
            @ErrorObject = @objFileSystem
    
    IF @hr = 0
        EXEC @hr = sp_OAMethod
            @objFileSystem,
            'GetFile',
            @objFile OUT,
            @strArquivo
            
    IF @hr = 0
        SELECT
            @ErrorMessage = 'getting the attributes of ''' + @strArquivo + '''',
            @ErrorObject = @objFile
            
    IF @hr = 0
        EXEC @hr = sp_OAGetProperty
            @objFile,
            'Path',
            @Path OUT
            
    IF @hr = 0
        EXEC @hr = sp_OAGetProperty
            @objFile,
            'ShortPath',
            @ShortPath OUT
            
    IF @hr = 0
        EXEC @hr = sp_OAGetProperty
            @objFile,
            'Type',
            @Type OUT
            
    IF @hr = 0
        EXEC @hr = sp_OAGetProperty
            @objFile,
            'DateCreated',
            @DateCreated OUT
            
    IF @hr = 0
        EXEC @hr = sp_OAGetProperty
            @objFile,
            'DateLastAccessed',
            @DateLastAccessed OUT
            
    IF @hr = 0
        EXEC @hr = sp_OAGetProperty
            @objFile,
            'DateLastModified',
            @DateLastModified OUT
            
    IF @hr = 0
        EXEC @hr = sp_OAGetProperty
            @objFile,
            'Attributes',
            @Attributes OUT
            
    IF @hr = 0
        EXEC @hr = sp_OAGetProperty
            @objFile,
            'size',
            @size OUT
 
 
    IF @hr <> 0
    BEGIN
        DECLARE
            @source VARCHAR(255),
            @Description VARCHAR(255),
            @Helpfile VARCHAR(255),
            @HelpID INT
   
        EXECUTE sp_OAGetErrorInfo
            @ErrorObject,
            @source OUTPUT,
            @Description OUTPUT,
            @Helpfile OUTPUT,
            @HelpID OUTPUT
 
        SELECT
            @ErrorMessage = 'Error whilst ' + @ErrorMessage + ', ' + @Description
            
        RAISERROR (@ErrorMessage,16,1)
        
    END
    
    EXEC sp_OADestroy
        @objFileSystem
        
    EXEC sp_OADestroy
        @objFile
        
    SELECT
        [Path] = @Path,
        [ShortPath] = @ShortPath,
        [Type] = @Type,
        [DateCreated] = @DateCreated,
        [DateLastAccessed] = @DateLastAccessed,
        [DateLastModified] = @DateLastModified,
        [Attributes] = @Attributes,
        [Size] = @size
        
    RETURN @hr

END
GO


CREATE PROCEDURE [ole].[stpMove_Arquivo_FSO] (
    @strOrigem VARCHAR(MAX),
    @strDestino VARCHAR(MAX),
    @sobrescrever INT = 0
)
AS
BEGIN

    IF (ole.fncArquivo_Existe_FSO(@strOrigem) = 1 AND @strOrigem != @strDestino)
    BEGIN

        DECLARE	
            @hr INT,
            @objFileSystem INT,
            @source VARCHAR(250),
            @description VARCHAR(2000)


        EXEC @hr = sp_OACreate
            'Scripting.FileSystemObject',
            @objFileSystem OUT
            
            
        IF @hr <> 0
        BEGIN
        
            EXEC sp_OAGetErrorInfo
                @objFileSystem,
                @source OUT,
                @description OUT
                
            RAISERROR('Object Creation Failed 0x%x, %s, %s',16,1,@hr,@source,@description)
            
            RETURN
        END

        
        IF (ole.fncArquivo_Existe_FSO(@strDestino) = 1)
            IF (@sobrescrever = 1) 
                EXEC ole.stpApaga_Arquivo_FSO @strDestino
            ELSE
            BEGIN
                PRINT 'O arquivo de destino já existe e o parâmetro sobrescrever foi definido como NÃO'
                RETURN
            END
            
        
        
        EXEC @hr = sp_OAMethod
            @objFileSystem,
            'CopyFile',
            NULL,
            @strOrigem,
            @strDestino
            
        IF (@hr <> 0)
        BEGIN
        
            EXEC sp_OAGetErrorInfo
                @objFileSystem,
                @source OUT,
                @description OUT
                
            EXEC sp_OADestroy
                @objFileSystem
                
            RAISERROR('Method Failed 0x%x, %s, %s',16, 1, @hr, @source, @description)
            
            PRINT @source
            PRINT @description
            
            RETURN
            
        END
        ELSE BEGIN
        
            EXEC ole.stpApaga_Arquivo_FSO @strOrigem
        
        END
        
        
        EXEC sp_OADestroy
            @objFileSystem
            
            
        
    END
    ELSE
        PRINT 'O arquivo de origem não existe ou é igual ao arquivo de destino'

END 
GO
