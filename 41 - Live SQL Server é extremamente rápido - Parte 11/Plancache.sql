

-- Planos das consultas em execução
SELECT
    B.start_time,
    A.session_id,
    B.command,
    A.login_name,
    A.[host_name],
    A.[program_name],
    B.logical_reads,
    B.cpu_time,
    B.writes,
    B.blocking_session_id,
    C.query_plan
FROM
    sys.dm_exec_sessions AS A WITH (NOLOCK)
    LEFT JOIN sys.dm_exec_requests AS B WITH (NOLOCK) ON A.session_id = B.session_id
    OUTER APPLY sys.dm_exec_query_plan(B.[plan_handle]) AS C
WHERE
    A.session_id > 50
    AND A.session_id <> @@SPID
    AND (A.[status] <> 'sleeping' OR (A.[status] = 'sleeping' AND A.open_transaction_count > 0))
ORDER BY
    B.start_time
    
    
    

-- Visualizar planos em cache
SELECT
    cp.objtype AS ObjectType,
    OBJECT_NAME(st.objectid, st.dbid) AS ObjectName,
    cp.usecounts AS ExecutionCount,
    st.text AS QueryText,
    qp.query_plan AS QueryPlan
FROM
    sys.dm_exec_cached_plans AS cp
    CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
    CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS st
ORDER BY
    ExecutionCount DESC
    
    
    
    
-- Identificar consultas pesadas usando a plancache
SELECT TOP(100)
    DB_NAME(C.[dbid]) AS [database],
    B.[text],
    (SELECT CAST(SUBSTRING(B.[text], (A.statement_start_offset/2)+1,   
        (((CASE A.statement_end_offset  
            WHEN -1 THEN DATALENGTH(B.[text]) 
            ELSE A.statement_end_offset  
        END) - A.statement_start_offset)/2) + 1) AS NVARCHAR(MAX)) FOR XML PATH(''), TYPE) AS [TSQL],
    C.query_plan,

    A.last_execution_time,
    A.execution_count,
 
    A.total_elapsed_time / 1000 AS total_elapsed_time_ms,
    A.last_elapsed_time / 1000 AS last_elapsed_time_ms,
    A.min_elapsed_time / 1000 AS min_elapsed_time_ms,
    A.max_elapsed_time / 1000 AS max_elapsed_time_ms,
    ((A.total_elapsed_time / A.execution_count) / 1000) AS avg_elapsed_time_ms,
 
    A.total_worker_time / 1000 AS total_worker_time_ms,
    A.last_worker_time / 1000 AS last_worker_time_ms,
    A.min_worker_time / 1000 AS min_worker_time_ms,
    A.max_worker_time / 1000 AS max_worker_time_ms,
    ((A.total_worker_time / a.execution_count) / 1000) AS avg_worker_time_ms,
   
    A.total_physical_reads,
    A.last_physical_reads,
    A.min_physical_reads,
    A.max_physical_reads,
   
    A.total_logical_reads,
    A.last_logical_reads,
    A.min_logical_reads,
    A.max_logical_reads,
   
    A.total_logical_writes,
    A.last_logical_writes,
    A.min_logical_writes,
    A.max_logical_writes
FROM
    sys.dm_exec_query_stats A
    CROSS APPLY sys.dm_exec_sql_text(A.[sql_handle]) B
    OUTER APPLY sys.dm_exec_query_plan (A.plan_handle) AS C
ORDER BY
    A.total_elapsed_time DESC
    
    
    
    
-- Plancache das Stored Procedures
SELECT TOP(100)
    B.[name] AS rotina,
    A.cached_time,
    A.last_execution_time,
    A.execution_count,

    A.total_elapsed_time / 1000 AS total_elapsed_time_ms,
    A.last_elapsed_time / 1000 AS last_elapsed_time_ms,
    A.min_elapsed_time / 1000 AS min_elapsed_time_ms,
    A.max_elapsed_time / 1000 AS max_elapsed_time_ms,
    ((A.total_elapsed_time / A.execution_count) / 1000) AS avg_elapsed_time_ms,

    A.total_worker_time / 1000 AS total_worker_time_ms,
    A.last_worker_time / 1000 AS last_worker_time_ms,
    A.min_worker_time / 1000 AS min_worker_time_ms,
    A.max_worker_time / 1000 AS max_worker_time_ms,
    ((A.total_worker_time / A.execution_count) / 1000) AS avg_worker_time_ms,
    
    A.total_physical_reads,
    A.last_physical_reads,
    A.min_physical_reads,
    A.max_physical_reads,
    
    A.total_logical_reads,
    A.last_logical_reads,
    A.min_logical_reads,
    A.max_logical_reads,
    
    A.total_logical_writes,
    A.last_logical_writes,
    A.min_logical_writes,
    A.max_logical_writes
FROM
    sys.dm_exec_procedure_stats                 A
    JOIN sys.objects                            B    ON  A.[object_id] = B.[object_id]
ORDER BY
    A.execution_count DESC
    
    
    
    
-- Conversão implícita através da plancache
SELECT TOP ( 100 )
    DB_NAME(B.[dbid]) AS [Database],
    B.[text] AS [Consulta],
    A.total_worker_time AS [Total Worker Time],
    A.total_worker_time / A.execution_count AS [Avg Worker Time],
    A.max_worker_time AS [Max Worker Time],
    A.total_elapsed_time / A.execution_count AS [Avg Elapsed Time],
    A.max_elapsed_time AS [Max Elapsed Time],
    A.total_logical_reads / A.execution_count AS [Avg Logical Reads],
    A.max_logical_reads AS [Max Logical Reads],
    A.execution_count AS [Execution Count],
    A.creation_time AS [Creation Time],
    C.query_plan AS [Query Plan]
FROM
    sys.dm_exec_query_stats AS A WITH ( NOLOCK )
    CROSS APPLY sys.dm_exec_sql_text(A.plan_handle) AS B
    CROSS APPLY sys.dm_exec_query_plan(A.plan_handle) AS C
WHERE
    CAST(C.query_plan AS NVARCHAR(MAX)) LIKE ( '%PlanAffectingConvert%ConvertIssue%CONVERT_IMPLICIT%' )
    AND B.[dbid] = DB_ID()
    AND B.[text] NOT LIKE '%sys.dm_exec_sql_text%' -- Não pegar a própria consulta
ORDER BY
    A.total_worker_time DESC
    
    
    
-- Consultas em cache utilizando paralelismo
SELECT TOP(20)
    st.[text] AS [SqlText],
    cp.cacheobjtype,
    cp.objtype,
    DB_NAME(st.[dbid]) AS [DatabaseName],
    cp.usecounts,
    qp.query_plan
FROM
    sys.dm_exec_cached_plans cp
    CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
    CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
WHERE
    cp.cacheobjtype = 'Compiled Plan'
    AND qp.query_plan.value('declare namespace p="http://schemas.microsoft.com/sqlserver/2004/07/showplan"; max(//p:RelOp/@Parallel)', 'float') > 0
ORDER BY
    cp.usecounts DESC;
    
    
    
-- Missing Index através da plancache
WITH XMLNAMESPACES
(
    DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
)
SELECT
    query_plan,
    n.value('(@StatementText)[1]', 'VARCHAR(4000)') AS sql_text,
    n.value('(//MissingIndexGroup/@Impact)[1]', 'FLOAT') AS impact,
    DB_ID(REPLACE(REPLACE(n.value('(//MissingIndex/@Database)[1]', 'VARCHAR(128)'), '[', ''), ']', '')) AS database_id,
    OBJECT_ID(n.value('(//MissingIndex/@Database)[1]', 'VARCHAR(128)') + '.' + n.value('(//MissingIndex/@Schema)[1]', 'VARCHAR(128)') + '.' + n.value('(//MissingIndex/@Table)[1]', 'VARCHAR(128)')) AS OBJECT_ID,
    n.value('(//MissingIndex/@Database)[1]', 'VARCHAR(128)') + '.' + n.value('(//MissingIndex/@Schema)[1]', 'VARCHAR(128)') + '.' + n.value('(//MissingIndex/@Table)[1]', 'VARCHAR(128)') AS statement,
    (
        SELECT DISTINCT
            c.value('(@Name)[1]', 'VARCHAR(128)') + ', '
        FROM
            n.nodes('//ColumnGroup') AS t(cg)
            CROSS APPLY cg.nodes('Column') AS r(c)
        WHERE
            cg.value('(@Usage)[1]', 'VARCHAR(128)') = 'EQUALITY'
        FOR XML PATH('')
    ) AS equality_columns,
    (
        SELECT DISTINCT
            c.value('(@Name)[1]', 'VARCHAR(128)') + ', '
        FROM
            n.nodes('//ColumnGroup') AS t(cg)
            CROSS APPLY cg.nodes('Column') AS r(c)
        WHERE
            cg.value('(@Usage)[1]', 'VARCHAR(128)') = 'INEQUALITY'
        FOR XML PATH('')
    ) AS inequality_columns,
    (
        SELECT DISTINCT
            c.value('(@Name)[1]', 'VARCHAR(128)') + ', '
        FROM
            n.nodes('//ColumnGroup') AS t(cg)
            CROSS APPLY cg.nodes('Column') AS r(c)
        WHERE
            cg.value('(@Usage)[1]', 'VARCHAR(128)') = 'INCLUDE'
        FOR XML PATH('')
    ) AS include_columns
INTO
    #MissingIndexInfo
FROM
(
    SELECT
        query_plan
    FROM
    (
        SELECT DISTINCT
            plan_handle
        FROM
            sys.dm_exec_query_stats WITH ( NOLOCK )
    ) AS qs
    OUTER APPLY sys.dm_exec_query_plan(qs.plan_handle) tp
    WHERE
        tp.query_plan.exist('//MissingIndex') = 1
) AS tab(query_plan)
CROSS APPLY query_plan.nodes('//StmtSimple') AS q(n)
WHERE
    n.exist('QueryPlan/MissingIndexes') = 1;



UPDATE
    #MissingIndexInfo
SET
    equality_columns = LEFT(equality_columns, LEN(equality_columns) - 1),
    inequality_columns = LEFT(inequality_columns, LEN(inequality_columns) - 1),
    include_columns = LEFT(include_columns, LEN(include_columns) - 1);


SELECT
    *
FROM
    #MissingIndexInfo;
    
    
    
-- Eventos de Keylookup na Plancache
DECLARE @plans TABLE
(
    query_text NVARCHAR(MAX),
    o_name sysname,
    execution_plan XML,
    last_execution_time DATETIME,
    execution_count BIGINT,
    total_worker_time BIGINT,
    total_physical_reads BIGINT,
    total_logical_reads BIGINT
);

DECLARE @lookups TABLE
(
    table_name sysname,
    index_name sysname,
    index_cols NVARCHAR(MAX)
);

WITH query_stats
AS ( 
    SELECT
         [sql_handle],
         [plan_handle],
         MAX(last_execution_time) AS last_execution_time,
         SUM(execution_count) AS execution_count,
         SUM(total_worker_time) AS total_worker_time,
         SUM(total_physical_reads) AS total_physical_reads,
         SUM(total_logical_reads) AS total_logical_reads
     FROM
         sys.dm_exec_query_stats
     GROUP BY
         [sql_handle],
         [plan_handle] 
)
INSERT INTO @plans
(
    query_text,
    o_name,
    execution_plan,
    last_execution_time,
    execution_count,
    total_worker_time,
    total_physical_reads,
    total_logical_reads
)
SELECT /*TOP 50*/
    sql_text.[text],
    CASE
        WHEN sql_text.objectid IS NOT NULL THEN ISNULL(OBJECT_NAME(sql_text.objectid, sql_text.[dbid]), 'Unresolved')
        ELSE CAST('Ad-hoc\Prepared' AS sysname)
    END,
    query_plan.query_plan,
    query_stats.last_execution_time,
    query_stats.execution_count,
    query_stats.total_worker_time,
    query_stats.total_physical_reads,
    query_stats.total_logical_reads
FROM
    query_stats
    CROSS APPLY sys.dm_exec_sql_text(query_stats.sql_handle) AS [sql_text]
    CROSS APPLY sys.dm_exec_query_plan(query_stats.plan_handle) AS [query_plan]
WHERE
    query_plan.query_plan IS NOT NULL;

;WITH XMLNAMESPACES
 (
     DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
 )
, lookups
AS ( SELECT
         DB_ID(REPLACE(REPLACE(keylookups.keylookup.value('(Object/@Database)[1]', 'sysname'), '[', ''), ']', '')) AS [database_id],
         OBJECT_ID(keylookups.keylookup.value('(Object/@Database)[1]', 'sysname') + '.' + keylookups.keylookup.value('(Object/@Schema)[1]', 'sysname') + '.' + keylookups.keylookup.value('(Object/@Table)[1]', 'sysname')) AS [object_id],
         keylookups.keylookup.value('(Object/@Database)[1]', 'sysname') AS [database],
         keylookups.keylookup.value('(Object/@Schema)[1]', 'sysname') AS [schema],
         keylookups.keylookup.value('(Object/@Table)[1]', 'sysname') AS [table],
         keylookups.keylookup.value('(Object/@Index)[1]', 'sysname') AS [index],
         REPLACE(keylookups.keylookup.query(' 
for $column in DefinedValues/DefinedValue/ColumnReference 
return string($column/@Column) 
').value('.', 'varchar(max)'), ' ', ', ') AS [columns],
         plans.query_text,
         plans.o_name,
         plans.execution_plan,
         plans.last_execution_time,
         plans.execution_count,
         plans.total_worker_time,
         plans.total_physical_reads,
         plans.total_logical_reads
     FROM
         @plans AS [plans]
         CROSS APPLY execution_plan.nodes('//RelOp/IndexScan[@Lookup="1"]') AS keylookups(keylookup) )
SELECT
    lookups.[database],
    lookups.[schema],
    lookups.[table],
    lookups.[index],
    lookups.[columns],
    index_stats.user_lookups,
    index_stats.last_user_lookup,
    lookups.execution_count,
    lookups.total_worker_time,
    lookups.total_physical_reads,
    lookups.total_logical_reads,
    lookups.last_execution_time,
    lookups.o_name AS [object_name],
    lookups.query_text,
    lookups.execution_plan
FROM
    lookups
    INNER JOIN sys.dm_db_index_usage_stats AS [index_stats] ON lookups.database_id = index_stats.database_id
                                                               AND lookups.[object_id] = index_stats.[object_id]
WHERE
    index_stats.user_lookups > 0
    AND lookups.[database] NOT IN ( '[master]', '[model]', '[msdb]', '[tempdb]' )
ORDER BY
    index_stats.user_lookups DESC,
    lookups.total_physical_reads DESC,
    lookups.total_logical_reads DESC
    
  