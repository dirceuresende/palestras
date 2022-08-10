
---------------------------------------------------------
-- Rotina de Rebuild
-- https://ola.hallengren.com/
---------------------------------------------------------

EXECUTE [master].[dbo].[IndexOptimize]
	@Databases = 'USER_DATABASES',
	@Indexes = 'ALL_INDEXES, -AdventureWorks.Production.Product',
	@FragmentationLow = NULL,
	@FragmentationMedium = 'INDEX_REORGANIZE, INDEX_REBUILD_ONLINE, INDEX_REBUILD_OFFLINE',
	@FragmentationHigh = 'INDEX_REBUILD_ONLINE, INDEX_REBUILD_OFFLINE',
	@FragmentationLevel1 = 5, -- % de fragmentação
	@FragmentationLevel2 = 30, -- % de fragmentação
	@UpdateStatistics = 'ALL',
	@SortInTempdb = 'Y',
	@MaxDOP = 8,
	@TimeLimit = 3600 -- segundos
	

EXECUTE [master].[dbo].[IndexOptimize]
	@Databases = 'AdventureWorks2019, AdventureWorksDW2019, dirceuresende',
	@FragmentationLow = NULL,
	@FragmentationMedium = 'INDEX_REORGANIZE, INDEX_REBUILD_ONLINE, INDEX_REBUILD_OFFLINE',
	@FragmentationHigh = 'INDEX_REBUILD_ONLINE, INDEX_REBUILD_OFFLINE',
	@FragmentationLevel1 = 5, -- % de fragmentação
	@FragmentationLevel2 = 30, -- % de fragmentação
	@UpdateStatistics = 'ALL',
	@SortInTempdb = 'Y',
	@MaxDOP = 8,
	@TimeLimit = 3600 -- segundos


---------------------------------------------------------
-- AUTO_UPDATE_STATISTICS_ASYNC
-- https://techcommunity.microsoft.com/t5/azure-database-support-blog/improving-performance-with-auto-update-statistics-async/ba-p/3579907 
---------------------------------------------------------

/*

With synchronous statistics updates, queries always compile and execute with up-to-date statistics. When statistics are out-of-date, the Query Optimizer 
waits for updated statistics before compiling and executing the query.

Contrarily, with asynchronous statistics updates, queries compile with existing statistics even if the existing statistics are out-of-date. The Query Optimizer 
could choose a suboptimal query plan if statistics are out-of-date when the query is compiled. Statistics are typically updated soon thereafter.

*/


-- WAIT_ON_SYNC_STATISTICS_REFRESH
ALTER DATABASE [dirceuresende] SET AUTO_UPDATE_STATISTICS_ASYNC ON


-- https://www.sqlskills.com/blogs/paul/wait-statistics-or-please-tell-me-where-it-hurts/
-- Last updated October 1, 2021
WITH [Waits] 
AS
    (SELECT
        [wait_type],
        [wait_time_ms] / 1000.0 AS [WaitS],
        ([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],
        [signal_wait_time_ms] / 1000.0 AS [SignalS],
        [waiting_tasks_count] AS [WaitCount],
        100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
        ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]
    FROM sys.dm_os_wait_stats
    WHERE [wait_type] NOT IN (
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
 
        -- Maybe comment this out if you have parallelism issues
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
        N'PREEMPTIVE_OS_FLUSHFILEBUFFERS', -- https://www.sqlskills.com/help/waits/PREEMPTIVE_OS_FLUSHFILEBUFFERS
        N'PREEMPTIVE_XE_GETTARGETSTATE', -- https://www.sqlskills.com/help/waits/PREEMPTIVE_XE_GETTARGETSTATE
        N'PVS_PREALLOCATE', -- https://www.sqlskills.com/help/waits/PVS_PREALLOCATE
        N'PWAIT_ALL_COMPONENTS_INITIALIZED', -- https://www.sqlskills.com/help/waits/PWAIT_ALL_COMPONENTS_INITIALIZED
        N'PWAIT_DIRECTLOGCONSUMER_GETNEXT', -- https://www.sqlskills.com/help/waits/PWAIT_DIRECTLOGCONSUMER_GETNEXT
        N'PWAIT_EXTENSIBILITY_CLEANUP_TASK', -- https://www.sqlskills.com/help/waits/PWAIT_EXTENSIBILITY_CLEANUP_TASK
        N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP', -- https://www.sqlskills.com/help/waits/QDS_PERSIST_TASK_MAIN_LOOP_SLEEP
        N'QDS_ASYNC_QUEUE', -- https://www.sqlskills.com/help/waits/QDS_ASYNC_QUEUE
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
            -- https://www.sqlskills.com/help/waits/QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP
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
        N'SOS_WORK_DISPATCHER', -- https://www.sqlskills.com/help/waits/SOS_WORK_DISPATCHER
        N'SP_SERVER_DIAGNOSTICS_SLEEP', -- https://www.sqlskills.com/help/waits/SP_SERVER_DIAGNOSTICS_SLEEP
        N'SQLTRACE_BUFFER_FLUSH', -- https://www.sqlskills.com/help/waits/SQLTRACE_BUFFER_FLUSH
        N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', -- https://www.sqlskills.com/help/waits/SQLTRACE_INCREMENTAL_FLUSH_SLEEP
        N'SQLTRACE_WAIT_ENTRIES', -- https://www.sqlskills.com/help/waits/SQLTRACE_WAIT_ENTRIES
        N'VDI_CLIENT_OTHER', -- https://www.sqlskills.com/help/waits/VDI_CLIENT_OTHER
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
    AND [waiting_tasks_count] > 0
    )
SELECT
    MAX ([W1].[wait_type]) AS [WaitType],
    CAST (MAX ([W1].[WaitS]) AS DECIMAL (16,2)) AS [Wait_S],
    CAST (MAX ([W1].[ResourceS]) AS DECIMAL (16,2)) AS [Resource_S],
    CAST (MAX ([W1].[SignalS]) AS DECIMAL (16,2)) AS [Signal_S],
    MAX ([W1].[WaitCount]) AS [WaitCount],
    CAST (MAX ([W1].[Percentage]) AS DECIMAL (5,2)) AS [Percentage],
    CAST ((MAX ([W1].[WaitS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgWait_S],
    CAST ((MAX ([W1].[ResourceS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgRes_S],
    CAST ((MAX ([W1].[SignalS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgSig_S],
    CAST ('https://www.sqlskills.com/help/waits/' + MAX ([W1].[wait_type]) as XML) AS [Help/Info URL]
FROM [Waits] AS [W1]
INNER JOIN [Waits] AS [W2] ON [W2].[RowNum] <= [W1].[RowNum]
GROUP BY [W1].[RowNum]
HAVING SUM ([W2].[Percentage]) - MAX( [W1].[Percentage] ) < 95; -- percentage threshold
GO


---------------------------------------------------------
-- Columnstore + Linked Server
-- https://www.nikoport.com/2017/09/14/columnstore-indexes-part-112-linked-servers/
---------------------------------------------------------

USE [dirceuresende]
GO

DROP TABLE IF EXISTS dbo.T1;

CREATE TABLE dbo.T1 (
	C1 INT,
	INDEX CCI_T1 CLUSTERED COLUMNSTORE
);

INSERT INTO dbo.T1 (C1)
VALUES (1),(2),(3);

ALTER TABLE dbo.T1 REBUILD;


-- Leitura OK
SELECT SUM(C1) as Total
FROM [.\SQL2019].dirceuresende.dbo.T1
INNER JOIN sys.objects so ON T1.C1 < so.object_id;

-- Escrita...
INSERT INTO [.\SQL2019].dirceuresende.dbo.T1 (C1)
SELECT so.object_id
FROM sys.objects so;

-- Internamente, ele faz isso
DECLARE @cursor INT
EXEC sp_cursoropen @cursor OUTPUT, N'SELECT * FROM dbo.T1', 2, 8193
EXEC sp_cursorclose @cursor


-- Tentando com índice nonclustered
DROP TABLE IF EXISTS dbo.t2;

CREATE TABLE dbo.t2 (
	C1 INT,
	INDEX CI_t2 CLUSTERED (C1),
	INDEX NCI_t2 NONCLUSTERED COLUMNSTORE (C1)
);

INSERT INTO dbo.t2 (C1)
VALUES (1),(2),(3);

ALTER TABLE dbo.t2 REBUILD;

INSERT INTO [.\SQL2019].dirceuresende.dbo.t2 (C1)
SELECT so.object_id
FROM sys.objects so;


---------------------------------------------------------
-- Columnstore + Update
-- https://www.youtube.com/watch?v=mhJuxA9EPvc
---------------------------------------------------------

DROP TABLE IF EXISTS dbo.Vendas_Columnstore
GO

CREATE TABLE [dbo].[Vendas_Columnstore] (
	[Id_Pedido] [int] NOT NULL,
	[Dt_Pedido] [datetime] NULL,
	[Status] [int] NULL,
	[Quantidade] [int] NULL,
	[Valor] [numeric] (18, 2) NULL
)
GO

INSERT INTO dbo.Vendas_Columnstore
SELECT *
FROM dbo.Vendas


CREATE CLUSTERED COLUMNSTORE INDEX SK01_Vendas_Columnstore ON dbo.Vendas_Columnstore


SET STATISTICS TIME, IO ON

UPDATE dbo.Vendas_Columnstore
SET [Status] = 200
WHERE [Status] = 2

--SQL Server parse and compile time: 
--   CPU time = 122 ms, elapsed time = 122 ms.
--SQL Server parse and compile time: 
--   CPU time = 0 ms, elapsed time = 0 ms.
--Table 'Vendas_Columnstore'. Scan count 11, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 26424, lob physical reads 0, lob page server reads 0, lob read-ahead reads 12790, lob page server read-ahead reads 0.
--Table 'Vendas_Columnstore'. Segment reads 12, segment skipped 0.
--Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.


-- SQL Server Execution Times:
--   CPU time = 4687 ms,  elapsed time = 4908 ms.


DELETE FROM dbo.Vendas_Columnstore
WHERE [Status] = 200


INSERT INTO dbo.Vendas_Columnstore
(
	Id_Pedido,
    Dt_Pedido,
    [Status],
    Quantidade,
    Valor
)
SELECT 
	Id_Pedido,
    Dt_Pedido,
    [Status],
    Quantidade,
    Valor
FROM
	dbo.Vendas
WHERE
	[Status] = 2


---------------------------------------------------------
-- GUID x Fragmentação
-- https://www.mssqltips.com/sqlservertip/6595/sql-server-guid-column-and-index-fragmentation/
---------------------------------------------------------

DROP TABLE IF EXISTS dbo.Product_A
GO

CREATE TABLE dbo.Product_A
(
    ID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    productname VARCHAR(50)
);


DROP TABLE IF EXISTS dbo.Product_B
GO

CREATE TABLE dbo.Product_B
(
    ID UNIQUEIDENTIFIER PRIMARY KEY NONCLUSTERED DEFAULT NEWID(),
    productname VARCHAR(50),
);
GO

CREATE CLUSTERED INDEX CIX_Product_B_productname ON dbo.Product_B (productname);
GO


INSERT INTO [dbo].[Product_A]
VALUES (DEFAULT,'Test')
GO 100000


INSERT INTO [dbo].[Product_B]
VALUES (DEFAULT,'Test')
GO 100000


SELECT 
	OBJECT_NAME(ips.object_id),
    i.name,
    ips.index_id,
    index_type_desc,
    avg_fragmentation_in_percent,
    avg_page_space_used_in_percent,
    page_count
FROM
	sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'SAMPLED') ips
    INNER JOIN sys.indexes i ON (ips.object_id = i.object_id) AND (ips.index_id = i.index_id)
WHERE
	OBJECT_NAME(ips.object_id) LIKE 'Product_%'
ORDER BY
	avg_fragmentation_in_percent DESC;


DROP TABLE IF EXISTS dbo.Product_C
GO

CREATE TABLE dbo.Product_C
(
    ID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    productname VARCHAR(50)
);

INSERT INTO [dbo].[Product_C]
VALUES (default,'Test')
GO 100000



---------------------------------------------------------
-- GUID x INT: Performance
-- https://www.sql-server-performance.com/guid-performance/
---------------------------------------------------------

DROP TABLE IF EXISTS dbo.Product_A
GO

CREATE TABLE dbo.Product_A
(
    ID INT
);


DROP TABLE IF EXISTS dbo.Product_B
GO

CREATE TABLE dbo.Product_B
(
    ID UNIQUEIDENTIFIER
);
GO



-- CPU time = 5281 ms,  elapsed time = 5762 ms.
-- CPU time = 5344 ms,  elapsed time = 5792 ms. - Indice Clustered
-- CPU time = 11640 ms,  elapsed time = 12174 ms. - Indice NC
INSERT INTO [dbo].[Product_A] (ID)
SELECT Id_Pedido
FROM dbo.Vendas

-- CPU time = 6125 ms,  elapsed time = 6466 ms.
-- CPU time = 13028 ms,  elapsed time = 8097 ms. - Indice Clustered
-- CPU time = 17375 ms,  elapsed time = 18162 ms. - Indice NC
INSERT INTO [dbo].[Product_B] (ID)
SELECT NEWID()
FROM dbo.Vendas


-- CPU time = 516 ms,  elapsed time = 540 ms.
SELECT * 
FROM dbo.Product_A
WHERE ID = 123456

-- CPU time = 546 ms,  elapsed time = 548 ms.
SELECT * 
FROM dbo.Product_B
WHERE ID = 'E590C058-B308-4826-9FB6-79BF5986CFA3'


CREATE NONCLUSTERED INDEX SK01_Product_A ON dbo.Product_A(ID)
CREATE NONCLUSTERED INDEX SK01_Product_B ON dbo.Product_B(ID)


-- CPU time = 0 ms,  elapsed time = 0 ms.
SELECT * 
FROM dbo.Product_A
WHERE ID = 123456

-- CPU time = 0 ms,  elapsed time = 0 ms.
SELECT * 
FROM dbo.Product_B
WHERE ID = '18DD7368-4B98-4CD3-A5FF-B1007B72D915'


SELECT 
	OBJECT_NAME(ips.object_id),
    i.name,
    ips.index_id,
    index_type_desc,
    avg_fragmentation_in_percent,
    avg_page_space_used_in_percent,
    page_count
FROM
	sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'SAMPLED') ips
    INNER JOIN sys.indexes i ON (ips.object_id = i.object_id) AND (ips.index_id = i.index_id)
WHERE
	OBJECT_NAME(ips.object_id) LIKE 'Product_%'
ORDER BY
	avg_fragmentation_in_percent DESC;



---------------------------------------------------------
-- Merge x Delete/Insert x Update/Insert
-- https://www.sqlservercentral.com/articles/performance-of-the-sql-merge-vs-insertupdate
---------------------------------------------------------

DROP TABLE IF EXISTS #Target
GO

CREATE TABLE #Target
(
    ID BIGINT PRIMARY KEY,
    [Value] INT
);

DROP TABLE IF EXISTS #Source
GO

CREATE TABLE #Source
(
    ID BIGINT PRIMARY KEY,
    [Value] INT
);


TRUNCATE TABLE #Source;
TRUNCATE TABLE #Target;

WITH Tally (n)
AS (SELECT TOP 1000000
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_columns a
        CROSS JOIN sys.all_columns b)
INSERT INTO #Target
SELECT 2 * n,
       1 + ABS(CHECKSUM(NEWID())) % 1000
FROM Tally;
WITH Tally (n)
AS (SELECT TOP 1000000
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_columns a
        CROSS JOIN sys.all_columns b)
INSERT INTO #Source
SELECT CASE
           WHEN n <= 500000 THEN
               2 * n - 1
           ELSE
               2 * n
       END,
       1 + ABS(CHECKSUM(NEWID())) % 1000
FROM Tally;



-- MERGE 
-- CPU time = 2110 ms,  elapsed time = 2178 ms.
MERGE #Target t
USING #Source s ON s.ID = t.ID
	WHEN MATCHED THEN 
		UPDATE SET Value = s.Value
	WHEN NOT MATCHED THEN 
		INSERT ( ID, Value )
        VALUES ( s.ID, s.Value );



-- UPDATE/INSERT
-- CPU time = 358 ms, elapsed time = 358 ms.
UPDATE t
SET [Value] = s.[Value]
FROM #Target t
JOIN #Source s ON s.ID = t.ID;


-- CPU time = 407 ms,  elapsed time = 462 ms.
INSERT INTO #Target
SELECT
	s.ID,
    s.[Value]
FROM
	#Source s
    LEFT JOIN #Target t ON s.ID = t.ID
WHERE
	t.ID IS NULL;




-- MERGE NÃO É SÓ PERFORMANCE

DROP TABLE IF EXISTS #Target
GO

CREATE TABLE #Target
(
    ID BIGINT,
    [Value] INT
);

DROP TABLE IF EXISTS #Source
GO

CREATE TABLE #Source
(
    ID BIGINT,
    [Value] INT
);

INSERT INTO #Target
    VALUES  ( 1, 2342 ),
            ( 2, 345 )


INSERT INTO #Source
    VALUES  ( 1, 975 ),
            ( 3, 683 ),
			( 2, 500 ),
			( 2, 600 ),
			( 3, 700 )


MERGE #Target t
USING #Source s ON s.ID = t.ID
    WHEN MATCHED THEN 
		UPDATE
        SET Value = s.Value
    WHEN NOT MATCHED THEN
		INSERT ( ID, Value )
        VALUES ( s.ID, s.Value );


UPDATE t
SET t.[Value] = s.[Value]
FROM #Source s
JOIN #Target t ON t.ID = s.ID


SELECT *
FROM #Target;



---------------------------------------------------------
-- CDC para cargas de BI
-- https://www.dirceuresende.com/blog/sql-server-como-monitorar-e-auditar-alteracoes-de-dados-em-tabelas-utilizando-change-data-capture-cdc/
---------------------------------------------------------

SET STATISTICS TIME, IO OFF


DROP TABLE IF EXISTS dbo.Vendas_Sistema
GO

SELECT *
INTO 
	dbo.Vendas_Sistema
FROM
	dbo.Vendas


UPDATE dbo.Vendas_Sistema
SET Valor = 100
WHERE Id_Pedido = 1250

UPDATE dbo.Vendas_Sistema
SET Valor = 99.99
WHERE Id_Pedido = 1857


-- Vamos ativar o CDC no database
USE [dirceuresende] 
GO
 
EXEC sys.sp_cdc_enable_db 
GO

-- E agora ativar o CDC na tabela
USE [dirceuresende]
GO

EXEC sys.sp_cdc_enable_table 
	@source_schema = N'dbo', 
	@source_name   = N'Vendas_Sistema', 
	@role_name     = NULL 
GO

UPDATE dbo.Vendas_Sistema
SET Valor = 100
WHERE Id_Pedido = 1999

UPDATE dbo.Vendas_Sistema
SET Valor = 99.99
WHERE Id_Pedido = 2999

INSERT INTO dbo.Vendas_Sistema
(
    Dt_Pedido,
    Status,
    Quantidade,
    Valor
)
VALUES
(   GETDATE(), -- Dt_Pedido - datetime
    0, -- Status - int
    2, -- Quantidade - int
    123.45  -- Valor - numeric(18, 2)
    )

DELETE FROM dbo.Vendas_Sistema
WHERE Id_Pedido = 999

SELECT TOP 100 * FROM dbo.Vendas_Sistema

SELECT 
	(CASE [__$operation]
		WHEN 1 THEN 'DELETE'
		WHEN 2 THEN 'INSERT'
		WHEN 3 THEN 'UPDATE - VALOR ANTERIOR'
		WHEN 4 THEN 'UPDATE - NOVO VALOR'
	END) AS operacao,
	sys.fn_cdc_map_lsn_to_time([__$start_lsn]) AS Dt_Operacao,
	* 
FROM
	cdc.dbo_Vendas_Sistema_CT



INSERT INTO dbo.Tabela_BI
SELECT 
    Id_Pedido,
    Dt_Pedido,
    [Status],
    Quantidade,
    Valor
FROM
	cdc.dbo_Vendas_Sistema_CT
WHERE
	sys.fn_cdc_map_lsn_to_time([__$start_lsn]) >= '2022-08-10'
	AND [__$operation] = 2 -- INSERT


UPDATE A
SET
	A.[Status] = B.[Status],
	A.Quantidade = B.Quantidade,
	A.Valor = B.Valor
FROM
	dbo.Tabela_BI A
	JOIN cdc.dbo_Vendas_Sistema_CT B ON A.Id_Pedido = B.Id_Pedido
WHERE
	sys.fn_cdc_map_lsn_to_time(B.[__$start_lsn]) >= '2022-08-10'
	AND B.[__$operation] = 4 -- UPDATE - VALOR NOVO



DELETE A
FROM
	dbo.Tabela_BI A
	JOIN cdc.dbo_Vendas_Sistema_CT B ON A.Id_Pedido = B.Id_Pedido
WHERE
	sys.fn_cdc_map_lsn_to_time(B.[__$start_lsn]) >= '2022-08-10'
	AND B.[__$operation] = 1 -- DELETE
  
