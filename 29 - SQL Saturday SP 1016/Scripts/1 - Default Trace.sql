
SELECT configuration_id, [value], value_in_use, is_dynamic, is_advanced
FROM sys.configurations
WHERE [name] = 'default trace enabled'




-- Ativa o trace padrão (caso esteja desativado)
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
EXEC sp_configure 'default trace enabled', 1;
GO
RECONFIGURE;
GO
EXEC sp_configure 'show advanced options', 0;
GO
RECONFIGURE;
GO


-- Lista todos os eventos possíveis
DECLARE @id INT = ( SELECT id FROM sys.traces WHERE is_default = 1 )
 
SELECT DISTINCT
    eventid,
    [name]
FROM
    fn_trace_geteventinfo(@id) A
    JOIN sys.trace_events B ON A.eventid = B.trace_event_id


-- Identificando eventos de DDL e DCL
DECLARE @Ds_Arquivo_Trace VARCHAR(255) = (SELECT SUBSTRING([path], 0, LEN([path])-CHARINDEX('\', REVERSE([path]))+1) + '\Log.trc' FROM sys.traces WHERE is_default = 1)

SELECT
    A.HostName,
    A.ApplicationName,
    A.NTUserName,
    A.NTDomainName,
    A.LoginName,
    A.SPID,
    A.EventClass,
    B.name,
    A.EventSubClass,
    A.TextData,
    A.StartTime,
    A.ObjectName,
    A.DatabaseName,
    A.TargetLoginName,
    A.TargetUserName
FROM
    [fn_trace_gettable](@Ds_Arquivo_Trace, DEFAULT) A
    JOIN master.sys.trace_events B ON A.EventClass = B.trace_event_id
WHERE
    A.EventClass IN ( 164, 46, 47, 108, 110, 152 ) 
    AND A.StartTime >= GETDATE()-7
    AND A.LoginName NOT IN ( 'NT AUTHORITY\NETWORK SERVICE' )
    AND A.LoginName NOT LIKE '%SQLTELEMETRY$%'
    AND A.DatabaseName != 'tempdb'
    AND NOT (B.name LIKE 'Object:%' AND A.ObjectName IS NULL )
    AND NOT (A.ApplicationName LIKE 'Red Gate%' OR A.ApplicationName LIKE '%Intellisense%' OR A.ApplicationName = 'DacFx Deploy')
ORDER BY
    StartTime DESC



-- Identificando quando comandos DBCC foram executados na instância
DECLARE @path VARCHAR(MAX) = (SELECT [path] FROM sys.traces WHERE is_default = 1)

SELECT
    TextData,
    Duration,
    StartTime,
    EndTime,
    SPID,
    ApplicationName,
    LoginName
FROM
    sys.fn_trace_gettable(@path, DEFAULT)
WHERE
    EventClass IN ( 116 )
ORDER BY
    StartTime DESC

    

-- Identificando quando os backups foram restaurados
DECLARE @path VARCHAR(MAX) = (SELECT [path] FROM sys.traces WHERE is_default = 1)

SELECT
    TextData,
    Duration,
    StartTime,
    EndTime,
    SPID,
    ApplicationName,
    LoginName
FROM
    sys.fn_trace_gettable(@path, DEFAULT)
WHERE
    EventClass IN ( 115 ) 
    AND EventSubClass = 2
ORDER BY
    StartTime DESC

