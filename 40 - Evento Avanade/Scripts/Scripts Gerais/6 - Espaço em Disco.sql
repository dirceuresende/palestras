
-- Tamanho das tabelas
SELECT 
    s.[name] AS [schema],
    t.[name] AS [table_name],
    p.[rows] AS [row_count],
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS [size_mb],
    CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS [used_mb], 
    CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS [unused_mb]
FROM 
    sys.tables t
    JOIN sys.indexes i ON t.[object_id] = i.[object_id]
    JOIN sys.partitions p ON i.[object_id] = p.[object_id] AND i.index_id = p.index_id
    JOIN sys.allocation_units a ON p.[partition_id] = a.container_id
    LEFT JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
WHERE 
    t.is_ms_shipped = 0
    AND i.[object_id] > 255 
GROUP BY
    t.[name], 
    s.[name], 
    p.[rows]
ORDER BY 
    [size_mb] DESC


-- Espaço dos índices
SELECT 
    s.[name] AS [schema],
    t.[name] AS [table_name],
    i.[name] AS [index_name],
    i.[type_desc],
    p.[rows] AS [row_count],
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS [size_mb],
    CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS [used_mb], 
    CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS [unused_mb]
FROM
    sys.tables t
    JOIN sys.indexes i ON t.[object_id] = i.[object_id]
    JOIN sys.partitions p ON i.[object_id] = p.[object_id] AND i.index_id = p.index_id
    JOIN sys.allocation_units a ON p.[partition_id] = a.container_id
    LEFT JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
WHERE 
    t.is_ms_shipped = 0
    AND i.[object_id] > 255 
GROUP BY
    t.[name], 
    s.[name],
    i.[name],
    i.[type_desc],
    p.[rows]
ORDER BY 
    [size_mb] DESC



-- Tamanho dos discos
SELECT DISTINCT
    VS.volume_mount_point [Montagem] ,
    VS.logical_volume_name AS [Volume] ,
    CAST(CAST(VS.total_bytes AS DECIMAL(19, 2)) / 1024 / 1024 / 1024 AS DECIMAL(10, 2)) AS [Total (GB)] ,
    CAST(CAST(VS.available_bytes AS DECIMAL(19, 2)) / 1024 / 1024 / 1024 AS DECIMAL(10, 2)) AS [Espaço Disponível (GB)] ,
    CAST(( CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100 ) AS DECIMAL(10, 2)) AS [Espaço Disponível ( % )] ,
    CAST(( 100 - CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100 ) AS DECIMAL(10, 2)) AS [Espaço em uso ( % )]
FROM
    sys.master_files AS MF
    CROSS APPLY [sys].[dm_os_volume_stats](MF.database_id, MF.file_id) AS VS
WHERE
    CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100 < 100;




-- Tamanho dos databases
SELECT
    B.database_id AS database_id,
    B.[name] AS [database_name],
    A.state_desc,
    A.[type_desc],
    A.[file_id],
    A.[name],
    A.physical_name,
    CAST(C.total_bytes / 1073741824.0 AS NUMERIC(18, 2)) AS disk_total_size_GB,
    CAST(C.available_bytes / 1073741824.0 AS NUMERIC(18, 2)) AS disk_free_size_GB,
    CAST(A.size / 128 / 1024.0 AS NUMERIC(18, 2)) AS size_GB,
    CAST(A.max_size / 128 / 1024.0 AS NUMERIC(18, 2)) AS max_size_GB,
    CAST(
        (CASE
        WHEN A.growth <= 0 THEN A.size / 128 / 1024.0
            WHEN A.max_size <= 0 THEN C.total_bytes / 1073741824.0
            WHEN A.max_size / 128 / 1024.0 > C.total_bytes / 1073741824.0 THEN C.total_bytes / 1073741824.0
            ELSE A.max_size / 128 / 1024.0 
        END) AS NUMERIC(18, 2)) AS max_real_size_GB,
    (CASE WHEN A.is_percent_growth = 1 THEN A.growth ELSE CAST(A.growth / 128 AS NUMERIC(18, 2)) END) AS growth_MB,
    A.is_percent_growth,
    (CASE WHEN A.growth <= 0 THEN 0 ELSE 1 END) AS is_autogrowth_enabled
FROM
    sys.master_files        A   WITH(NOLOCK)
    JOIN sys.databases      B   WITH(NOLOCK)    ON  A.database_id = B.database_id
    CROSS APPLY sys.dm_os_volume_stats(A.database_id, A.[file_id]) C


