USE [WideWorldImportersDW]
GO

ALTER DATABASE WideWorldImportersDW SET COMPATIBILITY_LEVEL = 140 -- SQL Server 2017
GO


SET STATISTICS TIME ON
SET STATISTICS IO ON

SELECT [Lineage Key],
       SUM([Quantity])                                 AS SUM_QTY,
       SUM([Unit Price])                        AS SUM_BASE_PRICE,
       SUM([Unit Price]*(1+[Tax Rate]))         AS SUM_DISC_PRICE,
       SUM(([Unit Price]+[Total Including Tax] )*(1+[Tax Rate]))     AS SUM_CHARGE,
       AVG([Quantity])                                 AS AVG_QTY,
       AVG([Unit Price])                        AS AVG_PRICE,
       COUNT(*)                                 AS COUNT_ORDER
FROM   Fact.[Sale]
WHERE  [Invoice Date Key]   >= DATEADD(dd, -73, '1998-12-01')
GROUP  BY     [Lineage Key]
ORDER  BY     [Lineage Key];


/*

SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
SQL Server parse and compile time: 
   CPU time = 6 ms, elapsed time = 6 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.

(1 row affected)
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Sale'. Scan count 7, logical reads 2146, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

(1 row affected)

 SQL Server Execution Times:
   CPU time = 375 ms,  elapsed time = 373 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.

*/



ALTER DATABASE WideWorldImportersDW SET COMPATIBILITY_LEVEL = 150 -- SQL Server 2019
GO


SELECT [Lineage Key],
       SUM([Quantity])                                 AS SUM_QTY,
       SUM([Unit Price])                        AS SUM_BASE_PRICE,
       SUM([Unit Price]*(1+[Tax Rate]))         AS SUM_DISC_PRICE,
       SUM(([Unit Price]+[Total Including Tax] )*(1+[Tax Rate]))     AS SUM_CHARGE,
       AVG([Quantity])                                 AS AVG_QTY,
       AVG([Unit Price])                        AS AVG_PRICE,
       COUNT(*)                                 AS COUNT_ORDER
FROM   Fact.[Sale]
WHERE  [Invoice Date Key]   >= DATEADD(dd, -73, '1998-12-01')
GROUP  BY     [Lineage Key]
ORDER  BY     [Lineage Key];


/*

SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

(1 row affected)
Table 'Sale'. Scan count 7, logical reads 2146, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

(1 row affected)

 SQL Server Execution Times:
   CPU time = 187 ms,  elapsed time = 184 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.

*/

