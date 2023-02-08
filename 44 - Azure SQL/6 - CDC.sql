
----------------------------------------------
-- Quais databases estão com o CDC ativo?
----------------------------------------------

SELECT [name], is_cdc_enabled 
FROM sys.databases



----------------------------------------------
-- Quais tabelas estão sendo monitoradas com CDC?
----------------------------------------------

SELECT [name]
FROM sys.tables
WHERE is_tracked_by_cdc = 1

----------------------------------------------
-- Como habilitar o CDC em um database (Nível 1)
----------------------------------------------

EXEC sys.sp_cdc_enable_db 
GO

-- Msg 22830, Level 16, State 1, Procedure sys.sp_cdc_enable_db_internal, Line 274 [Batch Start Line 13]
-- Could not update the metadata that indicates database dirceu is enabled for Change Data Capture. The failure occurred when executing the command 'SetCDCTracked(Value = 1)'. 
-- The error returned was 22871: 'Change Data Capture is not supported on Free, Basic or Standard tier Single Database (S0,S1,S2) and Database in Elastic pool with max eDTUs < 100 or max vCore < 1. 
-- Please upgrade to a higher Service Objective.'. Use the action and error to determine the cause of the failure and resubmit the request.


-- Altera o tier para S3 (suporte para CDC)
ALTER DATABASE [AdventureWorksDW2019] MODIFY(SERVICE_OBJECTIVE = 'S3')

-- Verifica se já alterou
SELECT CONVERT(VARCHAR(100), DATABASEPROPERTYEX( DB_NAME(), 'ServiceObjective' ))


-- Vou tentar ativar o CDC novamente
EXEC sys.sp_cdc_enable_db 
GO


----------------------------------------------
-- Verificando as tabelas criadas pelo CDC
----------------------------------------------

SELECT * FROM cdc.captured_columns
SELECT * FROM cdc.change_tables
SELECT * FROM cdc.ddl_history
SELECT * FROM cdc.index_columns
SELECT * FROM cdc.lsn_time_mapping


----------------------------------------------
-- Como ativar o CDC e monitorar alterações nas tabelas (Nível 2)
----------------------------------------------

EXEC sys.sp_cdc_enable_table 
    @source_schema = N'SalesLT', 
    @source_name   = N'Customer', 
    @role_name     = NULL 
GO


-- Nova tabela criada: cdc.SalesLT_Customer_CT
SELECT * FROM cdc.SalesLT_Customer_CT


-- Caso você queira monitorar as alterações em colunas específicas, e não em todas as colunas da tabela, você pode utilizar essa sintaxe
EXEC sys.sp_cdc_enable_table 
    @source_schema = N'SalesLT', 
    @source_name   = N'Customer', 
    @role_name     = NULL,
    @captured_column_list = '[Title], [FirstName], [LastName], [EmailAddress], [Phone]'
GO


----------------------------------------------
-- Inserindo dados para testar
----------------------------------------------

INSERT INTO SalesLT.Customer ([NameStyle], [Title], [FirstName], [MiddleName], [LastName], [Suffix], [CompanyName], [SalesPerson], [EmailAddress], [Phone], [PasswordHash], [PasswordSalt], [rowguid], [ModifiedDate])
VALUES
( 0, N'Mr.', N'Dirceu', N'N.', N'Resende', NULL, N'A Bike Store', N'adventure-works\pamela0', N'orlando0@adventure-works.com', N'245-555-0173', 'L/Rlwxzp4w7RWmEgXX+/A7cXaePEPcp+KwQhl2fJL7w=', '1KjXYs4=', NEWID(), GETDATE() ),
( 0, N'Mr.', N'Teste', NULL, N'CDC', NULL, N'Progressive Sports', N'adventure-works\david8', N'keith0@adventure-works.com', N'170-555-0127', 'YPdtRdvqeAhj6wyxEsFdshBDNXxkCXn+CRgbvJItknw=', 'fs1ZGhY=', NEWID(), GETDATE() )


-- Atualizando dados para testar
UPDATE SalesLT.Customer
SET 
    FirstName = 'Teste',
    LastName = 'Deu Certo'
WHERE
    LastName = 'CDC'


DELETE FROM SalesLT.Customer
WHERE LastName = 'Deu Certo'


----------------------------------------------
-- Visualizando os dados coletados pelo CDC
----------------------------------------------

SELECT 
    (CASE [__$operation] 
        WHEN 1 THEN '1 - DELETE'
        WHEN 2 THEN '2 - INSERT'
        WHEN 3 THEN '3 - UPDATE (Valor ANTES)'
        WHEN 4 THEN '4 - UPDATE (Valor DEPOIS)'
    END) AS Operacao,
    sys.fn_cdc_map_lsn_to_time([__$start_lsn]) AS Dt_Operacao,
    * 
FROM
    cdc.SalesLT_Customer_CT
ORDER BY
    [__$start_lsn]



-- Não pode mais truncar a tabela após ativar o CDC
TRUNCATE TABLE SalesLT.Customer


----------------------------------------------
-- Como configurar a retenção de dados do CDC?
----------------------------------------------

EXEC sp_cdc_change_job 
    @job_type='cleanup', 
    @retention=10080 -- 7 dias (quantidade de minutos de retenção)


-- Para visualizar os parâmetros atuais de retenção, utilize a consulta abaixo:
SELECT 
    [retention],
    ([retention]) / ((60 * 24)) AS RetentionInDays,
    *
FROM
    cdc.cdc_jobs;



----------------------------------------------
-- Como desativar o CDC em uma tabela
----------------------------------------------

EXEC sys.sp_cdc_help_change_data_capture
GO

SELECT OBJECT_NAME([object_id]), OBJECT_NAME(source_object_id), capture_instance
FROM cdc.change_tables


EXEC sys.sp_cdc_disable_table
    @source_schema = 'SalesLT', -- sysname
    @source_name = 'Customer', -- sysname
    @capture_instance = 'SalesLT_Customer' -- sysname


-- A tabela de histórico é apagada quando desativa o CDC na tabela
SELECT * FROM cdc.SalesLT_Customer_CT

-- DELETE FROM SalesLT.Customer WHERE CustomerID > 30118


----------------------------------------------
-- Como desativar o CDC na base toda
----------------------------------------------

-- CUIDADO: TODAS as tabelas de histórico do CDC serão APAGADAS.
EXEC sys.sp_cdc_disable_db
GO


----------------------------------------------
-- Change Data Capture (CDC) e operações de Backup/Restore
----------------------------------------------

-- Após restaurar o banco como outro nome ou em outra instância, executar os comandos abaixo para manter o CDC ativo:

exec sys.sp_cdc_add_job 'capture'
GO
 
exec sys.sp_cdc_add_job 'cleanup'
GO

