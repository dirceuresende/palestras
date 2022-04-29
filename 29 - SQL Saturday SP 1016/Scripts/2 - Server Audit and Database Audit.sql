USE [master]
GO

IF ((SELECT COUNT(*) FROM sys.server_audits WHERE [name] = 'Auditoria_Arquivo') > 0)
BEGIN

    ALTER SERVER AUDIT Auditoria_Arquivo WITH (STATE = OFF);

    DROP SERVER AUDIT [Auditoria_Arquivo];

END
GO


CREATE SERVER AUDIT [Auditoria_Arquivo]
TO FILE 
(	FILEPATH = N'C:\Auditoria\'
	,MAXSIZE = 100 MB
	,MAX_ROLLOVER_FILES = 4
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = CONTINUE
)
GO

ALTER SERVER AUDIT Auditoria_Arquivo WITH (STATE = ON)
GO


USE [master]
GO

IF ((SELECT COUNT(*) FROM sys.server_audit_specifications WHERE [name] = 'Auditoria_Arquivo_Especificacao') > 0)
BEGIN
    
    ALTER SERVER AUDIT SPECIFICATION [Auditoria_Arquivo_Especificacao] WITH(STATE = OFF);

    DROP SERVER AUDIT SPECIFICATION [Auditoria_Arquivo_Especificacao];

END
GO


CREATE SERVER AUDIT SPECIFICATION [Auditoria_Arquivo_Especificacao]
FOR SERVER AUDIT [Auditoria_Arquivo]
ADD (DATABASE_CHANGE_GROUP)
WITH (STATE = ON)
GO


USE [Auditoria]
GO

IF ((SELECT COUNT(*) FROM sys.database_audit_specifications WHERE [name] = 'Audita_DML') > 0)
BEGIN

    ALTER DATABASE AUDIT SPECIFICATION [Audita_DML] WITH(STATE = OFF);

    DROP DATABASE AUDIT SPECIFICATION [Audita_DML];

END
GO


CREATE DATABASE AUDIT SPECIFICATION [Audita_DML]
FOR SERVER AUDIT [Auditoria_Arquivo]
ADD (DELETE ON DATABASE::[Auditoria] BY [DIRCEU-VM\dirceu]),
ADD (INSERT ON SCHEMA::[dbo] BY [public]),
ADD (INSERT ON OBJECT::[dbo].[Clientes] BY [public])
WITH (STATE = ON)
GO




IF (OBJECT_ID('dbo._Teste') IS NOT NULL) DROP TABLE dbo._Teste
CREATE TABLE dbo._Teste (
    Nome VARCHAR(100)
)

INSERT INTO dbo._Teste
VALUES('Teste'), ('Audit')
GO

ALTER DATABASE Auditoria SET COMPATIBILITY_LEVEL = 140
GO


-- Retorna as informações de um arquivo específico
SELECT event_time,action_id,server_principal_name,statement,* 
FROM sys.fn_get_audit_file('C:\Auditoria\Auditoria_Arquivo_B8CA34F9-D2E9-4F28-98FF-1981A5F5F1BB_0_132455700720700000.sqlaudit',default,default)  



-- Retorna as informações de todos os arquivos
SELECT event_time,action_id,server_principal_name,statement,* 
FROM sys.fn_get_audit_file('C:\Auditoria\*.sqlaudit',default,default)












--------- PERMISSÕES REAIS ------------------

CREATE TABLE [dbo].[Auditoria_Acesso]
(
    [Id_Auditoria] [bigint] NOT NULL IDENTITY(1, 1),
    [Dt_Auditoria] [datetime] NOT NULL,
    [Cd_Acao] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
    [Ds_Maquina] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
    [Ds_Usuario] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
    [Ds_Database] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
    [Ds_Schema] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
    [Ds_Objeto] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
    [Ds_Query] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
    [Fl_Sucesso] [bit] NOT NULL,
    [Ds_IP] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
    [Ds_Programa] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
    [Qt_Duracao] [bigint] NOT NULL,
    [Qt_Linhas_Retornadas] [bigint] NOT NULL,
    [Qt_Linhas_Alteradas] [bigint] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
ALTER TABLE [dbo].[Auditoria_Acesso] ADD CONSTRAINT [PK__Auditori__E9F1DAD4EE3743FE] PRIMARY KEY CLUSTERED ([Id_Auditoria]) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO


USE [master]
GO

IF ((SELECT COUNT(*) FROM sys.server_audits WHERE [name] = 'Auditoria_Acessos') > 0)
BEGIN
    ALTER SERVER AUDIT [Auditoria_Acessos] WITH (STATE = OFF);
    DROP SERVER AUDIT [Auditoria_Acessos]
END


CREATE SERVER AUDIT [Auditoria_Acessos]
TO FILE
(	
    FILEPATH = N'C:\Auditoria\Permissoes\',
    MAXSIZE = 10 MB,
    MAX_ROLLOVER_FILES = 16,
    RESERVE_DISK_SPACE = OFF
)
WITH
(	
    QUEUE_DELAY = 1000,
    ON_FAILURE = CONTINUE,
    AUDIT_GUID = '0b5ad307-ee47-43db-a169-9af67cb661f9'
)
WHERE (([server_principal_name] LIKE '%User' OR [server_principal_name] LIKE 'LS_%') AND [application_name]<>'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense' AND NOT [application_name] LIKE 'Red Gate Software%')
GO


ALTER SERVER AUDIT [Auditoria_Acessos] WITH (STATE = ON)
GO




DECLARE @Query VARCHAR(MAX)
SET @Query = '

IF (''?'' NOT IN (''master'', ''tempdb'', ''model'', ''msdb''))
BEGIN

    USE [?];

    IF ((SELECT COUNT(*) FROM sys.database_audit_specifications WHERE [name] = ''Auditoria_Acessos'') > 0)
    BEGIN

        ALTER DATABASE AUDIT SPECIFICATION [Auditoria_Acessos] WITH (STATE = OFF);
        DROP DATABASE AUDIT SPECIFICATION [Auditoria_Acessos];

    END

    CREATE DATABASE AUDIT SPECIFICATION [Auditoria_Acessos]
    FOR SERVER AUDIT [Auditoria_Acessos]
    ADD (DELETE ON DATABASE::[?] BY [public]),
    ADD (EXECUTE ON DATABASE::[?] BY [public]),
    ADD (INSERT ON DATABASE::[?] BY [public]),
    ADD (SELECT ON DATABASE::[?] BY [public]),
    ADD (UPDATE ON DATABASE::[?] BY [public])
    WITH (STATE = ON);
    
END'


EXEC sys.sp_MSforeachdb @Query






IF (OBJECT_ID('dbo.stpAuditoria_Acessos_Carrega_Dados') IS NULL) EXEC('CREATE PROCEDURE dbo.stpAuditoria_Acessos_Carrega_Dados AS SELECT 1')
GO

ALTER PROCEDURE dbo.stpAuditoria_Acessos_Carrega_Dados
AS
BEGIN

    DECLARE @TimeZone INT = DATEDIFF(HOUR, GETUTCDATE(), GETDATE())
    DECLARE @Dt_Max DATETIME = DATEADD(SECOND, 1, ISNULL((SELECT MAX(Dt_Auditoria) FROM dbo.Auditoria_Acesso), '1900-01-01'))

    INSERT INTO dbo.Auditoria_Acesso
    (
        Dt_Auditoria,
        Cd_Acao,
        Ds_Maquina,
        Ds_Usuario,
        Ds_Database,
        Ds_Schema,
        Ds_Objeto,
        Ds_Query
        Fl_Sucesso,
        Ds_IP,
        Ds_Programa,
        Qt_Duracao,
        Qt_Linhas_Retornadas,
        Qt_Linhas_Alteradas
    )
    SELECT DISTINCT
        DATEADD(HOUR, @TimeZone, event_time) AS event_time,
        action_id,
        server_instance_name,
        server_principal_name,
        [database_name],
        [schema_name],
        [object_name],
        [statement],
        succeeded,
        client_ip,
        application_name,
        duration_milliseconds,
        response_rows,
        affected_rows
    FROM 
        sys.fn_get_audit_file('C:\Auditoria\Permissoes\*.sqlaudit', DEFAULT, DEFAULT)
    WHERE 
        DATEADD(HOUR, @TimeZone, event_time) >= @Dt_Max

END




SELECT DISTINCT 
    Ds_Usuario,
    Ds_Database, 
    Cd_Acao, 
    Ds_Objeto,
    'USE [' + Ds_Database + ']; GRANT ' + (CASE Cd_Acao
        WHEN 'UP' THEN 'UPDATE'
        WHEN 'IN' THEN 'INSERT'
        WHEN 'DL' THEN 'DELETE'
        WHEN 'SL' THEN 'SELECT'
        WHEN 'EX' THEN 'EXECUTE'
    END) + ' ON [' + Ds_Schema + '].[' + Ds_Objeto + '] TO [' + Ds_Usuario + '];' AS Comando 
FROM 
    dbo.Auditoria_Acesso 
WHERE 
    Cd_Acao <> 'UNDO'
ORDER BY
    Ds_Usuario,
    Ds_Database,
    Ds_Objeto



-- Referência
-- https://www.dirceuresende.com/blog/auditoria-sql-server-audit-dml-ddl/

