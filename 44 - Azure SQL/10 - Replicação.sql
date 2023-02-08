SELECT * FROM sys.dm_database_replica_states


SELECT @@SERVERNAME
SELECT DATABASEPROPERTYEX(DB_NAME(), 'Updateability')

CREATE TABLE dbo.Teste ( Id INT )

INSERT INTO dbo.Teste
SELECT column_id FROM sys.columns


SELECT * FROM dbo.Teste


-- Forçar uso de CPU
DECLARE @T DATETIME, @F BIGINT;
SET @T = GETDATE();
WHILE DATEADD(SECOND,600,@T)>GETDATE()
SET @F=POWER(2,30);