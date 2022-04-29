USE [master]
GO

IF ((SELECT COUNT(*) FROM sys.server_triggers WHERE name = 'trgAlteracao_Objetos') > 0)
    DROP TRIGGER [trgAlteracao_Objetos] ON ALL SERVER
GO

CREATE TRIGGER [trgAlteracao_Objetos]
ON ALL SERVER -- ON DATABASE
FOR DDL_DATABASE_LEVEL_EVENTS
AS
BEGIN
 
 
    SET NOCOUNT ON
 
 
    DECLARE 
        @Evento XML, 
        @Mensagem VARCHAR(MAX),
 
        @Dt_Evento DATETIME,
        @Ds_Tipo_Evento VARCHAR(30),
        @Ds_Database VARCHAR(50),
        @Ds_Usuario VARCHAR(100),
        @Ds_Schema VARCHAR(20),
        @Ds_Objeto VARCHAR(100),
        @Ds_Tipo_Objeto VARCHAR(20),
        @Ds_Query VARCHAR(MAX)
 
 
    SET @Evento = EVENTDATA()
 
    SELECT 
        @Dt_Evento = @Evento.value('(/EVENT_INSTANCE/PostTime/text())[1]','datetime'),
        @Ds_Tipo_Evento = @Evento.value('(/EVENT_INSTANCE/EventType/text())[1]','varchar(30)'),
        @Ds_Database = @Evento.value('(/EVENT_INSTANCE/DatabaseName/text())[1]','varchar(50)'),
        @Ds_Usuario = @Evento.value('(/EVENT_INSTANCE/LoginName/text())[1]','varchar(100)'),
        @Ds_Schema = @Evento.value('(/EVENT_INSTANCE/SchemaName/text())[1]','varchar(20)'),
        @Ds_Objeto = @Evento.value('(/EVENT_INSTANCE/ObjectName/text())[1]','varchar(100)'),
        @Ds_Tipo_Objeto = @Evento.value('(/EVENT_INSTANCE/ObjectType/text())[1]','varchar(20)'),
        @Ds_Query = @Evento.value('(/EVENT_INSTANCE/TSQLCommand/CommandText/text())[1]','varchar(max)')
 
 
    IF (@Ds_Database IN ('master', 'model', 'msdb'))
    BEGIN
 
        IF (LEFT(@Ds_Tipo_Evento, 6) = 'CREATE')
        BEGIN
 
            SET @Mensagem = 'Você (' + @Ds_Usuario + ') acabou de criar um objeto na database de sistema ' + @Ds_Database + ' e essa operação foi logada. 
 
Favor excluir e criar na database correta. 
 
A equipe de Banco de Dados agradece a sua colaboração.'
 
 
            PRINT @Mensagem
 
 
        END
        ELSE BEGIN
 
            IF (LEFT(@Ds_Tipo_Evento, 5) = 'ALTER')
            BEGIN
 
                SET @Mensagem = 'Você (' + @Ds_Usuario + ') acabou de modificar um objeto na database de sistema ' + @Ds_Database + ' e essa operação foi logada. 
 
Favor criar o objeto na database correta. 
 
A equipe de Banco de Dados agradece a sua colaboração.'
 
 
                PRINT @Mensagem
 
            END
 
        END
 
    END
 
 
    IF (OBJECT_ID('Auditoria.dbo.Alteracao_Objetos') IS NULL)
    BEGIN
 
        -- DROP TABLE Auditoria.dbo.Alteracao_Objetos
        CREATE TABLE Auditoria.dbo.Alteracao_Objetos (
            Id_Auditoria INT IDENTITY(1,1),
            Dt_Evento DATETIME,
            Ds_Tipo_Evento VARCHAR(30),
            Ds_Database VARCHAR(50),
            Ds_Usuario VARCHAR(100),
            Ds_Schema VARCHAR(20),
            Ds_Objeto VARCHAR(100),
            Ds_Tipo_Objeto VARCHAR(20),
            Ds_Query XML
        )
        
        CREATE CLUSTERED INDEX SK01 ON Auditoria.dbo.Alteracao_Objetos(Id_Auditoria)
 
    END
 
 
    IF (@Ds_Database NOT IN ('tempdb'))
    BEGIN
 
        INSERT INTO Auditoria.dbo.Alteracao_Objetos
        SELECT 
            @Dt_Evento,
            @Ds_Tipo_Evento,
            @Ds_Database,
            @Ds_Usuario,
            @Ds_Schema,
            @Ds_Objeto,
            @Ds_Tipo_Objeto,
            @Evento
            
    END
 
 
END
GO
 
ENABLE TRIGGER [trgAlteracao_Objetos] ON ALL SERVER -- ON DATABASE
GO




USE [Auditoria]
GO

GRANT CONNECT TO [guest]
GRANT INSERT ON Auditoria.dbo.Alteracao_Objetos TO [public]
GO