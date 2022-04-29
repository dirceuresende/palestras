-- O que está em execução agora ?
SELECT
    RIGHT('00' + CAST(DATEDIFF(SECOND, COALESCE(B.start_time, A.login_time), GETDATE()) / 86400 AS VARCHAR), 2) + ' ' + 
    RIGHT('00' + CAST((DATEDIFF(SECOND, COALESCE(B.start_time, A.login_time), GETDATE()) / 3600) % 24 AS VARCHAR), 2) + ':' + 
    RIGHT('00' + CAST((DATEDIFF(SECOND, COALESCE(B.start_time, A.login_time), GETDATE()) / 60) % 60 AS VARCHAR), 2) + ':' + 
    RIGHT('00' + CAST(DATEDIFF(SECOND, COALESCE(B.start_time, A.login_time), GETDATE()) % 60 AS VARCHAR), 2) + '.' + 
    RIGHT('000' + CAST(DATEDIFF(SECOND, COALESCE(B.start_time, A.login_time), GETDATE()) AS VARCHAR), 3) 
    AS Duration,
    A.session_id AS session_id,
    B.command,
    TRY_CAST('<?query --' + CHAR(10) + (
        SELECT TOP 1 SUBSTRING(X.[text], B.statement_start_offset / 2 + 1, ((CASE
                                                                          WHEN B.statement_end_offset = -1 THEN (LEN(CONVERT(NVARCHAR(MAX), X.[text])) * 2)
                                                                          ELSE B.statement_end_offset
                                                                      END
                                                                     ) - B.statement_start_offset
                                                                    ) / 2 + 1
                     )
    ) + CHAR(10) + '--?>' AS XML) AS sql_text,
    TRY_CAST('<?query --' + CHAR(10) + X.[text] + CHAR(10) + '--?>' AS XML) AS sql_command,
    A.login_name,
    '(' + CAST(COALESCE(E.wait_duration_ms, B.wait_time) AS VARCHAR(20)) + 'ms)' + COALESCE(E.wait_type, B.wait_type) + COALESCE((CASE 
        WHEN COALESCE(E.wait_type, B.wait_type) LIKE 'PAGE%LATCH%' THEN ':' + DB_NAME(LEFT(E.resource_description, CHARINDEX(':', E.resource_description) - 1)) + ':' + SUBSTRING(E.resource_description, CHARINDEX(':', E.resource_description) + 1, 999)
        WHEN COALESCE(E.wait_type, B.wait_type) = 'OLEDB' THEN '[' + REPLACE(REPLACE(E.resource_description, ' (SPID=', ':'), ')', '') + ']'
        ELSE ''
    END), '') AS wait_info,
    FORMAT(COALESCE(B.cpu_time, 0), '###,###,###,###,###,###,###,##0') AS CPU,
    FORMAT(COALESCE(F.tempdb_allocations, 0), '###,###,###,###,###,###,###,##0') AS tempdb_allocations,
    FORMAT(COALESCE((CASE WHEN F.tempdb_allocations > F.tempdb_current THEN F.tempdb_allocations - F.tempdb_current ELSE 0 END), 0), '###,###,###,###,###,###,###,##0') AS tempdb_current,
    FORMAT(COALESCE(B.logical_reads, 0), '###,###,###,###,###,###,###,##0') AS reads,
    FORMAT(COALESCE(B.writes, 0), '###,###,###,###,###,###,###,##0') AS writes,
    FORMAT(COALESCE(B.reads, 0), '###,###,###,###,###,###,###,##0') AS physical_reads,
    FORMAT(COALESCE(B.granted_query_memory, 0), '###,###,###,###,###,###,###,##0') AS used_memory,
    NULLIF(B.blocking_session_id, 0) AS blocking_session_id,
    COALESCE(G.blocked_session_count, 0) AS blocked_session_count,
    'KILL ' + CAST(A.session_id AS VARCHAR(10)) AS kill_command,
    (CASE 
        WHEN B.[deadlock_priority] <= -5 THEN 'Low'
        WHEN B.[deadlock_priority] > -5 AND B.[deadlock_priority] < 5 AND B.[deadlock_priority] < 5 THEN 'Normal'
        WHEN B.[deadlock_priority] >= 5 THEN 'High'
    END) + ' (' + CAST(B.[deadlock_priority] AS VARCHAR(3)) + ')' AS [deadlock_priority],
    B.row_count,
    COALESCE(A.open_transaction_count, 0) AS open_tran_count,
    (CASE B.transaction_isolation_level
        WHEN 0 THEN 'Unspecified' 
        WHEN 1 THEN 'ReadUncommitted' 
        WHEN 2 THEN 'ReadCommitted' 
        WHEN 3 THEN 'Repeatable' 
        WHEN 4 THEN 'Serializable' 
        WHEN 5 THEN 'Snapshot'
    END) AS transaction_isolation_level,
    A.[status],
    NULLIF(B.percent_complete, 0) AS percent_complete,
    A.[host_name],
    COALESCE(DB_NAME(CAST(B.database_id AS VARCHAR)), 'master') AS [database_name],
    (CASE WHEN D.name IS NOT NULL THEN 'SQLAgent - TSQL Job (' + D.[name] + ' - ' + SUBSTRING(A.[program_name], 67, LEN(A.[program_name]) - 67) +  ')' ELSE A.[program_name] END) AS [program_name],
    H.[name] AS resource_governor_group,
    COALESCE(B.start_time, A.last_request_end_time) AS start_time,
    A.login_time,
    COALESCE(B.request_id, 0) AS request_id,
    W.query_plan
FROM
    sys.dm_exec_sessions AS A WITH (NOLOCK)
    LEFT JOIN sys.dm_exec_requests AS B WITH (NOLOCK) ON A.session_id = B.session_id
    JOIN sys.dm_exec_connections AS C WITH (NOLOCK) ON A.session_id = C.session_id AND A.endpoint_id = C.endpoint_id
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
            session_id,
            request_id,
            SUM(internal_objects_alloc_page_count + user_objects_alloc_page_count) AS tempdb_allocations,
            SUM(internal_objects_dealloc_page_count + user_objects_dealloc_page_count) AS tempdb_current
        FROM
            sys.dm_db_task_space_usage
        GROUP BY
            session_id,
            request_id
    ) F ON B.session_id = F.session_id AND B.request_id = F.request_id
    LEFT JOIN (
        SELECT 
            blocking_session_id,
            COUNT(*) AS blocked_session_count
        FROM 
            sys.dm_exec_requests
        WHERE 
            blocking_session_id != 0
        GROUP BY
            blocking_session_id
    ) G ON A.session_id = G.blocking_session_id
    OUTER APPLY sys.dm_exec_sql_text(COALESCE(B.[sql_handle], C.most_recent_sql_handle)) AS X
    OUTER APPLY sys.dm_exec_query_plan(B.plan_handle) AS W
    LEFT JOIN sys.dm_resource_governor_workload_groups H ON A.group_id = H.group_id
WHERE
    A.session_id > 50
    AND A.session_id <> @@SPID
    AND (A.[status] != 'sleeping' OR (A.[status] = 'sleeping' AND A.open_transaction_count > 0))
    
    
    
    

-- Eventos de Wait da instância
SELECT * FROM sys.dm_os_wait_stats



-- Eventos de Wait da instância (versão do Paul Randal)
;WITH [Waits]
AS ( SELECT
         [wait_type],
         [wait_time_ms] / 1000.0 AS [WaitS],
         ( [wait_time_ms] - [signal_wait_time_ms] ) / 1000.0 AS [ResourceS],
         [signal_wait_time_ms] / 1000.0 AS [SignalS],
         [waiting_tasks_count] AS [WaitCount],
         100.0 * [wait_time_ms] / SUM([wait_time_ms]) OVER () AS [Percentage],
         ROW_NUMBER() OVER ( ORDER BY
                                 [wait_time_ms] DESC
                           ) AS [RowNum]
     FROM
         sys.dm_os_wait_stats
     WHERE
         [wait_type] NOT IN (
                                -- These wait types are almost 100% never a problem and so they are
                                -- filtered out to avoid them skewing the results. Click on the URL
                                -- for more information.
                                N'BROKER_EVENTHANDLER', -- https://www.sqlskills.com/help/waits/BROKER_EVENTHANDLER
                                N'BROKER_RECEIVE_WAITFOR', -- https://www.sqlskills.com/help/waits/BROKER_RECEIVE_WAITFOR
                                N'BROKER_TASK_STOP', -- https://www.sqlskills.com/help/waits/BROKER_TASK_STOP
                                N'BROKER_TO_FLUSH', -- https://www.sqlskills.com/help/waits/BROKER_TO_FLUSH
                                N'BROKER_TRANSMITTER', -- https://www.sqlskills.com/help/waits/BROKER_TRANSMITTER
                                N'CHECKPOINT_QUEUE', -- https://www.sqlskills.com/help/waits/CHECKPOINT_QUEUE
                                N'CHKPT', -- https://www.sqlskills.com/help/waits/CHKPT
                                N'CLR_AUTO_EVENT', -- https://www.sqlskills.com/help/waits/CLR_AUTO_EVENT
                                N'CLR_MANUAL_EVENT', -- https://www.sqlskills.com/help/waits/CLR_MANUAL_EVENT
                                N'CLR_SEMAPHORE', -- https://www.sqlskills.com/help/waits/CLR_SEMAPHORE
                                N'CXCONSUMER', -- https://www.sqlskills.com/help/waits/CXCONSUMER

                                -- Maybe comment these four out if you have mirroring issues
                                N'DBMIRROR_DBM_EVENT', -- https://www.sqlskills.com/help/waits/DBMIRROR_DBM_EVENT
                                N'DBMIRROR_EVENTS_QUEUE', -- https://www.sqlskills.com/help/waits/DBMIRROR_EVENTS_QUEUE
                                N'DBMIRROR_WORKER_QUEUE', -- https://www.sqlskills.com/help/waits/DBMIRROR_WORKER_QUEUE
                                N'DBMIRRORING_CMD', -- https://www.sqlskills.com/help/waits/DBMIRRORING_CMD

                                N'DIRTY_PAGE_POLL', -- https://www.sqlskills.com/help/waits/DIRTY_PAGE_POLL
                                N'DISPATCHER_QUEUE_SEMAPHORE', -- https://www.sqlskills.com/help/waits/DISPATCHER_QUEUE_SEMAPHORE
                                N'EXECSYNC', -- https://www.sqlskills.com/help/waits/EXECSYNC
                                N'FSAGENT', -- https://www.sqlskills.com/help/waits/FSAGENT
                                N'FT_IFTS_SCHEDULER_IDLE_WAIT', -- https://www.sqlskills.com/help/waits/FT_IFTS_SCHEDULER_IDLE_WAIT
                                N'FT_IFTSHC_MUTEX', -- https://www.sqlskills.com/help/waits/FT_IFTSHC_MUTEX

                                -- Maybe comment these six out if you have AG issues
                                N'HADR_CLUSAPI_CALL', -- https://www.sqlskills.com/help/waits/HADR_CLUSAPI_CALL
                                N'HADR_FILESTREAM_IOMGR_IOCOMPLETION', -- https://www.sqlskills.com/help/waits/HADR_FILESTREAM_IOMGR_IOCOMPLETION
                                N'HADR_LOGCAPTURE_WAIT', -- https://www.sqlskills.com/help/waits/HADR_LOGCAPTURE_WAIT
                                N'HADR_NOTIFICATION_DEQUEUE', -- https://www.sqlskills.com/help/waits/HADR_NOTIFICATION_DEQUEUE
                                N'HADR_TIMER_TASK', -- https://www.sqlskills.com/help/waits/HADR_TIMER_TASK
                                N'HADR_WORK_QUEUE', -- https://www.sqlskills.com/help/waits/HADR_WORK_QUEUE

                                N'KSOURCE_WAKEUP', -- https://www.sqlskills.com/help/waits/KSOURCE_WAKEUP
                                N'LAZYWRITER_SLEEP', -- https://www.sqlskills.com/help/waits/LAZYWRITER_SLEEP
                                N'LOGMGR_QUEUE', -- https://www.sqlskills.com/help/waits/LOGMGR_QUEUE
                                N'MEMORY_ALLOCATION_EXT', -- https://www.sqlskills.com/help/waits/MEMORY_ALLOCATION_EXT
                                N'ONDEMAND_TASK_QUEUE', -- https://www.sqlskills.com/help/waits/ONDEMAND_TASK_QUEUE
                                N'PARALLEL_REDO_DRAIN_WORKER', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_DRAIN_WORKER
                                N'PARALLEL_REDO_LOG_CACHE', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_LOG_CACHE
                                N'PARALLEL_REDO_TRAN_LIST', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_TRAN_LIST
                                N'PARALLEL_REDO_WORKER_SYNC', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_WORKER_SYNC
                                N'PARALLEL_REDO_WORKER_WAIT_WORK', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_WORKER_WAIT_WORK
                                N'PREEMPTIVE_XE_GETTARGETSTATE', -- https://www.sqlskills.com/help/waits/PREEMPTIVE_XE_GETTARGETSTATE
                                N'PWAIT_ALL_COMPONENTS_INITIALIZED', -- https://www.sqlskills.com/help/waits/PWAIT_ALL_COMPONENTS_INITIALIZED
                                N'PWAIT_DIRECTLOGCONSUMER_GETNEXT', -- https://www.sqlskills.com/help/waits/PWAIT_DIRECTLOGCONSUMER_GETNEXT
                                N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP', -- https://www.sqlskills.com/help/waits/QDS_PERSIST_TASK_MAIN_LOOP_SLEEP
                                N'QDS_ASYNC_QUEUE', -- https://www.sqlskills.com/help/waits/QDS_ASYNC_QUEUE
                                N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP', -- https://www.sqlskills.com/help/waits/QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP
                                N'QDS_SHUTDOWN_QUEUE', -- https://www.sqlskills.com/help/waits/QDS_SHUTDOWN_QUEUE
                                N'REDO_THREAD_PENDING_WORK', -- https://www.sqlskills.com/help/waits/REDO_THREAD_PENDING_WORK
                                N'REQUEST_FOR_DEADLOCK_SEARCH', -- https://www.sqlskills.com/help/waits/REQUEST_FOR_DEADLOCK_SEARCH
                                N'RESOURCE_QUEUE', -- https://www.sqlskills.com/help/waits/RESOURCE_QUEUE
                                N'SERVER_IDLE_CHECK', -- https://www.sqlskills.com/help/waits/SERVER_IDLE_CHECK
                                N'SLEEP_BPOOL_FLUSH', -- https://www.sqlskills.com/help/waits/SLEEP_BPOOL_FLUSH
                                N'SLEEP_DBSTARTUP', -- https://www.sqlskills.com/help/waits/SLEEP_DBSTARTUP
                                N'SLEEP_DCOMSTARTUP', -- https://www.sqlskills.com/help/waits/SLEEP_DCOMSTARTUP
                                N'SLEEP_MASTERDBREADY', -- https://www.sqlskills.com/help/waits/SLEEP_MASTERDBREADY
                                N'SLEEP_MASTERMDREADY', -- https://www.sqlskills.com/help/waits/SLEEP_MASTERMDREADY
                                N'SLEEP_MASTERUPGRADED', -- https://www.sqlskills.com/help/waits/SLEEP_MASTERUPGRADED
                                N'SLEEP_MSDBSTARTUP', -- https://www.sqlskills.com/help/waits/SLEEP_MSDBSTARTUP
                                N'SLEEP_SYSTEMTASK', -- https://www.sqlskills.com/help/waits/SLEEP_SYSTEMTASK
                                N'SLEEP_TASK', -- https://www.sqlskills.com/help/waits/SLEEP_TASK
                                N'SLEEP_TEMPDBSTARTUP', -- https://www.sqlskills.com/help/waits/SLEEP_TEMPDBSTARTUP
                                N'SNI_HTTP_ACCEPT', -- https://www.sqlskills.com/help/waits/SNI_HTTP_ACCEPT
                                N'SP_SERVER_DIAGNOSTICS_SLEEP', -- https://www.sqlskills.com/help/waits/SP_SERVER_DIAGNOSTICS_SLEEP
                                N'SQLTRACE_BUFFER_FLUSH', -- https://www.sqlskills.com/help/waits/SQLTRACE_BUFFER_FLUSH
                                N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', -- https://www.sqlskills.com/help/waits/SQLTRACE_INCREMENTAL_FLUSH_SLEEP
                                N'SQLTRACE_WAIT_ENTRIES', -- https://www.sqlskills.com/help/waits/SQLTRACE_WAIT_ENTRIES
                                N'WAIT_FOR_RESULTS', -- https://www.sqlskills.com/help/waits/WAIT_FOR_RESULTS
                                N'WAITFOR', -- https://www.sqlskills.com/help/waits/WAITFOR
                                N'WAITFOR_TASKSHUTDOWN', -- https://www.sqlskills.com/help/waits/WAITFOR_TASKSHUTDOWN
                                N'WAIT_XTP_RECOVERY', -- https://www.sqlskills.com/help/waits/WAIT_XTP_RECOVERY
                                N'WAIT_XTP_HOST_WAIT', -- https://www.sqlskills.com/help/waits/WAIT_XTP_HOST_WAIT
                                N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG', -- https://www.sqlskills.com/help/waits/WAIT_XTP_OFFLINE_CKPT_NEW_LOG
                                N'WAIT_XTP_CKPT_CLOSE', -- https://www.sqlskills.com/help/waits/WAIT_XTP_CKPT_CLOSE
                                N'XE_DISPATCHER_JOIN', -- https://www.sqlskills.com/help/waits/XE_DISPATCHER_JOIN
                                N'XE_DISPATCHER_WAIT', -- https://www.sqlskills.com/help/waits/XE_DISPATCHER_WAIT
                                N'XE_TIMER_EVENT' -- https://www.sqlskills.com/help/waits/XE_TIMER_EVENT
                            )
         AND [waiting_tasks_count] > 0 )
SELECT
    MAX([W1].[wait_type]) AS [WaitType],
    CAST(MAX([W1].[WaitS]) AS DECIMAL(16, 2)) AS [Wait_S],
    CAST(MAX([W1].[ResourceS]) AS DECIMAL(16, 2)) AS [Resource_S],
    CAST(MAX([W1].[SignalS]) AS DECIMAL(16, 2)) AS [Signal_S],
    MAX([W1].[WaitCount]) AS [WaitCount],
    CAST(MAX([W1].[Percentage]) AS DECIMAL(5, 2)) AS [Percentage],
    CAST(( MAX([W1].[WaitS]) / MAX([W1].[WaitCount])) AS DECIMAL(16, 4)) AS [AvgWait_S],
    CAST(( MAX([W1].[ResourceS]) / MAX([W1].[WaitCount])) AS DECIMAL(16, 4)) AS [AvgRes_S],
    CAST(( MAX([W1].[SignalS]) / MAX([W1].[WaitCount])) AS DECIMAL(16, 4)) AS [AvgSig_S],
    CAST('https://www.sqlskills.com/help/waits/' + MAX([W1].[wait_type]) AS XML) AS [Help/Info URL]
FROM
    [Waits] AS [W1]
    INNER JOIN [Waits] AS [W2] ON [W2].[RowNum] <= [W1].[RowNum]
GROUP BY
    [W1].[RowNum]
HAVING
    SUM([W2].[Percentage]) - MAX([W1].[Percentage]) < 95; -- percentage threshold
GO






-- Histórico de uso de CPU (últimos 256 minutos)
DECLARE @ts_now BIGINT =
        (
            SELECT
                cpu_ticks / ( cpu_ticks / ms_ticks )
            FROM
                sys.dm_os_sys_info WITH ( NOLOCK )
        );

SELECT TOP ( 256 )
    SQLProcessUtilization AS [SQL Server Process CPU Utilization],
    SystemIdle AS [System Idle Process],
    100 - SystemIdle - SQLProcessUtilization AS [Other Process CPU Utilization],
    DATEADD(ms, -1 * ( @ts_now - [timestamp] ), GETDATE()) AS [Event Time]
FROM
(
    SELECT
        record.value('(./Record/@id)[1]', 'int') AS record_id,
        record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS [SystemIdle],
        record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS [SQLProcessUtilization],
        [timestamp]
    FROM
    (
        SELECT
            [timestamp],
            CONVERT(XML, record) AS [record]
        FROM
            sys.dm_os_ring_buffers WITH ( NOLOCK )
        WHERE
            ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
            AND record LIKE N'%<SystemHealth>%'
    ) AS x
) AS y
ORDER BY
    record_id DESC
OPTION ( RECOMPILE );




-- Uso de memória
-- https://blogs.msdn.microsoft.com/mvpawardprogram/2012/06/04/using-sys-dm_os_ring_buffers-to-diagnose-memory-issues-in-sql-server/
WITH RingBuffer
AS ( SELECT
         CAST(dorb.record AS XML) AS xRecord,
         dorb.timestamp
     FROM
         sys.dm_os_ring_buffers AS dorb
     WHERE
         dorb.ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR' )
SELECT
    xr.value('(ResourceMonitor/Notification)[1]', 'varchar(75)') AS RmNotification,
    xr.value('(ResourceMonitor/IndicatorsProcess)[1]', 'tinyint') AS IndicatorsProcess,
    xr.value('(ResourceMonitor/IndicatorsSystem)[1]', 'tinyint') AS IndicatorsSystem,
    DATEADD(ms, -1 * dosi.ms_ticks - rb.timestamp, GETDATE()) AS RmDateTime,
    xr.value('(MemoryNode/TargetMemory)[1]', 'bigint') AS TargetMemory,
    xr.value('(MemoryNode/ReserveMemory)[1]', 'bigint') AS ReserveMemory,
    xr.value('(MemoryNode/CommittedMemory)[1]', 'bigint') AS CommitedMemory,
    xr.value('(MemoryNode/SharedMemory)[1]', 'bigint') AS SharedMemory,
    xr.value('(MemoryNode/PagesMemory)[1]', 'bigint') AS PagesMemory,
    xr.value('(MemoryRecord/MemoryUtilization)[1]', 'bigint') AS MemoryUtilization,
    xr.value('(MemoryRecord/TotalPhysicalMemory)[1]', 'bigint') AS TotalPhysicalMemory,
    xr.value('(MemoryRecord/AvailablePhysicalMemory)[1]', 'bigint') AS AvailablePhysicalMemory,
    xr.value('(MemoryRecord/TotalPageFile)[1]', 'bigint') AS TotalPageFile,
    xr.value('(MemoryRecord/AvailablePageFile)[1]', 'bigint') AS AvailablePageFile,
    xr.value('(MemoryRecord/TotalVirtualAddressSpace)[1]', 'bigint') AS TotalVirtualAddressSpace,
    xr.value('(MemoryRecord/AvailableVirtualAddressSpace)[1]', 'bigint') AS AvailableVirtualAddressSpace,
    xr.value('(MemoryRecord/AvailableExtendedVirtualAddressSpace)[1]', 'bigint') AS AvailableExtendedVirtualAddressSpace
FROM
    RingBuffer AS rb
    CROSS APPLY rb.xRecord.nodes('Record') record(xr)
    CROSS JOIN sys.dm_os_sys_info AS dosi
ORDER BY
    RmDateTime DESC;
    
    
    
    
-- Desempenho de I/O dos discos
SELECT
    DB_NAME(fs.database_id) AS [Database Name],
    mf.physical_name,
    io_stall_read_ms,
    num_of_reads,
    CAST(io_stall_read_ms / ( 1.0 + num_of_reads ) AS NUMERIC(10, 1)) AS [avg_read_stall_ms],
    io_stall_write_ms,
    num_of_writes,
    CAST(io_stall_write_ms / ( 1.0 + num_of_writes ) AS NUMERIC(10, 1)) AS [avg_write_stall_ms],
    io_stall_read_ms + io_stall_write_ms AS [io_stalls],
    num_of_reads + num_of_writes AS [total_io],
    CAST(( io_stall_read_ms + io_stall_write_ms ) / ( 1.0 + num_of_reads + num_of_writes ) AS NUMERIC(10, 1)) AS [avg_io_stall_ms]
FROM
    sys.dm_io_virtual_file_stats(NULL, NULL) AS fs
    INNER JOIN sys.master_files AS mf WITH ( NOLOCK ) ON fs.database_id = mf.database_id AND fs.[file_id] = mf.[file_id]
ORDER BY
    avg_io_stall_ms DESC;
    
    
    
    
-- Quantidade de páginas alocadas em memória por Database
SELECT
    CASE database_id WHEN 32767 THEN 'ResourceDb' ELSE DB_NAME(database_id)END AS database_name,
    COUNT(*) AS cached_pages_count,
    COUNT(*) * .0078125 AS cached_megabytes /* Each page is 8kb, which is .0078125 of an MB */
FROM
    sys.dm_os_buffer_descriptors
GROUP BY
    DB_NAME(database_id),
    database_id
ORDER BY
    cached_pages_count DESC;
    
    
    
    