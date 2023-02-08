-- Apaga a sessão, caso ela já exista
IF ((SELECT COUNT(*) FROM sys.server_event_sessions WHERE [name] = 'Captura Erros do Sistema') > 0) DROP EVENT SESSION [Captura Erros do Sistema] ON SERVER 
GO

CREATE EVENT SESSION [Captura Erros do Sistema] ON SERVER 
ADD EVENT sqlserver.error_reported (
    ACTION(client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.sql_text)

    -- Adicionado manualmente, pois não é possível filtrar pela coluna "Severity" pela interface
    WHERE severity > 10
)
ADD TARGET package0.event_file(SET filename=N'D:\SQL\Traces\Captura Erros do Sistema',max_file_size=(3),max_rollover_files=(1))
WITH (STARTUP_STATE=ON) -- Será iniciado automaticamente com a instância
GO

-- Ativando a sessão (por padrão, ela é criada desativada)
ALTER EVENT SESSION [Captura Erros do Sistema] ON SERVER STATE = START
GO



IF (OBJECT_ID('dbo.Historico_Erros_Banco') IS NULL)
BEGIN

    -- DROP TABLE dbo.Historico_Erros_Banco
    CREATE TABLE dbo.Historico_Erros_Banco (
        Dt_Evento DATETIME,
        session_id INT,
        [database_name] VARCHAR(100),
        session_nt_username VARCHAR(100),
        client_hostname VARCHAR(100),
        client_app_name VARCHAR(100),
        [error_number] INT,
        severity INT,
        [state] INT,
        sql_text XML,
        [message] VARCHAR(MAX)
    )

    CREATE CLUSTERED INDEX SK01_Historico_Erros ON dbo.Historico_Erros_Banco(Dt_Evento)

END



DECLARE @TimeZone INT = DATEDIFF(HOUR, GETUTCDATE(), GETDATE())
DECLARE @Dt_Ultimo_Evento DATETIME = ISNULL((SELECT MAX(Dt_Evento) FROM dbo.Historico_Erros_Banco WITH(NOLOCK)), '1990-01-01')


IF (OBJECT_ID('tempdb..#Eventos') IS NOT NULL) DROP TABLE #Eventos

;WITH CTE AS (
    SELECT CONVERT(XML, event_data) AS event_data
    FROM sys.fn_xe_file_target_read_file(N'D:\SQL\Traces\Captura Erros do Sistema*.xel', NULL, NULL, NULL)
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


SET QUOTED_IDENTIFIER ON

INSERT INTO dbo.Historico_Erros_Banco
SELECT
    A.Dt_Evento,
    xed.event_data.value('(action[@name="session_id"]/value)[1]', 'int') AS [session_id],
    xed.event_data.value('(action[@name="database_name"]/value)[1]', 'varchar(100)') AS [database_name],
    xed.event_data.value('(action[@name="session_nt_username"]/value)[1]', 'varchar(100)') AS [session_nt_username],
    xed.event_data.value('(action[@name="client_hostname"]/value)[1]', 'varchar(100)') AS [client_hostname],
    xed.event_data.value('(action[@name="client_app_name"]/value)[1]', 'varchar(100)') AS [client_app_name],
    xed.event_data.value('(data[@name="error_number"]/value)[1]', 'int') AS [error_number],
    xed.event_data.value('(data[@name="severity"]/value)[1]', 'int') AS [severity],
    xed.event_data.value('(data[@name="state"]/value)[1]', 'int') AS [state],
    TRY_CAST(xed.event_data.value('(action[@name="sql_text"]/value)[1]', 'varchar(max)') AS XML) AS [sql_text],
    xed.event_data.value('(data[@name="message"]/value)[1]', 'varchar(max)') AS [message]
FROM
    #Eventos A
    CROSS APPLY A.event_data.nodes('//event') AS xed (event_data)


SELECT * FROM dbo.Historico_Erros_Banco