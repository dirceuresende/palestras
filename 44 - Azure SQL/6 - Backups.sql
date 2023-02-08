
-- Mostrar backups no Portal

-- Não execute na master!
SELECT
    [A].[backup_file_id],
    [B].[name] AS [database_name],
    DATEADD(HOUR, -3, [A].[backup_start_date]) AS backup_start_date,
    DATEADD(HOUR, -3, [A].[backup_finish_date]) AS backup_finish_date,
    [A].[backup_type],
    (CASE 
        WHEN [A].[backup_type] = 'L' THEN 'Log Backup'
        WHEN [A].[backup_type] = 'D' THEN 'Full Database Backup'
        WHEN [A].[backup_type] = 'I' THEN 'Incremental or Differential Backup'
    END) AS [backup_type_desc],
    [A].[in_retention]
FROM
    [sys].[dm_database_backups] AS [A]
    JOIN [sys].[databases] AS [B] ON [B].[physical_database_name] = [A].[physical_database_name]
WHERE
    B.[name] <> 'master'
ORDER BY
    [A].[backup_type],
    [A].[backup_finish_date] DESC;