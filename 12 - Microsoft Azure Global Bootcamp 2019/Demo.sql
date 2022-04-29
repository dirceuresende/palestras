
-- CRIA A BASE DE TESTE
USE [master]
GO

CREATE DATABASE [gwab2019_dirceu]
GO

ALTER DATABASE [gwab2019_dirceu] SET RECOVERY FULL WITH NO_WAIT
GO

USE [gwab2019_dirceu]
GO
execute dbo.sp_changedbowner @loginame = N'sa'
GO

-- Ativa o CDC
execute sys.sp_cdc_enable_db
GO
 


-- CRIA A TABELA QUE SERÁ MONITORADA
IF (OBJECT_ID('dbo.Vendas') IS NOT NULL) DROP TABLE dbo.Vendas
CREATE TABLE [dbo].[Vendas] (
	Id_Pedido INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	Dt_Pedido DATETIME NOT NULL,
	Quantidade INT NOT NULL,
	Valor NUMERIC(18, 2),
	Total_Pedido NUMERIC(18, 2)
) WITH(DATA_COMPRESSION=PAGE)
GO
 

-- https://www.dirceuresende.com/blog/sql-server-como-monitorar-e-auditar-alteracoes-de-dados-em-tabelas-utilizando-change-data-capture-cdc/
-- Ativa o CDC
-- ### GARANTIR QUE O SQL AGENT ESTÁ RODANDO ###
-- EXEC sys.sp_cdc_enable_db
execute sys.sp_cdc_enable_table @source_schema = 'dbo', @source_name = 'Vendas', @role_name = 'cdc_reader'
GO

/*

EXEC sys.sp_cdc_disable_db

EXEC sys.sp_cdc_disable_table
    @source_schema = 'dbo', -- sysname
    @source_name = 'Vendas', -- sysname
    @capture_instance = 'dbo_Vendas' -- sysname


EXEC sys.sp_cdc_help_change_data_capture

*/


-- Essa ação criou a tabela de sistema para realizar o tracking [cdc].[dbo_Vendas_CT]
-- Essa ação vai criar e inicialiar os jobs do SQL Agent:
-- (1) cdc.gwab2019_dirceu_capture --> Lê a transaction log, identifica as operações de DML e copia dados alterados para a tabela [cdc].[dbo_Vendas_CT]
-- (2) cdc.gwab2019_dirceu_cleanup --> Apaga os dados em [cdc].[dbo_Vendas_CT] mais antigos que 72 horas (default)

 
-- Cria uma tabela de controle para gerenciar os dados já enviados para o Azure
CREATE TABLE [dbo].[SQL2AEH_TableOffset]
(
 [TableName] [varchar](250) NOT NULL,
 [LastMaxVal] [binary](10) NOT NULL,
 [LastUpdateDateTime] [datetime] NOT NULL DEFAULT getdate(),
 [LastCheckedDateTime] [datetime] NOT NULL DEFAULT getdate(),
 CONSTRAINT [PK_SQL2AEH_TableOffset_1] PRIMARY KEY NONCLUSTERED 
 (
 [TableName] ASC
 ) 
) 
GO
 
-- Enviando posição inicial gerada pelo tracking
insert into [dbo].[SQL2AEH_TableOffset] select 'dbo.Vendas', 0x00000000000000000000, '1900-01-01 00:00:00', '1900-01-01 00:00:00'
GO




-----------------------------------------------------------
-- Gera alguns dados de teste
-----------------------------------------------------------

insert into [dbo].[Vendas]
(
    [Dt_Pedido],
    [Quantidade],
    [Valor]
)
select '2017-07-10 15:00:00', 1, 550
union
select '2017-07-10 18:00:00', 2, 650
union
select '2017-07-10 21:00:00', 3, 750
GO


-- Consulta os dados
SELECT * FROM [dbo].[Vendas]
SELECT * FROM [dbo].[SQL2AEH_TableOffset]
SELECT * FROM cdc.dbo_Vendas_CT ORDER BY [__$start_lsn] DESC

-- Cria uma função para gerar dados aleatórios
IF (OBJECT_ID('dbo.fncRand') IS NOT NULL) DROP FUNCTION dbo.fncRand
GO
 
CREATE FUNCTION dbo.fncRand(@Numero BIGINT)
RETURNS BIGINT
AS
BEGIN
    RETURN (ABS(CHECKSUM(PWDENCRYPT(N''))) / 2147483647.0) * @Numero
END
GO


-- Fica inserindo os dados em tempo real, simulando transações
WHILE(1=1)
BEGIN


	;WITH dados AS (
		SELECT 
			GETDATE() AS Dt_Pedido, 
			1 + dbo.fncRand(20) AS Quantidade,
			0.97 * dbo.fncRand(500) AS Valor
	)
	INSERT INTO [dbo].[Vendas]
	(
		[Dt_Pedido],
		[Quantidade],
		[Valor],
		Total_Pedido
	)
	SELECT 
		A.Dt_Pedido,
        A.Quantidade,
        A.Valor,
		A.Quantidade * A.Valor
	FROM 
		dados A
	
	
	WAITFOR DELAY '00:00:00.200'


END

