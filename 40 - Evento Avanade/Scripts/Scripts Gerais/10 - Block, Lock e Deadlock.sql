
-- Identifica locks ativos
SELECT
    A.request_session_id AS session_id,
    COALESCE(G.start_time, F.last_request_start_time) AS start_time,
    COALESCE(G.open_transaction_count, F.open_transaction_count) AS open_transaction_count,
    A.resource_database_id,
    DB_NAME(A.resource_database_id) AS dbname,
    (CASE WHEN A.resource_type = 'OBJECT' THEN D.[name] ELSE E.[name] END) AS ObjectName,
    (CASE WHEN A.resource_type = 'OBJECT' THEN D.is_ms_shipped ELSE E.is_ms_shipped END) AS is_ms_shipped,
    --B.index_id,
    --C.[name] AS index_name,
    --A.resource_type,
    --A.resource_description,
    --A.resource_associated_entity_id,
    A.request_mode,
    A.request_status,
    F.login_name,
    F.[program_name],
    F.[host_name],
    G.blocking_session_id
FROM
    sys.dm_tran_locks A WITH(NOLOCK)
    LEFT JOIN sys.partitions B WITH(NOLOCK) ON B.hobt_id = A.resource_associated_entity_id
    LEFT JOIN sys.indexes C WITH(NOLOCK) ON C.[object_id] = B.[object_id] AND C.index_id = B.index_id
    LEFT JOIN sys.objects D WITH(NOLOCK) ON A.resource_associated_entity_id = D.[object_id]
    LEFT JOIN sys.objects E WITH(NOLOCK) ON B.[object_id] = E.[object_id]
    LEFT JOIN sys.dm_exec_sessions F WITH(NOLOCK) ON A.request_session_id = F.session_id
    LEFT JOIN sys.dm_exec_requests G WITH(NOLOCK) ON A.request_session_id = G.session_id
WHERE
    A.resource_associated_entity_id > 0
    AND A.resource_database_id = DB_ID()
    AND A.resource_type = 'OBJECT'
    AND (CASE WHEN A.resource_type = 'OBJECT' THEN D.is_ms_shipped ELSE E.is_ms_shipped END) = 0
ORDER BY
    A.request_session_id,
    A.resource_associated_entity_id
    
    
    
    
-- Identifica blocks ativos
SELECT
    A.session_id AS session_id,
    '(' + CAST(COALESCE(E.wait_duration_ms, B.wait_time) AS VARCHAR(20)) + 'ms)' + COALESCE(E.wait_type, B.wait_type) + COALESCE((CASE 
        WHEN COALESCE(E.wait_type, B.wait_type) LIKE 'PAGE%LATCH%' THEN ':' + DB_NAME(LEFT(E.resource_description, CHARINDEX(':', E.resource_description) - 1)) + ':' + SUBSTRING(E.resource_description, CHARINDEX(':', E.resource_description) + 1, 999)
        WHEN COALESCE(E.wait_type, B.wait_type) = 'OLEDB' THEN '[' + REPLACE(REPLACE(E.resource_description, ' (SPID=', ':'), ')', '') + ']'
        ELSE ''
    END), '') AS wait_info,
    COALESCE(E.wait_duration_ms, B.wait_time) AS wait_time_ms,
    NULLIF(B.blocking_session_id, 0) AS blocking_session_id,
    COALESCE(F.blocked_session_count, 0) AS blocked_session_count,
    A.open_transaction_count,
    CAST('<?query --' + CHAR(10) + (
    SELECT TOP 1 SUBSTRING(X.[text], B.statement_start_offset / 2 + 1, ((CASE
                                                                        WHEN B.statement_end_offset = -1 THEN (LEN(CONVERT(NVARCHAR(MAX), X.[text])) * 2)
                                                                        ELSE B.statement_end_offset
                                                                    END
                                                                    ) - B.statement_start_offset
                                                                ) / 2 + 1
                    )
    ) + CHAR(10) + '--?>' AS XML) AS sql_text,
    CAST('<?query --' + CHAR(10) + X.[text] + CHAR(10) + '--?>' AS XML) AS sql_command,
    A.total_elapsed_time,
    A.[deadlock_priority],
    (CASE B.transaction_isolation_level
        WHEN 0 THEN 'Unspecified' 
        WHEN 1 THEN 'ReadUncommitted' 
        WHEN 2 THEN 'ReadCommitted' 
        WHEN 3 THEN 'Repeatable' 
        WHEN 4 THEN 'Serializable' 
        WHEN 5 THEN 'Snapshot'
    END) AS transaction_isolation_level,
    A.last_request_start_time,
    A.login_name,
    A.nt_user_name,
    A.original_login_name,
    A.[host_name],
    (CASE WHEN D.name IS NOT NULL THEN 'SQLAgent - TSQL Job (' + D.[name] + ' - ' + SUBSTRING(A.[program_name], 67, LEN(A.[program_name]) - 67) +  ')' ELSE A.[program_name] END) AS [program_name]
FROM
    sys.dm_exec_sessions AS A WITH (NOLOCK)
    LEFT JOIN sys.dm_exec_requests AS B WITH (NOLOCK) ON A.session_id = B.session_id
    LEFT JOIN msdb.dbo.sysjobs AS D ON RIGHT(D.job_id, 10) = RIGHT(SUBSTRING(A.[program_name], 30, 34), 10)
    LEFT JOIN (
        SELECT
            session_id, 
            wait_type,
            wait_duration_ms,
            resource_description,
            ROW_NUMBER() OVER(PARTITION BY session_id ORDER BY (CASE WHEN wait_type LIKE 'PAGE%LATCH%' THEN 0 ELSE 1 END), wait_duration_ms) AS Ranking
        FROM 
            sys.dm_os_waiting_tasks
    ) E ON A.session_id = E.session_id AND E.Ranking = 1
    LEFT JOIN (
        SELECT
            blocking_session_id,
            COUNT(*) AS blocked_session_count
        FROM
            sys.dm_exec_requests
        WHERE
            blocking_session_id <> 0
        GROUP BY
            blocking_session_id
    ) F ON A.session_id = F.blocking_session_id
    LEFT JOIN sys.sysprocesses AS G WITH(NOLOCK) ON A.session_id = G.spid
    OUTER APPLY sys.dm_exec_sql_text(COALESCE(B.[sql_handle], G.[sql_handle])) AS X
WHERE
    A.session_id > 50
    AND A.session_id <> @@SPID
    AND (
        (NULLIF(B.blocking_session_id, 0) IS NOT NULL OR COALESCE(F.blocked_session_count, 0) > 0)
        OR (A.session_id IN (SELECT NULLIF(blocking_session_id, 0) FROM sys.dm_exec_requests))
    )




-- Identifica histórico de deadlocks
DECLARE @TimeZone INT = DATEDIFF(HOUR, GETUTCDATE(), GETDATE())

SELECT
    DATEADD(HOUR, @TimeZone, xed.value('@timestamp', 'datetime2(3)')) AS CreationDate,
    xed.query('.') AS XEvent
FROM
(
    SELECT 
        CAST(st.[target_data] AS XML) AS TargetData
    FROM 
        sys.dm_xe_session_targets AS st
        INNER JOIN sys.dm_xe_sessions AS s ON s.[address] = st.event_session_address
    WHERE 
        s.[name] = N'system_health'
        AND st.target_name = N'ring_buffer'
) AS [Data]
CROSS APPLY TargetData.nodes('RingBufferTarget/event[@name="xml_deadlock_report"]') AS XEventData (xed)
ORDER BY 
    CreationDate DESC
    
    

