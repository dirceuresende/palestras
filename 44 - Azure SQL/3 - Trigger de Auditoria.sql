IF (OBJECT_ID('dbo.Alteracao_Objetos') IS NULL)
BEGIN
 
    -- DROP TABLE dbo.Alteracao_Objetos
    CREATE TABLE dbo.Alteracao_Objetos (
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
        
    CREATE CLUSTERED INDEX SK01 ON dbo.Alteracao_Objetos(Id_Auditoria)
 
END



IF ((SELECT COUNT(*) FROM sys.triggers WHERE name = 'trgAlteracao_Objetos') > 0)
    DROP TRIGGER [trgAlteracao_Objetos] ON DATABASE
GO

CREATE OR ALTER TRIGGER [trgAlteracao_Objetos]
ON DATABASE
FOR DDL_DATABASE_LEVEL_EVENTS
AS
BEGIN
 
 
    SET NOCOUNT ON
 
 
    DECLARE 
        @Evento XML,
 
        @Dt_Evento DATETIME,
        @Ds_Tipo_Evento VARCHAR(30),
        @Ds_Database VARCHAR(50),
        @Ds_Usuario VARCHAR(100),
        @Ds_Schema VARCHAR(20),
        @Ds_Objeto VARCHAR(100),
        @Ds_Tipo_Objeto VARCHAR(20)
 
 
    SET @Evento = EVENTDATA()
 
    SELECT 
        @Dt_Evento = @Evento.value('(/EVENT_INSTANCE/PostTime/text())[1]','datetime'),
        @Ds_Tipo_Evento = @Evento.value('(/EVENT_INSTANCE/EventType/text())[1]','varchar(30)'),
        @Ds_Database = @Evento.value('(/EVENT_INSTANCE/DatabaseName/text())[1]','varchar(50)'),
        @Ds_Usuario = @Evento.value('(/EVENT_INSTANCE/UserName/text())[1]','varchar(100)'),
        @Ds_Schema = @Evento.value('(/EVENT_INSTANCE/SchemaName/text())[1]','varchar(20)'),
        @Ds_Objeto = @Evento.value('(/EVENT_INSTANCE/ObjectName/text())[1]','varchar(100)'),
        @Ds_Tipo_Objeto = @Evento.value('(/EVENT_INSTANCE/ObjectType/text())[1]','varchar(20)')
 
 
    INSERT INTO dbo.Alteracao_Objetos
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
GO

ENABLE TRIGGER [trgAlteracao_Objetos] ON DATABASE
GO

GRANT INSERT ON dbo.Alteracao_Objetos TO [public]
GO

