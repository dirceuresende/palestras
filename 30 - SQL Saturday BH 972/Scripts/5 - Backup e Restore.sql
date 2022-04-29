
-- Histórico de backups realizados
SELECT
    B.[database_name],
    (CASE B.[type]
        WHEN 'D' THEN 'Full Backup'
        WHEN 'I' THEN 'Differential Backup'
        WHEN 'L' THEN 'TLog Backup'
        WHEN 'F' THEN 'File or filegroup'
        WHEN 'G' THEN 'Differential file'
        WHEN 'P' THEN 'Partial'
        WHEN 'Q' THEN 'Differential Partial'
    END) AS BackupType,
    B.recovery_model AS RecoveryModel,
    B.backup_start_date,
    B.backup_finish_date,
    CAST(DATEDIFF(SECOND,B.backup_start_date, B.backup_finish_date) AS VARCHAR(4)) + ' ' + 'Seconds' AS TotalTimeTaken,
    B.expiration_date,
    B.[user_name],
    B.machine_name,
    B.is_password_protected,
    B.collation_name,
    B.is_copy_only,
    CONVERT(NUMERIC(20, 2), B.backup_size / 1048576) AS BackupSizeMB,
    A.logical_device_name,
    A.physical_device_name,
    B.[name] AS backupset_name,
    B.[description],
    B.has_backup_checksums,
    B.is_damaged,
    B.has_incomplete_metadata
FROM
    sys.databases X
    JOIN msdb.dbo.backupset B ON X.[name] = B.[database_name]
    JOIN msdb.dbo.backupmediafamily A ON A.media_set_id = B.media_set_id
WHERE
    B.backup_start_date >= CONVERT(DATE, DATEADD(DAY, -7, GETDATE()))


 -- Histórico dos Restores realizados na instância
SELECT
    A.[restore_history_id],
    A.[restore_date],
    A.[destination_database_name],
    C.physical_device_name,
    A.[user_name],
    A.[backup_set_id],
    CASE A.[restore_type]
        WHEN 'D' THEN 'Database'
        WHEN 'I' THEN 'Differential'
        WHEN 'L' THEN 'Log'
        WHEN 'F' THEN 'File'
        WHEN 'G' THEN 'Filegroup'
        WHEN 'V' THEN 'Verifyonlyl'
    END AS RestoreType,
    A.[replace],
    A.[recovery],
    A.[restart],
    A.[stop_at],
    A.[device_count],
    A.[stop_at_mark_name],
    A.[stop_before]
FROM
    [msdb].[dbo].[restorehistory] A
    JOIN [msdb].[dbo].[backupset] B ON A.backup_set_id = B.backup_set_id
    JOIN msdb.dbo.backupmediafamily C ON B.media_set_id = C.media_set_id
WHERE
    A.restore_date >= CONVERT(DATE, DATEADD(DAY, -7, GETDATE()))



-- Bancos há mais de 7 dias sem backup
SELECT
    A.[name] AS [database_name],
    A.recovery_model_desc,
    (SELECT SUM(CAST(size / 128 / 1024.0 AS NUMERIC(18, 2))) FROM sys.master_files WHERE A.[name] = [name]) AS size_GB,
    MAX(B.backup_start_date) AS last_backup_date
FROM
    sys.databases A
    LEFT JOIN msdb.dbo.backupset B ON A.[name] = B.[database_name]
WHERE
    (B.backup_set_id IS NULL OR DATEDIFF(DAY, B.backup_start_date, GETDATE()) > 7)
    AND A.[name] NOT IN ('tempdb', 'model')
GROUP BY
    A.[name],
    A.recovery_model_desc



-- Verifica backups/restores em andamento

-- BACKUP DATABASE dirceuresende TO DISK = 'C:\Temporario\dirceuresende.bak' WITH COPY_ONLY, COMPRESSION

SELECT
    R.session_id,
    R.command AS Ds_Operacao,
    B.name AS Nm_Banco,
    R.start_time AS Dt_Inicio,
    CONVERT(VARCHAR(20), DATEADD(MS, R.estimated_completion_time, GETDATE()), 20) AS Dt_Previsao_Fim,
    CONVERT(NUMERIC(6, 2), R.percent_complete) AS Vl_Percentual_Concluido,
    CONVERT(NUMERIC(6, 2), R.total_elapsed_time / 1000.0 / 60.0) AS Qt_Minutos_Execucao,
    CONVERT(NUMERIC(6, 2), R.estimated_completion_time / 1000.0 / 60.0) AS Qt_Minutos_Restantes,
    CONVERT(NUMERIC(6, 2), R.estimated_completion_time / 1000.0 / 60.0 / 60.0) AS Qt_Horas_Restantes,
    CONVERT(VARCHAR(MAX), ( SELECT
                                SUBSTRING(text, R.statement_start_offset / 2, CASE WHEN R.statement_end_offset = -1 THEN 1000 ELSE ( R.statement_end_offset - R.statement_start_offset ) / 2 END)
                            FROM
                                sys.dm_exec_sql_text(sql_handle)
                            )) AS Ds_Comando
FROM
    sys.dm_exec_requests	R	WITH(NOLOCK)
    JOIN sys.databases		B	WITH(NOLOCK)	 ON R.database_id = B.database_id
WHERE
    R.command IN ( 
        'BACKUP DATABASE', 
        'RESTORE DATABASE', 
        'ALTER INDEX REORGANIZE', 
        'AUTO_SHRINK option with ALTER DATABASE', 
        'CREATE INDEX',
        'DBCC CHECKDB',
        'DBCC CHECKFILEGROUP',
        'DBCC CHECKTABLE',
        'DBCC INDEXDEFRAG',
        'DBCC SHRINKDATABASE',
        'DBCC SHRINKFILE',
        'KILL',
        'UPDATE STATISTICS',
        'DBCC'
    )
    AND R.estimated_completion_time > 0 