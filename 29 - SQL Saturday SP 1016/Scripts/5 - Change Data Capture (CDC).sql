----------------------------------------------
-- Quais databases estão com o CDC ativo?
----------------------------------------------

SELECT [name]
FROM sys.databases
WHERE is_cdc_enabled = 1



----------------------------------------------
-- Quais tabelas estão sendo monitoradas com CDC?
----------------------------------------------

SELECT [name]
FROM sys.tables
WHERE is_tracked_by_cdc = 1



----------------------------------------------
-- Como habilitar o CDC em um database (Nível 1)
----------------------------------------------

USE dirceuresende 
GO

EXEC sys.sp_cdc_enable_db 
GO


-- Novo schema criado
SELECT SCHEMA_ID('cdc')


-- Novas tabelas internas criadas
SELECT *
FROM sys.tables
WHERE [schema_id] = SCHEMA_ID('cdc')


-- Consultando as novas tabelas
SELECT * FROM cdc.change_tables
SELECT * FROM cdc.captured_columns
SELECT * FROM cdc.ddl_history
SELECT * FROM cdc.index_columns
SELECT * FROM cdc.lsn_time_mapping


----------------------------------------------
-- Como ativar o CDC e monitorar alterações nas tabelas (Nível 2)
----------------------------------------------

USE [dirceuresende]
GO 

IF (OBJECT_ID('dbo.Clientes') IS NOT NULL) DROP TABLE dbo.Clientes
CREATE TABLE dbo.Clientes (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
    Nome VARCHAR(100),
    Teste VARCHAR(50)
) WITH(DATA_COMPRESSION=PAGE)

EXEC sys.sp_cdc_enable_table 
    @source_schema = N'dbo', 
    @source_name   = N'Clientes', 
    @role_name     = NULL 
GO


-- Caso você queira monitorar as alterações em colunas específicas
EXEC sys.sp_cdc_enable_table 
    @source_schema = N'dbo', 
    @source_name   = N'Clientes', 
    @role_name     = NULL,
    @captured_column_list = '[Id], [Nome], [Teste]'
GO

/*

cdc.dirceuresende_capture: Job que é executado sempre que o SQL Server Agent é iniciado e executa a SP 
de sistema sys.sp_MScdc_capture_job, que por sua vez, executa a SP sys.sp_cdc_scan, iniciando o 
monitoramento da tabela.

cdc.dirceuresende_cleanup: Job que é executado diariamente às 02:00 e tem a finalidade de controlar o tamanho 
das tabelas de controle do CDC, para evitar que elas cresçam descontroladamente. Esse job executa a SP de 
sistema sys.sp_MScdc_cleanup_job, que por sua vez, executa a SP sys.sp_cdc_cleanup_job_internal.

*/

----------------------------------------------
-- Consultando as alterações nas tabelas
----------------------------------------------

SELECT * FROM cdc.dbo_Clientes_CT


INSERT INTO dbo.Clientes (Nome)
VALUES('Dirceu Resende'), ('Jéssica Lima'), ('Teste 1'), ('Teste 2'), ('Teste 3')

SELECT * FROM cdc.dbo_Clientes_CT



UPDATE dbo.Clientes
SET Nome = 'Teste CDC'
WHERE Nome = 'Teste 1'

UPDATE dbo.Clientes
SET Nome = 'Teste CDC 2'
WHERE Nome = 'Teste 2'

SELECT * FROM cdc.dbo_Clientes_CT



DELETE FROM cdc.dbo_Clientes_CT WHERE Nome = 'Teste CDC 2'

SELECT * FROM cdc.dbo_Clientes_CT



TRUNCATE TABLE dbo.Clientes



----------------------------------------------
-- Como desativar o CDC em um database (Nível 1)
----------------------------------------------

USE [dirceuresende]
GO

EXEC sys.sp_cdc_disable_db
GO


/* 

Vale lembrar que ao desativar o CDC a nível de database, TODOS os monitoramentos ativos do CDC a 
nível de tabela também serão desativados e os dados de histórico serão todos perdidos também 
(e você NÃO será alertado sobre a existência desses monitoramentos ativos a nível de tabela).

*/


----------------------------------------------
-- Como desativar o CDC em uma tabela (Nível 2)
----------------------------------------------

/*

Para desativar o CDC de uma tabela específica, você precisará primeiro identificar o nome da instância de 
captura do CDC, utilizando a SP sys.sp_cdc_help_change_data_capture ou consultando a cdc.change_tables, 
para depois desativar o monitoramento com a SP sys.sp_cdc_disable_table.

Vale lembrar que é possível desativar o CDC a nível de database, mesmo que existam monitoramentos ativos a 
nível de tabela (e você NÃO será alertado sobre a existência disso). No final desse tópico eu deixei alguns 
alertas sobre o que acontece quando você faz isso.. Leia até o final!

*/

USE [dirceuresende]
GO

EXEC sys.sp_cdc_help_change_data_capture
GO

SELECT OBJECT_NAME([object_id]), OBJECT_NAME(source_object_id), capture_instance
FROM cdc.change_tables


-- Uma vez que identificamos o nome da instância (dbo_Clientes), agora podemos executar 
-- a sys.sp_cdc_disable_table
USE [dirceuresende]
GO

EXEC sys.sp_cdc_disable_table
    @source_schema = 'dbo', -- sysname
    @source_name = 'Clientes', -- sysname
    @capture_instance = 'dbo_Clientes' -- sysname


/*

Após desativar o CDC na tabela, vocês podem observar que a tabela de monitoramento foi excluída automaticamente. 
MUITO CUIDADO com isso, para não perder os valores gravados e perder o seu histórico. Caso você queira 
desativar o CDC, mas não tem a intenção de perder o histórico, copie os dados da tabela de histórico para 
outra tabela antes de desativar o CDC na tabela.

*/

----------------------------------------------
-- Change Data Capture (CDC) e operações de Backup/Restore
----------------------------------------------

/*

Restaurando o mesmo database, na mesma instância
-------------------------------------------------------------------------------------------------------------
Nessa situação, o restore será feito normalmente e o CDC continuá ativo e funcionando após a base ser restaurada. 
Nada muda.


Restaurando o backup na mesma instância, mas com outro nome de database ou em outra instância
-------------------------------------------------------------------------------------------------------------
Nesses dois casos, o CDC será desativado e as informações de metadados gravadas serão perdidas, o que seria 
algo bem ruim. Para que isso não aconteça, você deverá utilizar o parâmetro keep_cdc no comando de restore.

*/

-- Exemplo

RESTORE DATABASE 
    [dirceuresende]
FROM 
    DISK = 'C:\Backups\dirceuresende.bak' 
WITH 
    MOVE 'dirceuresende_dados' TO 'C:\Dados\dirceuresende_dados.mdf',
    MOVE 'dirceuresende_log' TO 'C:\Dados\dirceuresende_log.ldf', 
    KEEP_CDC


-- Após o restore, você precisará executar os comandos abaixo para recriar os jobs do CDC:

USE [dirceuresende]
GO

exec sys.sp_cdc_add_job 'capture'
GO

exec sys.sp_cdc_add_job 'cleanup'
GO
