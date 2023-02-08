-- sqlcmd -S localhost\sql2019 -t 1 -Q "WAITFOR DELAY '00:00:02'" -Udirceu -Pdirceu

-- Apaga a sessão, caso ela já exista
IF ((SELECT COUNT(*) FROM sys.server_event_sessions WHERE [name] = 'Monitora Timeouts') > 0) DROP EVENT SESSION [Monitora Timeouts] ON SERVER 
GO

CREATE EVENT SESSION [Monitora Timeouts]
ON SERVER
ADD EVENT sqlserver.attention ( 
    ACTION
    (
        sqlserver.client_app_name,
        sqlserver.client_hostname,
        sqlserver.[database_name],
        sqlserver.nt_username,
        sqlserver.num_response_rows,
        sqlserver.server_instance_name,
        sqlserver.server_principal_name,
        sqlserver.server_principal_sid,
        sqlserver.session_id,
        sqlserver.session_nt_username,
        sqlserver.session_server_principal_name,
        sqlserver.sql_text,
        sqlserver.username
    )
)
ADD TARGET package0.event_file ( 
    SET 
        filename = N'D:\SQL\Traces\Monitora_Timeout.xel', -- Não esqueça de mudar o caminho aqui :)
        max_file_size = ( 50 ), -- Tamanho máximo (MB) de cada arquivo
        max_rollover_files = ( 8 ) -- Quantidade de arquivos gerados
)
WITH
(
    STARTUP_STATE = OFF
)

-- Ativando a sessão (por padrão, ela é criada desativada)
ALTER EVENT SESSION [Monitora Timeouts] ON SERVER STATE = START
GO




IF (OBJECT_ID('dbo.Historico_Timeout') IS NULL)
BEGIN

    -- DROP TABLE dbo.Historico_Timeout
    CREATE TABLE dbo.Historico_Timeout (
        [Dt_Evento]            DATETIME,
        [session_id]           INT,
        [duration]             BIGINT,
        [server_instance_name] VARCHAR(100),
        [database_name]        VARCHAR(100),
        [session_nt_username]  VARCHAR(100),
        [nt_username]          VARCHAR(100),
        [client_hostname]      VARCHAR(100),
        [client_app_name]      VARCHAR(100),
        [num_response_rows]    INT,
        [sql_text]             XML
    ) WITH(DATA_COMPRESSION=PAGE)

END


DECLARE @TimeZone INT = DATEDIFF(HOUR, GETUTCDATE(), GETDATE())
DECLARE @Dt_Ultimo_Evento DATETIME = ISNULL((SELECT MAX(Dt_Evento) FROM dbo.Historico_Timeout WITH(NOLOCK)), '1990-01-01')
 
 
IF (OBJECT_ID('tempdb..#Eventos') IS NOT NULL) DROP TABLE #Eventos 
;WITH CTE AS (
    SELECT CONVERT(XML, event_data) AS event_data
    FROM sys.fn_xe_file_target_read_file(N'D:\SQL\Traces\Monitora_Timeout*.xel', NULL, NULL, NULL)
)
SELECT
    DATEADD(HOUR, @TimeZone, CTE.event_data.value('(//event/@timestamp)[1]', 'datetime')) AS Dt_Evento,
    CTE.event_data
INTO
    #Eventos
FROM
    CTE
WHERE
    DATEADD(HOUR, @TimeZone, CTE.event_data.value('(//event/@timestamp)[1]', 'datetime')) > @Dt_Ultimo_Evento
    
 
INSERT INTO dbo.Historico_Timeout
SELECT
    A.Dt_Evento,
    xed.event_data.value('(action[@name="session_id"]/value)[1]', 'int') AS [session_id],
    xed.event_data.value('(data[@name="duration"]/value)[1]', 'bigint') AS [duration],
    xed.event_data.value('(action[@name="server_instance_name"]/value)[1]', 'varchar(100)') AS [server_instance_name],
    xed.event_data.value('(action[@name="database_name"]/value)[1]', 'varchar(100)') AS [database_name],
    xed.event_data.value('(action[@name="session_nt_username"]/value)[1]', 'varchar(100)') AS [session_nt_username],
    xed.event_data.value('(action[@name="nt_username"]/value)[1]', 'varchar(100)') AS [nt_username],
    xed.event_data.value('(action[@name="client_hostname"]/value)[1]', 'varchar(100)') AS [client_hostname],
    xed.event_data.value('(action[@name="client_app_name"]/value)[1]', 'varchar(100)') AS [client_app_name],
    xed.event_data.value('(action[@name="num_response_rows"]/value)[1]', 'int') AS [num_response_rows],
    TRY_CAST(xed.event_data.value('(action[@name="sql_text"]/value)[1]', 'varchar(max)') AS XML) AS [sql_text]
FROM
    #Eventos A
    CROSS APPLY A.event_data.nodes('//event') AS xed (event_data)