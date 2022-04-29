-- Tabelas sem compressão
SELECT DISTINCT 
    C.[name] AS [Schema],
    A.[name] AS Tabela,
    NULL AS Indice,
    'ALTER TABLE [' + C.[name] + '].[' + A.[name] + '] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE)' AS Comando
FROM 
    sys.tables                   A
    INNER JOIN sys.partitions    B   ON A.[object_id] = B.[object_id]
    INNER JOIN sys.schemas       C   ON A.[schema_id] = C.[schema_id]
WHERE 
    B.data_compression_desc = 'NONE'
    AND B.index_id = 0 -- HEAP
    AND A.[type] = 'U'
    
UNION
 
SELECT DISTINCT 
    C.[name] AS [Schema],
    B.[name] AS Tabela,
    A.[name] AS Indice,
    'ALTER INDEX [' + A.[name] + '] ON [' + C.[name] + '].[' + B.[name] + '] REBUILD PARTITION = ALL WITH ( STATISTICS_NORECOMPUTE = OFF, ONLINE = OFF, SORT_IN_TEMPDB = OFF, DATA_COMPRESSION = PAGE)'
FROM 
    sys.indexes                  A
    INNER JOIN sys.tables        B   ON A.[object_id] = B.[object_id]
    INNER JOIN sys.schemas       C   ON B.[schema_id] = C.[schema_id]
    INNER JOIN sys.partitions    D   ON A.[object_id] = D.[object_id] AND A.index_id = D.index_id
WHERE
    D.data_compression_desc =  'NONE'
    AND D.index_id <> 0
    AND A.[type] IN (1, 2) -- CLUSTERED e NONCLUSTERED (Rowstore)
    AND B.[type] = 'U'
ORDER BY
    Tabela,
    Indice
    
    
    
    
-- Fragmentação dos índices
SELECT
    OBJECT_NAME(B.object_id) AS TableName,
    B.name AS IndexName,
    A.index_type_desc AS IndexType,
    A.avg_fragmentation_in_percent
FROM
    sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED')	A
    INNER JOIN sys.indexes							B	WITH(NOLOCK) ON B.object_id = A.object_id AND B.index_id = A.index_id
WHERE
    A.avg_fragmentation_in_percent > 30
    AND OBJECT_NAME(B.object_id) NOT LIKE '[_]%'
    AND A.index_type_desc != 'HEAP'
ORDER BY
    A.avg_fragmentation_in_percent DESC
    
    
    
    
-- Tabelas sem índice clustered (Heap)
SELECT
    B.[name] + '.' + A.[name] AS table_name
FROM
    sys.tables A
    JOIN sys.schemas B ON A.[schema_id] = B.[schema_id]
    JOIN sys.indexes C ON A.[object_id] = C.[object_id]
WHERE
    C.[type] = 0 -- = Heap 
ORDER BY
    table_name
    
    
    
-- Utilização dos índices
SELECT
    D.[name] + '.' + C.[name] AS ObjectName,
    A.[name] AS IndexName,
    (CASE WHEN A.is_unique = 1 THEN 'UNIQUE ' ELSE '' END) + A.[type_desc] AS IndexType,
    MAX(B.last_user_seek) AS last_user_seek,
    MAX(COALESCE(B.last_user_seek, B.last_user_scan)) AS last_read,
    SUM(B.user_seeks) AS User_Seeks,
    SUM(B.user_scans) AS User_Scans,
    SUM(B.user_seeks) + SUM(B.user_scans) AS User_Reads,
    SUM(B.user_lookups) AS User_Lookups,
    SUM(B.user_updates) AS User_Updates,
    SUM(E.[rows]) AS [row_count],
    CAST(ROUND(((SUM(F.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS [size_mb],
    CAST(ROUND(((SUM(F.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS [used_mb], 
    CAST(ROUND(((SUM(F.total_pages) - SUM(F.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS [unused_mb]
FROM
    sys.indexes A
    LEFT JOIN sys.dm_db_index_usage_stats B ON A.[object_id] = B.[object_id] AND A.index_id = B.index_id AND B.database_id = DB_ID()
    JOIN sys.objects C ON A.[object_id] = C.[object_id]
    JOIN sys.schemas D ON C.[schema_id] = D.[schema_id]
    JOIN sys.partitions E ON A.[object_id] = E.[object_id] AND A.index_id = E.index_id
    JOIN sys.allocation_units F ON E.[partition_id] = F.container_id
WHERE
    C.is_ms_shipped = 0
GROUP BY
    D.[name] + '.' + C.[name],
    A.[name],
    (CASE WHEN A.is_unique = 1 THEN 'UNIQUE ' ELSE '' END) + A.[type_desc]
ORDER BY
    1, 2
    
    
    
    
    
-- Sugestões de Missing Index
SELECT
    db.[name] AS [DatabaseName],
    id.[object_id] AS [ObjectID],
    OBJECT_NAME(id.[object_id], db.[database_id]) AS [ObjectName],
    id.[statement] AS [FullyQualifiedObjectName],
    id.[equality_columns] AS [EqualityColumns],
    id.[inequality_columns] AS [InEqualityColumns],
    id.[included_columns] AS [IncludedColumns],
    gs.[unique_compiles] AS [UniqueCompiles],
    gs.[user_seeks] AS [UserSeeks],
    gs.[user_scans] AS [UserScans],
    gs.[last_user_seek] AS [LastUserSeekTime],
    gs.[last_user_scan] AS [LastUserScanTime],
    gs.[avg_total_user_cost] AS [AvgTotalUserCost],
    gs.[avg_user_impact] AS [AvgUserImpact],
    gs.[user_seeks] * gs.[avg_total_user_cost] * ( gs.[avg_user_impact] * 0.01 ) AS [IndexAdvantage],
    gs.[system_seeks] AS [SystemSeeks],
    gs.[system_scans] AS [SystemScans],
    gs.[last_system_seek] AS [LastSystemSeekTime],
    gs.[last_system_scan] AS [LastSystemScanTime],
    gs.[avg_total_system_cost] AS [AvgTotalSystemCost],
    gs.[avg_system_impact] AS [AvgSystemImpact],
    'CREATE INDEX [IX_' + OBJECT_NAME(id.[object_id], db.[database_id]) + '_' + REPLACE(REPLACE(REPLACE(ISNULL(id.[equality_columns], ''), ', ', '_'), '[', ''), ']', '') + CASE WHEN id.[equality_columns] IS NOT NULL AND id.[inequality_columns] IS NOT NULL THEN '_' ELSE '' END + REPLACE(REPLACE(REPLACE(ISNULL(id.[inequality_columns], ''), ', ', '_'), '[', ''), ']', '') + '_' + LEFT(CAST(NEWID() AS [NVARCHAR](64)), 5) + ']' + ' ON ' + id.[statement] + ' (' + ISNULL(id.[equality_columns], '') + CASE WHEN id.[equality_columns] IS NOT NULL AND id.[inequality_columns] IS NOT NULL THEN ',' ELSE '' END + ISNULL(id.[inequality_columns], '') + ')' + ISNULL(' INCLUDE (' + id.[included_columns] + ')', '') AS [ProposedIndex],
    CAST(CURRENT_TIMESTAMP AS [SMALLDATETIME]) AS [CollectionDate]
FROM
    [sys].[dm_db_missing_index_group_stats] gs WITH ( NOLOCK )
    JOIN [sys].[dm_db_missing_index_groups] ig WITH ( NOLOCK ) ON gs.[group_handle] = ig.[index_group_handle]
    JOIN [sys].[dm_db_missing_index_details] id WITH ( NOLOCK ) ON ig.[index_handle] = id.[index_handle]
    JOIN [sys].[databases] db WITH ( NOLOCK ) ON db.[database_id] = id.[database_id]
WHERE
    db.[database_id] = DB_ID()
    --AND gs.avg_total_user_cost * ( gs.avg_user_impact / 100.0 ) * ( gs.user_seeks + gs.user_scans ) > 10
ORDER BY
    [IndexAdvantage] DESC
OPTION ( RECOMPILE );




-- Estatísticas há mais de 7 dias sem atualizar
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
WHERE
    D.last_updated < GETDATE() - 7
    AND E.[name] NOT IN ( 'sys', 'dtp' )
    AND B.[name] NOT LIKE '[_]%'
    AND D.modification_counter > 1000
ORDER BY
    D.modification_counter DESC
    
    

    
    
       