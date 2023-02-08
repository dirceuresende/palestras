
---------------------------------------------
-- Verificar configurações de estatísticas
---------------------------------------------

SELECT 
	[name],
	is_auto_create_stats_on,
	is_auto_create_stats_incremental_on,
	is_auto_update_stats_on,
	is_auto_update_stats_async_on
FROM 
	sys.databases



---------------------------------------------
-- Minhas estatísticas estão atualizadas?
---------------------------------------------

SELECT
    D.last_updated AS [LastUpdate],
    B.[name] AS [Table],
    A.[name] AS [Statistic],
    D.modification_counter AS ModificationCounter,
    'UPDATE STATISTICS [' + E.[name] + '].[' + B.[name] + '] [' + A.[name] + '] WITH FULLSCAN' AS UpdateStatisticsCommand
FROM
    sys.stats A
    JOIN sys.objects B ON A.[object_id] = B.[object_id]
    JOIN sys.indexes C ON C.[object_id] = B.[object_id] AND A.[name] = C.[name]
    OUTER APPLY sys.dm_db_stats_properties(A.[object_id], A.stats_id) D
    JOIN sys.schemas E ON B.[schema_id] = E.[schema_id]
WHERE 1=1
    AND (D.last_updated < GETDATE() - 7)
    AND E.[name] NOT IN ( 'sys', 'dtp' )
    AND B.[name] NOT LIKE '[_]%'
    AND D.modification_counter > 1000
ORDER BY
    D.modification_counter DESC



---------------------------------------------
-- Minha tabela possui estatísticas?
---------------------------------------------


EXEC sp_helpstats 'dbo.FactInternetSales'



SELECT * 
FROM sys.stats 
WHERE [object_id] = OBJECT_ID('dbo.FactInternetSales')



SELECT
    obj.[name],
    obj.[object_id],
    stat.[name],
    stat.stats_id,
    sp.last_updated,
    sp.modification_counter,
    sp.rows_sampled
FROM
    sys.objects                                                             AS obj
    INNER JOIN sys.stats                                                    AS stat ON stat.[object_id] = obj.[object_id]
    CROSS APPLY sys.dm_db_stats_properties( stat.[object_id], stat.stats_id ) AS sp
WHERE
    obj.[name] = 'FactInternetSales';




---------------------------------------------
-- Encontrando consultas com planos triviais
---------------------------------------------

SELECT Name,ProductNumber 
FROM AdventureWorks2019.Production.Product
WHERE ProductNumber = 'CA-6738'


WITH XMLNAMESPACES('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS p)
SELECT  st.text,
        qp.query_plan,
        qs.*
FROM    (
    SELECT  TOP 50 *
    FROM    sys.dm_exec_query_stats
    ORDER BY total_worker_time DESC
) AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE query_plan.exist('//p:StmtSimple[@StatementOptmLevel[.="TRIVIAL"]]/p:QueryPlan/p:ParameterList') = 1


SELECT * FROM sys.dm_exec_query_optimizer_info
WHERE counter='trivial plan'


SELECT Name,ProductNumber 
FROM AdventureWorks2019.Production.Product
WHERE ProductNumber = 'CA-6738'
OPTION (QUERYTRACEON 8757)



---------------------------------------------
-- Verificar histograma de colunas
---------------------------------------------

DBCC SHOW_STATISTICS('dbo.FactInternetSales', 'ProductKey')
GO


DBCC SHOW_STATISTICS('dbo.FactInternetSales', 'SalesOrderNumber')
GO


IF (EXISTS(SELECT TOP(1) NULL FROM sys.stats WHERE [name] = 'FactInternetSales_SalesOrderNumber')) DROP STATISTICS dbo.FactInternetSales.FactInternetSales_SalesOrderNumber
CREATE STATISTICS FactInternetSales_SalesOrderNumber ON dbo.FactInternetSales(SalesOrderNumber) WITH FULLSCAN
GO

IF (EXISTS(SELECT TOP(1) NULL FROM sys.stats WHERE [name] = 'FactInternetSales_SalesOrderNumber')) DROP STATISTICS dbo.FactInternetSales.FactInternetSales_SalesOrderNumber
CREATE STATISTICS FactInternetSales_SalesOrderNumber ON dbo.FactInternetSales(SalesOrderNumber) WITH SAMPLE 10 PERCENT
GO

IF (EXISTS(SELECT TOP(1) NULL FROM sys.stats WHERE [name] = 'FactInternetSales_SalesOrderNumber')) DROP STATISTICS dbo.FactInternetSales.FactInternetSales_SalesOrderNumber
CREATE STATISTICS FactInternetSales_SalesOrderNumber ON dbo.FactInternetSales(SalesOrderNumber) WITH SAMPLE 60000 ROWS
GO

DBCC SHOW_STATISTICS('dbo.FactInternetSales', 'FactInternetSales_SalesOrderNumber')
GO


IF (OBJECT_ID('dbo.Teste') IS NOT NULL) DROP TABLE dbo.Teste
CREATE TABLE dbo.Teste (
	Nome VARCHAR(100)
)

CREATE STATISTICS Teste_Live ON dbo.Teste(Nome) WITH FULLSCAN
GO

INSERT INTO dbo.Teste (Nome)
SELECT NEWID()
GO 20000

DELETE TOP(20) PERCENT FROM dbo.Teste


SELECT
    obj.[name],
    obj.[object_id],
    stat.[name],
    stat.stats_id,
    sp.last_updated,
    sp.modification_counter,
    sp.rows_sampled
FROM
    sys.objects                                                             AS obj
    INNER JOIN sys.stats                                                    AS stat ON stat.[object_id] = obj.[object_id]
    CROSS APPLY sys.dm_db_stats_properties( stat.[object_id], stat.stats_id ) AS sp
WHERE
    obj.[name] = 'Teste';


SELECT * FROM dbo.Teste


SELECT * FROM dbo.Teste
WHERE 1 = (SELECT 1)


---------------------------------------------
-- Como monitorar as estatísticas
---------------------------------------------

CREATE EVENT SESSION [StatsGather]
ON SERVER
    ADD EVENT sqlserver.auto_stats
    ( ACTION
      (
          sqlos.task_time,
          sqlserver.database_id,
          sqlserver.[database_name],
          sqlserver.plan_handle,
          sqlserver.session_id,
          sqlserver.tsql_stack
      )
     WHERE (
               [sqlserver].[is_system] = ( 0 )
           )
    )
    ADD TARGET package0.event_file
    ( SET filename = N'C:\Temporario\StatsGather', max_rollover_files = ( 10 ))
WITH
(
    MAX_MEMORY = 4096KB,
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY = 30 SECONDS,
    MAX_EVENT_SIZE = 0KB,
    MEMORY_PARTITION_MODE = NONE,
    TRACK_CAUSALITY = OFF,
    STARTUP_STATE = OFF
);
GO

ALTER EVENT SESSION [StatsGather] ON SERVER STATE = START
GO


IF OBJECT_ID( 'tempdb..#StatsGather' ) IS NOT NULL DROP TABLE [#StatsGather];
CREATE TABLE [#StatsGather] (
    [ID]       INT IDENTITY(1, 1) NOT NULL,
    [WaitsXML] XML,
    CONSTRAINT [PK_StatsGather] PRIMARY KEY CLUSTERED ( [ID] )
);


INSERT [#StatsGather] ( [WaitsXML] )
SELECT
    CONVERT( XML, [event_data] ) AS [WaitsXML]
FROM
    [sys].[fn_xe_file_target_read_file]( 'C:\Temporario\StatsGather*.xel', NULL, NULL, NULL );


WITH x1
AS
(
    SELECT
        [sw].[WaitsXML].[value]( '(event/action[@name="session_id"]/value)[1]', 'BIGINT' )            AS [session_id],
        DB_NAME( [sw].[WaitsXML].[value]( '(event/action[@name="database_id"]/value)[1]', 'BIGINT' )) AS [database_name],
        [sw].[WaitsXML].[value]( '(/event/@timestamp)[1]', 'DATETIME2(7)' )                           AS [event_time],
        [sw].[WaitsXML].[value]( '(/event/@name)[1]', 'VARCHAR(MAX)' )                                AS [event_name],
        [sw].[WaitsXML].[value]( '(/event/data[@name="index_id"]/value)[1]', 'BIGINT' )               AS [index_id],
        [sw].[WaitsXML].[value]( '(/event/data[@name="job_type"]/text)[1]', 'VARCHAR(MAX)' )          AS [job_type],
        [sw].[WaitsXML].[value]( '(/event/data[@name="status"]/text)[1]', 'VARCHAR(MAX)' )            AS [status],
        [sw].[WaitsXML].[value]( '(/event/data[@name="duration"]/value)[1]', 'BIGINT' ) / 1000000.    AS [duration],
        [sw].[WaitsXML].[value]( '(/event/data[@name="statistics_list"]/value)[1]', 'VARCHAR(MAX)' )  AS [statistics_list]
    FROM
        [#StatsGather] AS [sw]
)
SELECT
    [x1].[session_id],
    [x1].[database_name],
    [x1].[event_time],
    [x1].[event_name],
    [x1].[index_id],
    [x1].[job_type],
    [x1].[status],
    [x1].[duration],
    [x1].[statistics_list]
FROM
    x1
ORDER BY
    [x1].[event_time];


---------------------------------------------
-- Como atualizar as estatísticas
---------------------------------------------

-- Tabela
UPDATE STATISTICS dbo.FactInternetSales WITH FULLSCAN


-- Índice
UPDATE STATISTICS dbo.FactInternetSales PK_FactInternetSales_SalesOrderNumber_SalesOrderLineNumber WITH FULLSCAN


-- Banco inteiro
sp_updatestats




---------------------------------------------
-- Como criar estatísticas
---------------------------------------------

-- Criar estatísticas de coluna única em todas as colunas qualificadas
EXEC sp_createstats;  
GO  


-- Criar estatísticas de coluna única em todas as colunas de índice qualificadas
EXEC sp_createstats 'indexonly';  
GO  


IF (EXISTS(SELECT TOP(1) NULL FROM sys.stats WHERE [name] = 'FactInternetSales_SalesOrderNumber')) DROP STATISTICS dbo.FactInternetSales.FactInternetSales_SalesOrderNumber
CREATE STATISTICS FactInternetSales_SalesOrderNumber ON dbo.FactInternetSales(SalesOrderNumber) WITH FULLSCAN
GO


IF (EXISTS(SELECT TOP(1) NULL FROM sys.stats WHERE [name] = 'FactInternetSales_SalesOrderNumber')) DROP STATISTICS dbo.FactInternetSales.FactInternetSales_SalesOrderNumber
CREATE STATISTICS FactInternetSales_SalesOrderNumber ON dbo.FactInternetSales(SalesOrderNumber) WITH SAMPLE 10 PERCENT
GO


IF (EXISTS(SELECT TOP(1) NULL FROM sys.stats WHERE [name] = 'FactInternetSales_SalesOrderNumber')) DROP STATISTICS dbo.FactInternetSales.FactInternetSales_SalesOrderNumber
CREATE STATISTICS FactInternetSales_SalesOrderNumber ON dbo.FactInternetSales(SalesOrderNumber) WITH SAMPLE 60000 ROWS
GO


IF (EXISTS(SELECT TOP(1) NULL FROM sys.stats WHERE [name] = 'FactInternetSales_SalesOrderNumber')) DROP STATISTICS dbo.FactInternetSales.FactInternetSales_SalesOrderNumber
CREATE STATISTICS FactInternetSales_SalesOrderNumber ON dbo.FactInternetSales(SalesOrderNumber) WITH NORECOMPUTE -- Desabilite a opção de atualização das estatísticas automáticas
GO


IF (EXISTS(SELECT TOP(1) NULL FROM sys.stats WHERE [name] = 'FactInternetSales_SalesOrderNumber')) DROP STATISTICS dbo.FactInternetSales.FactInternetSales_SalesOrderNumber
CREATE STATISTICS FactInternetSales_SalesOrderNumber ON dbo.FactInternetSales(SalesOrderNumber) WITH MAXDOP=8
GO




---------------------------------------------
-- Rotina para manutenção de estatísticas
---------------------------------------------

-- https://ola.hallengren.com/sql-server-index-and-statistics-maintenance.html


EXEC master.dbo.IndexOptimize
    @Databases = N'ALL_DATABASES',                       -- nvarchar(max)
    @FragmentationLow = NULL,
	@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
	@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
	@FragmentationLevel1 = 5,
	@FragmentationLevel2 = 30,
	@UpdateStatistics = 'ALL', -- Update index and column statistics
	@OnlyModifiedStatistics = 'Y',
	@MaxDOP = 0,
	@TimeLimit = 3600 -- 3600 segundos = 60 minutos




EXEC master.dbo.IndexOptimize
    @Databases = N'',                       -- nvarchar(max)
    @FragmentationLow = N'',                -- nvarchar(max)
    @FragmentationMedium = N'',             -- nvarchar(max)
    @FragmentationHigh = N'',               -- nvarchar(max)
    @FragmentationLevel1 = 0,               -- int
    @FragmentationLevel2 = 0,               -- int
    @MinNumberOfPages = 0,                  -- int
    @MaxNumberOfPages = 0,                  -- int
    @SortInTempdb = N'',                    -- nvarchar(max)
    @MaxDOP = 0,                            -- int
    @FillFactor = 0,                        -- int
    @PadIndex = N'',                        -- nvarchar(max)
    @LOBCompaction = N'',                   -- nvarchar(max)
    @UpdateStatistics = N'',                -- nvarchar(max)
    @OnlyModifiedStatistics = N'',          -- nvarchar(max)
    @StatisticsModificationLevel = 0,       -- int
    @StatisticsSample = 0,                  -- int
    @StatisticsResample = N'',              -- nvarchar(max)
    @PartitionLevel = N'',                  -- nvarchar(max)
    @MSShippedObjects = N'',                -- nvarchar(max)
    @Indexes = N'',                         -- nvarchar(max)
    @TimeLimit = 0,                         -- int
    @Delay = 0,                             -- int
    @WaitAtLowPriorityMaxDuration = 0,      -- int
    @WaitAtLowPriorityAbortAfterWait = N'', -- nvarchar(max)
    @Resumable = N'',                       -- nvarchar(max)
    @AvailabilityGroups = N'',              -- nvarchar(max)
    @LockTimeout = 0,                       -- int
    @LockMessageSeverity = 0,               -- int
    @StringDelimiter = N'',                 -- nvarchar(max)
    @DatabaseOrder = N'',                   -- nvarchar(max)
    @DatabasesInParallel = N'',             -- nvarchar(max)
    @ExecuteAsUser = N'',                   -- nvarchar(max)
    @LogToTable = N'',                      -- nvarchar(max)
    @Execute = N''                          -- nvarchar(max)