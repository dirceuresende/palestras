IF EXISTS(SELECT NULL FROM sys.symmetric_keys)
	DROP MASTER KEY
GO

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'azurenapratica#!@123'
GO

IF EXISTS(SELECT NULL FROM sys.database_scoped_credentials WHERE [name] = 'usrAzureNaPratica')
	DROP DATABASE SCOPED CREDENTIAL usrAzureNaPratica
GO

CREATE DATABASE SCOPED CREDENTIAL usrAzureNaPratica
WITH
	IDENTITY = 'usrAzureNaPratica', 
	SECRET = 'azurenapratica@123'

	
IF EXISTS(SELECT NULL FROM sys.external_tables WHERE [name] = 'Cargos')
	DROP EXTERNAL TABLE dbo.Cargos
GO

IF EXISTS(SELECT NULL FROM sys.external_data_sources WHERE [name] = 'DbEleicoes')
	DROP EXTERNAL DATA SOURCE DbEleicoes 
GO

-- SQL Server, SQL Database, Azure Synapse Analytics
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/create-external-data-source-transact-sql?view=sql-server-ver15&tabs=dedicated
CREATE EXTERNAL DATA SOURCE DbEleicoes 
WITH (
	TYPE = RDBMS,
	LOCATION = 'eleicoes2022.database.windows.net',
	DATABASE_NAME = 'eleicoes',
	CREDENTIAL = usrAzureNaPratica
)

CREATE EXTERNAL TABLE dbo.Cargos (
	[CD_CARGO] [smallint] NOT NULL,
    [DS_CARGO] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
WITH
(
	DATA_SOURCE = DbEleicoes,
	SCHEMA_NAME = 'dbo',
	OBJECT_NAME = 'Cargos'
);



-- Conecta no banco de origem, onde estão as tabelas
IF EXISTS(SELECT NULL FROM sys.database_principals WHERE [name] = 'usrAzureNaPratica')
	DROP USER usrAzureNaPratica
GO

CREATE USER usrAzureNaPratica WITH PASSWORD = 'azurenapratica@123'
GO

GRANT SELECT ON dbo.Cargos TO [usrAzureNaPratica]
GO


-- Volta ao banco de origem
SELECT * FROM dbo.Cargos


-- Tabela é externa, não física
SELECT [name], is_external, [type_desc] FROM sys.tables


-- Teste JOIN
DROP TABLE IF EXISTS dbo.Candidatos
GO

CREATE TABLE dbo.Candidatos (
    Nome varchar(100),
    Id_Cargo int
)

INSERT INTO dbo.Candidatos
VALUES
    ( 'Dirceu Resende', 1 ),
    ( 'Teste Live', 2 )

SELECT * 
FROM 
    dbo.Candidatos A
    JOIN dbo.Cargos B ON A.Id_Cargo = B.CD_CARGO


-- Erro: Operação não suportada (DML Operations are not supported with external tables.)
INSERT INTO dbo.Cargos ( CD_CARGO, DS_CARGO )
VALUES(99, 'Teste')
