
-- Referências: https://www.nikoport.com/columnstore/


/*

SELECT * 
INTO dbo.FactInternetSales
FROM AdventureWorksDW2019.dbo.FactInternetSales


INSERT INTO dbo.FactInternetSales
SELECT * FROM dbo.FactInternetSales
GO 7


SELECT * 
INTO dbo.FactInternetSales_Clustered_Rowstore
FROM dbo.FactInternetSales

SELECT * 
INTO dbo.FactInternetSales_Clustered_Columnstore
FROM dbo.FactInternetSales


CREATE CLUSTERED INDEX SK01_Clustered_Rowstore ON dbo.FactInternetSales_Clustered_Rowstore(ProductKey, OrderDate) WITH(DATA_COMPRESSION=PAGE)
CREATE CLUSTERED COLUMNSTORE INDEX SK01_Clustered_Columnstore ON dbo.FactInternetSales_Clustered_Columnstore


*/


CREATE TABLE dbo.Teste_Columnstore (
    Id INT,
    Nome VARCHAR(100)
)

INSERT INTO dbo.Teste_Columnstore
SELECT * FROM dbo.Teste_Columnstore
GO 2

SELECT * INTO dbo.Teste_Columnstore2
FROM dbo.Teste_Columnstore

INSERT INTO dbo.Teste_Columnstore2
SELECT * FROM dbo.Teste_Columnstore2
GO 2

SELECT SUM(Id) FROM Teste_Columnstore2

/*

Table 'Teste_Columnstore2'. Scan count 5, logical reads 24106, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 797 ms,  elapsed time = 198 ms.

*/



SELECT * FROM Teste_Columnstore WHERE Nome = 'Groffe'

SELECT * FROM AdventureWorksDW2019.dbo.FactInternetSales WHERE ProductKey = 310

DROP INDEX [Teste] ON dbo.FactInternetSales

CREATE NONCLUSTERED INDEX [Teste] ON [dbo].[FactInternetSales] ([ProductKey]) INCLUDE(CustomerKey, SalesOrderNumber)
GO

CREATE NONCLUSTERED INDEX ProductKey ON AdventureWorksDW2019.dbo.FactInternetSales(ProductKey)

/*

Table 'Teste_Columnstore'. Scan count 1, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 48, lob physical reads 6, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Teste_Columnstore'. Segment reads 9, segment skipped 0.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 6 ms.

*/


sp_spaceused 'Teste_Columnstore'
sp_spaceused 'Teste_Columnstore2'

Teste_Columnstore	        8388608             114.904 KB	113312 KB	592 KB	1000 KB
Teste_Columnstore	        8388608             	392 KB	56 KB	    0 KB	336 KB

Teste_Columnstore	        4194304             96.456 KB	96.424 KB	8 KB	24 KB
Teste_Columnstore	        4194304                392 KB	56 KB	    0 KB	336 KB

CREATE CLUSTERED COLUMNSTORE INDEX SK01_Teste_Columnstore ON dbo.Teste_Columnstore




name	                                rows	    reserved	    data	        index_size	    unused
FactInternetSales	                    7730944     1.262.472 KB	1.262.200 KB	8 KB	        264 KB
FactInternetSales_Clustered_Rowstore	7730944     192.112 KB	    191.288 KB	    616 KB	        208 KB
FactInternetSales_Clustered_Columnstore	7730944     107.656 KB	    107.400 KB	    0 KB	        256 KB


sp_spaceused 'dbo.FactInternetSales'
GO

sp_spaceused 'dbo.FactInternetSales_Clustered_Rowstore'
GO

sp_spaceused 'dbo.FactInternetSales_Clustered_Columnstore'
GO




/*

name										rows			reserved		data			index_size		unused
FactInternetSales							7730944         1262408 KB		1262200 KB		8 KB			200 KB
FactInternetSales_Clustered_Rowstore		7730944         191960 KB		191328 KB		504 KB			128 KB
FactInternetSales_Clustered_Columnstore		7730944         107272 KB		107136 KB		0 KB			136 KB

*/

SET STATISTICS TIME, IO ON
GO


-- ROWSTORE

SELECT SUM(OrderQuantity * UnitPrice)
FROM dbo.FactInternetSales_Clustered_Rowstore

/*

(1 row affected)
Table 'FactInternetSales_Clustered_Rowstore'. Scan count 5, logical reads 24261, physical reads 0, page server reads 0, read-ahead reads 14, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 1532 ms,  elapsed time = 391 ms.

*/


SELECT SUM(OrderQuantity * UnitPrice)
FROM dbo.FactInternetSales_Clustered_Rowstore
WHERE OrderDate = '2013-07-08'

/*
Table 'FactInternetSales_Clustered_Rowstore'. Scan count 5, logical reads 24261, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 797 ms,  elapsed time = 205 ms.
*/


SELECT SUM(OrderQuantity * UnitPrice)
FROM dbo.FactInternetSales_Clustered_Rowstore
WHERE ProductKey = 537


/*

(1 row affected)
Table 'FactInternetSales_Clustered_Rowstore'. Scan count 1, logical reads 551, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 47 ms,  elapsed time = 49 ms.

*/


SELECT SUM(OrderQuantity * UnitPrice)
FROM dbo.FactInternetSales_Clustered_Rowstore
WHERE OrderDate = '2013-07-08'
AND ProductKey = 537


SELECT * 
FROM dbo.FactInternetSales_Clustered_Rowstore
WHERE OrderDate = '2013-07-08'
AND ProductKey = 537




-- COLUMNSTORE

SELECT SUM(OrderQuantity * UnitPrice)
FROM dbo.FactInternetSales_Clustered_Columnstore



SELECT SUM(OrderQuantity * UnitPrice)
FROM dbo.FactInternetSales_Clustered_Columnstore
WHERE OrderDate = '2013-07-08'

/*

SQL Server Execution Times:
   CPU time = 16 ms,  elapsed time = 84 ms.

*/


SELECT SUM(OrderQuantity * UnitPrice)
FROM dbo.FactInternetSales_Clustered_Columnstore
WHERE ProductKey = 537

/*

SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 146 ms.

*/
 

SELECT SUM(OrderQuantity * UnitPrice)
FROM dbo.FactInternetSales_Clustered_Columnstore
WHERE OrderDate = '2013-07-08'
AND ProductKey = 537



SELECT * 
FROM dbo.FactInternetSales_Clustered_Columnstore
WHERE OrderDate = '2013-07-08'
AND ProductKey = 537



SET STATISTICS TIME, IO OFF

-- COLUMNSTORE COMPACTA BEM

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





-- COLUMNSTORE COMPACTA MAL

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



sp_spaceused 'dbo.TabelaNumero'
GO

sp_spaceused 'dbo.TabelaTexto'
GO

sp_spaceused 'dbo.TabelaTexto2'
GO

-- VARCHAR VS INT FAZ DIFERENÇA?

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


   
   