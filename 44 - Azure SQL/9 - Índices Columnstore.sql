
-- Altera o tier para S3 (suporte para columnstore)
ALTER DATABASE [AdventureWorksDW2019] MODIFY(SERVICE_OBJECTIVE = 'S3')

-- Verifica se já alterou
SELECT CONVERT(VARCHAR(100), DATABASEPROPERTYEX( DB_NAME(), 'ServiceObjective' ))


/*

DROP TABLE IF EXISTS dbo.FactInternetSales
GO

CREATE TABLE [dbo].[FactInternetSales]
(
[SalesOrderID] [int] NOT NULL,
[SalesOrderDetailID] [int] NOT NULL,
[OrderQty] [smallint] NOT NULL,
[ProductID] [int] NOT NULL,
[UnitPrice] [money] NOT NULL,
[UnitPriceDiscount] [money] NOT NULL,
[LineTotal] [numeric] (38, 6) NOT NULL,
[rowguid] [uniqueidentifier] NOT NULL,
[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]
GO


INSERT INTO dbo.FactInternetSales
SELECT * FROM SalesLT.SalesOrderDetail


INSERT INTO dbo.FactInternetSales
SELECT * FROM dbo.FactInternetSales
GO 13


SELECT * 
INTO dbo.FactInternetSales_Clustered_Rowstore
FROM dbo.FactInternetSales

SELECT * 
INTO dbo.FactInternetSales_Clustered_Columnstore
FROM dbo.FactInternetSales


CREATE CLUSTERED INDEX SK01_Clustered_Rowstore ON dbo.FactInternetSales_Clustered_Rowstore(SalesOrderDetailID) WITH(DATA_COMPRESSION=PAGE)
CREATE CLUSTERED COLUMNSTORE INDEX SK01_Clustered_Columnstore ON dbo.FactInternetSales_Clustered_Columnstore


*/


sp_spaceused 'dbo.FactInternetSales'
GO

sp_spaceused 'dbo.FactInternetSales_Clustered_Rowstore'
GO

sp_spaceused 'dbo.FactInternetSales_Clustered_Columnstore'
GO

/*

name										rows			reserved		data			index_size		unused
FactInternetSales	                        4440064         417992 KB	    417896 KB	      8 KB	         88 KB
FactInternetSales_Clustered_Rowstore	    4440064          49288 KB	     49096 KB	    120 KB	         72 KB
FactInternetSales_Clustered_Columnstore	    4440064            328 KB	       216 KB	      0 KB	        112 KB

*/

SET STATISTICS TIME, IO ON
GO


-- ROWSTORE

SELECT SUM(OrderQty * UnitPrice)
FROM dbo.FactInternetSales_Clustered_Rowstore

SELECT SUM(OrderQty * UnitPrice)
FROM dbo.FactInternetSales_Clustered_Rowstore
WHERE SalesOrderDetailID = 110562


-- COLUMNSTORE

SELECT SUM(OrderQty * UnitPrice)
FROM dbo.FactInternetSales_Clustered_Columnstore

SELECT SUM(OrderQty * UnitPrice)
FROM dbo.FactInternetSales_Clustered_Columnstore
WHERE SalesOrderDetailID = 110562



SET STATISTICS TIME, IO OFF


-------------------------------------------
-- COLUMNSTORE COMPACTA BEM
-------------------------------------------

/*

IF (OBJECT_ID('dbo.ColumnStoreExemploBom') IS NOT NULL) DROP TABLE dbo.ColumnStoreExemploBom
CREATE TABLE dbo.ColumnStoreExemploBom (
	Id INT IDENTITY(1,1),
	Coluna1 VARCHAR(100)
)
GO

INSERT INTO dbo.ColumnStoreExemploBom(Coluna1)
SELECT [name]
FROM sys.columns
GO 1000

IF (OBJECT_ID('dbo.ColumnStoreExemploBom_CS') IS NOT NULL) DROP TABLE dbo.ColumnStoreExemploBom_CS
SELECT Coluna1 INTO ColumnStoreExemploBom_CS
FROM dbo.ColumnStoreExemploBom

IF (OBJECT_ID('dbo.ColumnStoreExemploBom_RS') IS NOT NULL) DROP TABLE dbo.ColumnStoreExemploBom_RS
SELECT Coluna1 INTO ColumnStoreExemploBom_RS
FROM dbo.ColumnStoreExemploBom

CREATE CLUSTERED COLUMNSTORE INDEX SK01_Columnstore ON dbo.ColumnStoreExemploBom_CS
CREATE CLUSTERED INDEX SK01_Rowstore ON dbo.ColumnStoreExemploBom_RS(Coluna1) WITH(DATA_COMPRESSION=PAGE)

*/

sp_spaceused 'dbo.ColumnStoreExemploBom'
GO

sp_spaceused 'dbo.ColumnStoreExemploBom_RS'
GO

sp_spaceused 'dbo.ColumnStoreExemploBom_CS'
GO

SELECT * FROM dbo.ColumnStoreExemploBom_RS WHERE Coluna1 = 'connecttimeout'



SELECT * FROM dbo.ColumnStoreExemploBom_RS WHERE Coluna1 LIKE 'co%'



SELECT MAX(Coluna1) FROM dbo.ColumnStoreExemploBom_RS



SELECT COUNT(*) FROM dbo.ColumnStoreExemploBom_RS



SELECT * FROM dbo.ColumnStoreExemploBom_CS WHERE Coluna1 = 'connecttimeout'



SELECT * FROM dbo.ColumnStoreExemploBom_CS WHERE Coluna1 LIKE 'co%'



SELECT MAX(Coluna1) FROM dbo.ColumnStoreExemploBom_CS



SELECT COUNT(*) FROM dbo.ColumnStoreExemploBom_CS




-------------------------------------------
-- COLUMNSTORE COMPACTA MAL
-------------------------------------------


/*

IF (OBJECT_ID('dbo.ColumnStoreExemploRuim') IS NOT NULL) DROP TABLE dbo.ColumnStoreExemploRuim
CREATE TABLE dbo.ColumnStoreExemploRuim (
	Coluna1 VARCHAR(100)
)
GO

INSERT INTO dbo.ColumnStoreExemploRuim(Coluna1)
SELECT NEWID()
FROM sys.columns
GO 1000

IF (OBJECT_ID('dbo.ColumnStoreExemploRuim_CS') IS NOT NULL) DROP TABLE dbo.ColumnStoreExemploRuim_CS
SELECT Coluna1 INTO ColumnStoreExemploRuim_CS
FROM dbo.ColumnStoreExemploRuim

IF (OBJECT_ID('dbo.ColumnStoreExemploRuim_RS') IS NOT NULL) DROP TABLE dbo.ColumnStoreExemploRuim_RS
SELECT Coluna1 INTO ColumnStoreExemploRuim_RS
FROM dbo.ColumnStoreExemploRuim

CREATE CLUSTERED COLUMNSTORE INDEX SK01_ColumnStoreExemploRuim_Columnstore ON dbo.ColumnStoreExemploRuim_CS
CREATE CLUSTERED INDEX SK01_ColumnStoreExemploRuim_Rowstore ON dbo.ColumnStoreExemploRuim_RS(Coluna1) WITH(DATA_COMPRESSION=PAGE)

*/


sp_spaceused 'dbo.ColumnStoreExemploRuim'
GO

sp_spaceused 'dbo.ColumnStoreExemploRuim_RS'
GO

sp_spaceused 'dbo.ColumnStoreExemploRuim_CS'
GO




SELECT * FROM dbo.ColumnStoreExemploRuim_RS WHERE Coluna1 = '3FA1B7A4-F1C0-42FF-A34A-763D0C1E509C'


SELECT * FROM dbo.ColumnStoreExemploRuim_RS WHERE Coluna1 LIKE '3F%'


SELECT MAX(Coluna1) FROM dbo.ColumnStoreExemploRuim_RS


SELECT COUNT(*) FROM dbo.ColumnStoreExemploRuim_RS


SELECT * FROM dbo.ColumnStoreExemploRuim_CS WHERE Coluna1 = '3FA1B7A4-F1C0-42FF-A34A-763D0C1E509C'
SELECT * FROM dbo.ColumnStoreExemploRuim_CS WHERE Coluna1 LIKE '3F%'
SELECT MAX(Coluna1) FROM dbo.ColumnStoreExemploRuim_CS


SELECT COUNT(*) FROM dbo.ColumnStoreExemploRuim_CS


-------------------------------------------
-- VARCHAR VS INT FAZ DIFERENÇA?
-------------------------------------------

/*

IF (OBJECT_ID('dbo.TabelaNumero') IS NOT NULL) DROP TABLE dbo.TabelaNumero
CREATE TABLE dbo.TabelaNumero (
	Coluna1 INT NOT NULL
)
GO

IF (OBJECT_ID('dbo.TabelaTexto') IS NOT NULL) DROP TABLE dbo.TabelaTexto
CREATE TABLE dbo.TabelaTexto (
	Coluna1 VARCHAR(100)
)

IF (OBJECT_ID('dbo.TabelaTexto2') IS NOT NULL) DROP TABLE dbo.TabelaTexto2
CREATE TABLE dbo.TabelaTexto2 (
	Coluna1 VARCHAR(100)
)

INSERT INTO dbo.TabelaNumero(Coluna1)
SELECT database_id
FROM sys.databases
GO 10000


INSERT INTO dbo.TabelaTexto(Coluna1)
SELECT CONCAT([name], ' | ', collation_name + ' | ' + user_access_desc + ' | ' + state_desc)
FROM sys.databases
GO 10000


INSERT INTO dbo.TabelaTexto2(Coluna1)
SELECT [name]
FROM sys.databases
GO 10000




CREATE CLUSTERED COLUMNSTORE INDEX SK01_TabelaTexto ON dbo.TabelaTexto
CREATE CLUSTERED COLUMNSTORE INDEX SK01_TabelaTexto2 ON dbo.TabelaTexto2
CREATE CLUSTERED COLUMNSTORE INDEX SK01_TabelaNumero ON dbo.TabelaNumero

*/



sp_spaceused 'dbo.TabelaNumero'
GO

sp_spaceused 'dbo.TabelaTexto'
GO

sp_spaceused 'dbo.TabelaTexto2'
GO



SELECT * FROM dbo.TabelaTexto WHERE Coluna1 = 'master'


SELECT * FROM dbo.TabelaNumero WHERE Coluna1 = 7


SELECT COUNT(*) FROM dbo.TabelaTexto2 WHERE Coluna1 = 'master'


SELECT COUNT(*) FROM dbo.TabelaNumero WHERE Coluna1 = 7


SELECT MAX(Coluna1) FROM dbo.TabelaTexto


SELECT MAX(Coluna1) FROM dbo.TabelaNumero




SELECT *
FROM dbo.TabelaTexto2 A
WHERE Coluna1 = 'master'



SELECT *
FROM dbo.TabelaNumero A
JOIN sys.databases B ON A.[Coluna1] = B.database_id
WHERE B.[name] = 'master'


   
