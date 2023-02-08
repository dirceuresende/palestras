
IF (OBJECT_ID('dbo.Testa_Job') IS NULL)
BEGIN

    CREATE TABLE dbo.Testa_Job (
        Id_Teste INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
        Dt_Teste DATETIME DEFAULT GETDATE(),
        Descricao VARCHAR(100)
    )

END


CREATE OR ALTER PROCEDURE dbo.stpTesta_Job
AS
BEGIN
    
    INSERT INTO dbo.Testa_Job (Descricao)
    VALUES('Teste Job')

END
GO


CREATE DATABASE SCOPED CREDENTIAL usrExecutaJob 
WITH 
	IDENTITY = 'usrExecutaJob',
    SECRET = 'anp-senhaforte!@#2';
GO

CREATE USER [usrExecutaJob] WITH PASSWORD = 'anp-senhaforte!@#2'
GO

GRANT EXECUTE ON dbo.[stpTesta_Job] TO [usrExecutaJob]
GO


IF (NOT EXISTS(SELECT TOP(1) NULL FROM jobs.target_groups WHERE [target_group_name] = 'GrupoANP'))
BEGIN

    EXEC jobs.sp_add_target_group 'GrupoANP'

END
GO


IF (NOT EXISTS(SELECT TOP(1) NULL FROM jobs.target_group_members WHERE [target_group_name] = 'GrupoANP'))
BEGIN

    EXEC jobs.sp_add_target_group_member
	    @target_group_name = 'GrupoANP',
        @target_type = N'SqlDatabase',
	    @database_name =N'dirceu',
        @server_name = N'dirceuresende.database.windows.net'

END
GO
   

SELECT * FROM jobs.target_groups
SELECT * FROM jobs.target_group_members


/*

-- Se quiser apagar

EXEC [jobs].sp_delete_target_group_member
    @target_group_name = N'GrupoANP', -- nvarchar(128)
    @target_id = '4649463B-A369-4898-AF1F-510C39572C7C' -- uniqueidentifier

*/

	

EXEC jobs.sp_add_job
	@job_name='Executa a Procedure', 
	@description='Job que serve para executar aquela procedure'


EXEC jobs.sp_add_jobstep 
	@job_name='Executa a Procedure',
	@command=N'EXEC dbo.stpTesta_Job',
	@credential_name='usrExecutaJob',
	@target_group_name='GrupoANP'



SELECT * 
FROM jobs.jobs


SELECT * 
FROM jobs.jobsteps


SELECT 
	js.* 
FROM 
	jobs.jobsteps js
	JOIN jobs.jobs j ON j.job_id = js.job_id AND j.job_version = js.job_version



EXEC jobs.sp_update_job
	@job_name='Executa a Procedure',
	@enabled=1,
	@schedule_interval_type='Hours', -- 'Once', 'Minutes', 'Hours', 'Days', 'Weeks', 'Months'
	@schedule_interval_count=1,
	@schedule_start_time='2023-02-04 02:25:00'


SELECT * 
FROM jobs.jobs


EXEC jobs.sp_start_job 'Executa a Procedure'


-- SELECT * FROM dbo.Testa_Job


SELECT * 
FROM jobs.job_executions
ORDER BY start_time DESC


-- Para a execução da SP
DECLARE @executionId UNIQUEIDENTIFIER

SELECT @executionId = job_execution_id
FROM jobs.job_executions
WHERE is_active = 1 
AND job_name = 'Executa a Procedure'


EXEC jobs.sp_stop_job @executionId


EXEC jobs.sp_purge_jobhistory 
	@job_name='Executa a Procedure', 
	@oldest_date='2023-02-02 00:00:00'


SELECT * 
FROM jobs.job_executions
ORDER BY start_time DESC



EXEC jobs.sp_delete_job
    @job_name = N'Executa a Procedure', -- nvarchar(128)
    @force = 1 -- bit


EXEC jobs.sp_delete_target_group
    @target_group_name = N'GrupoANP', -- nvarchar(128)
    @force = 1 -- bit
