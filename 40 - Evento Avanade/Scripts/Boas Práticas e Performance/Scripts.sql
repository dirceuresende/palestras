
-------------------------------------------
-- Apresentação
-------------------------------------------

SET NOCOUNT ON

PRINT CONVERT(VARCHAR(MAX), 0x2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D0A2D2D2044697263657520526573656E64650A2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D0A0A2D3E204F66696369616C2064652044617461206E6F2043617269626265616E20446576656C6F706D656E742042616E6B0A2D3E20496E73747275746F72206520436F6E73756C746F7220646520506F776572204249206E6F20506C616E696C686569726F730A2D3E20496E73747275746F7220646F20637572736F732E706F77657274756E696E672E636F6D2E62720A2D3E204175746F7220646F20626C6F6720646972636575726573656E64652E636F6D0A2D3E204D6963726F736F6674204D5650204461746120506C6174666F726D20646573646520323031380A2D3E204D6963726F736F6674204D43502C204D54412C204D4353412C204D43542065204D4353450A2D3E204F7267616E697A61646F7220646F2050415353204C6F63616C2047726F75702053514C205365727665722045530A2D3E204F7267616E697A61646F7220646F20486170707920486F757220636F6D204461646F730A2D3E204573637269746F7220646F20694D6173746572730A2D3E204573637269746F7220646F20636F6469676F73696D706C65732E6E65740A2D3E20486F62626965733A20566964656F67616D652C204E6574666C69782C2046757465626F6C2C205546432C20416E696D65732C20596F75547562650A0A2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D0A0A4769746875623A2068747470733A2F2F6769746875622E636F6D2F646972636575726573656E64650A54656C656772616D3A2040646972636575726573656E64650A536B7970653A2040646972636575726573656E64650A4C696E6B6564496E3A202F696E2F646972636575726573656E64652F0A)


-------------------------------------------
-- Quebrar consultas muito grandes
-------------------------------------------

USE [AdventureWorksDW2017]
GO

SELECT A.ProductKey,  A.OrderDateKey, A.SalesOrderNumber, A.OrderQuantity, A.SalesAmount, A.ExtendedAmount, A.UnitPrice, A.UnitPriceDiscountPct, A.RevisionNumber
FROM dbo.FactInternetSales A
JOIN dbo.DimDate B
	ON B.DateKey = A.DueDateKey
JOIN dbo.DimCustomer C
	ON C.CustomerKey = A.CustomerKey
JOIN (SELECT MAX(DateKey) AS MaxDate FROM dbo.DimDate JOIN dbo.FactInternetSales 
	ON FactInternetSales.OrderDateKey = DimDate.DateKey
	WHERE FullDateAlternateKey >= '2010-01-01'
	AND FullDateAlternateKey < '2020-01-01'
	AND FiscalYear < 2020
	) D 
	ON B.DateKey = D.MaxDate
JOIN dbo.DimProduct E
	ON E.ProductKey = A.ProductKey
LEFT JOIN dbo.DimProductSubcategory F 
	ON E.ProductSubcategoryKey = F.ProductSubcategoryKey







-- QUERY REESCRITA
IF (OBJECT_ID('tempdb..#Maior_Data') IS NOT NULL) DROP TABLE #Maior_Data
SELECT
	MAX(DateKey) AS MaxDate 
INTO
	#Maior_Data
FROM
	dbo.DimDate A
	JOIN dbo.FactInternetSales B ON B.OrderDateKey = A.DateKey
WHERE
	FullDateAlternateKey >= '2010-01-01'
	AND FullDateAlternateKey < '2020-01-01'
	AND FiscalYear < 2020
	

SELECT
    A.ProductKey,
    A.OrderDateKey,
    A.SalesOrderNumber,
    A.OrderQuantity,
    A.SalesAmount,
    A.ExtendedAmount,
    A.UnitPrice,
    A.UnitPriceDiscountPct,
    A.RevisionNumber
FROM
    dbo.FactInternetSales A
    JOIN dbo.DimDate B ON B.DateKey = A.DueDateKey
    JOIN dbo.DimCustomer C ON C.CustomerKey = A.CustomerKey
    JOIN #Maior_Data D ON B.DateKey = D.MaxDate
    JOIN dbo.DimProduct E ON E.ProductKey = A.ProductKey
    LEFT JOIN dbo.DimProductSubcategory F ON E.ProductSubcategoryKey = F.ProductSubcategoryKey;


-------------------------------------------
-- Usar ferramentas de identação de código para padronização
-------------------------------------------

-- SQL Prompt, Apex SQLComplete, SSMSBoost, dbForge SQL Complete, devart SQL Complete, etc..


-------------------------------------------
-- SQL Injection
-------------------------------------------

USE [dirceuresende]
GO

--------------- vamos criar uma Stored Procedure normal -----------------

CREATE OR ALTER PROCEDURE dbo.stpConsulta_Tabela (
	@Nome VARCHAR(128)
)
AS
BEGIN

	DECLARE @Query VARCHAR(MAX) = 'SELECT * FROM sys.all_objects WHERE name = ''' + @nome + ''''
	
	PRINT(@Query)
	EXEC(@Query)

END
GO


-- SP funcionando normalmente..
EXEC stpConsulta_Tabela @Nome = 'objects'
EXEC stpConsulta_Tabela @Nome = 'tables'


-- E agora, o nosso SQL Injection :D
EXEC stpConsulta_Tabela @Nome = '''; SELECT * FROM sys.databases; SELECT * FROM sys.database_principals; SELECT * FROM sys.tables;--'


--------------- oh não! E agora? -----------------


CREATE OR ALTER PROCEDURE dbo.stpConsulta_Tabela (
	@Nome VARCHAR(128)
)
AS
BEGIN

	DECLARE @Query NVARCHAR(MAX) = 'SELECT * FROM sys.all_objects WHERE name = @nome' -- Tem que ser NVARCHAR
	
	EXEC sys.sp_executesql 
		@stmt = @Query,
		@params = N'@nome VARCHAR(128)',
		@nome = @Nome	

END
GO


-- Vamos testar de novo..
EXEC stpConsulta_Tabela @Nome = 'objects'
EXEC stpConsulta_Tabela @Nome = 'tables'


-- E agora, o nosso SQL Injection :D
EXEC stpConsulta_Tabela @Nome = '''; SELECT * FROM sys.databases; SELECT * FROM sys.database_principals; SELECT * FROM sys.tables;--'


-------------------------------------------
-- Connection Pooling
-------------------------------------------

SELECT login_name, COUNT(*) AS conexoes
FROM sys.dm_exec_sessions
GROUP BY login_name


SELECT @@CONNECTIONS


SELECT
    B.login_name,
    B.[host_name],
    B.[program_name],
    DB_NAME(B.database_id) AS [database],
    COUNT(*) AS connections
FROM
    sys.dm_exec_connections             A
    LEFT JOIN sys.dm_exec_sessions      B   ON  A.session_id = B.session_id
GROUP BY
    B.login_name,
    B.[host_name],
    B.[program_name],
    DB_NAME(B.database_id)
 
 
SELECT *
FROM sys.dm_os_performance_counters A
WHERE A.counter_name = 'User Connections'



/*

1..100 | ForEach-Object -process {
	$sqlConn = New-Object System.Data.SqlClient.SqlConnection
    $guidDirceu = (New-Guid).Guid 
    $sqlConn.ConnectionString = "Server=localhost\sql2017;Integrated Security=true;Initial Catalog=master;Application Name=$guidDirceu;Pooling=true;Min Pool Size=20;Max Pool Size=100"
    $sqlConn.Open()
}

*/


select type, pages_kb from sys.dm_os_memory_clerks where type = 'MEMORYCLERK_SQLCONNECTIONPOOL'


-------------------------------------------
-- Compressão de LOBs
-------------------------------------------

USE [dirceuresende]
GO

-- 10 segundos para rodar...
IF OBJECT_ID('dbo.TabelaVARMAX', 'U') IS NOT NULL
	 DROP TABLE dbo.TabelaVARMAX
GO

CREATE TABLE dbo.TabelaVARMAX (
	ID INT IDENTITY NOT NULL CONSTRAINT PK_TabelaVARMAX PRIMARY KEY
	, Nome VARCHAR(100) NOT NULL DEFAULT NEWID()
	, DataRegistro DATETIME2 NOT NULL DEFAULT(SYSDATETIME())
	, Texto VARCHAR(MAX) NOT NULL DEFAULT (REPLICATE('A', 4000)) -- Preencher tabela com 4000 caracteres...
)
GO
CREATE INDEX ixNome ON TabelaVARMAX(Nome) INCLUDE(Texto)
GO

BEGIN TRAN
GO
INSERT INTO dbo.TabelaVARMAX DEFAULT VALUES
GO 10000
COMMIT
GO


-- Quantas páginas lidas no range scan?
SET STATISTICS IO ON
SELECT ID, Nome 
  FROM TabelaVARMAX
 WHERE Nome LIKE 'F%'
SET STATISTICS IO OFF
GO
-- Scan count 1, logical reads 617


-- Ativa a opção de armazenamento de dados LOB fora das páginas de dados
EXEC sp_tableoption 'TabelaVARMAX', 'large value types out of row', 1
GO

-- Recria o índice – reorganiza as páginas pra jogar dados LOB para fora da pag.
ALTER INDEX ixNome ON dbo.TabelaVARMAX REBUILD
GO


-- Quantas páginas lidas no range scan?
SET STATISTICS IO ON
SELECT ID, Nome 
  FROM TabelaVARMAX
 WHERE Nome LIKE 'F%'
SET STATISTICS IO OFF
GO

DROP INDEX ixNome ON TabelaVARMAX


sp_spaceused TabelaVARMAX
GO
-- 80456 KB

-- Recria o índice – reorganiza as páginas pra jogar dados LOB para fora da pag.
ALTER TABLE dbo.TabelaVARMAX REBUILD WITH(DATA_COMPRESSION=PAGE)
GO

sp_spaceused TabelaVARMAX
GO
-- 80216 KB
GO

ALTER TABLE TabelaVARMAX DROP CONSTRAINT PK_TabelaVARMAX
GO

CREATE CLUSTERED COLUMNSTORE INDEX IxCC ON TabelaVARMAX
GO

sp_spaceused TabelaVARMAX
GO

-- 520 KB
GO

/*

A regra é a seguinte:
1 - Comprime os dados in-row, ou seja, se couber nos 8KB da página columnstore comprime...
2 - Comprime dados of-row, ou seja, que não cabe na página de 8kb,
    porém apenas dados com tamanho entre 8KB e 16MB (excelente no nosso caso)
3 - Dados > 16MB, não são comprimidos...

*/



-------------------------------------------
-- Cuidados com o NOT IN
-------------------------------------------

USE [AdventureWorksDW2017]
GO

IF (OBJECT_ID('tempdb..#Teste') IS NOT NULL) DROP TABLE #Teste
CREATE TABLE #Teste (
	Pedido VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AI
)

INSERT INTO #Teste VALUES('SO43697'), ('SO43687'), (NULL)

SELECT * 
FROM dbo.FactInternetSales
WHERE SalesOrderNumber NOT IN (
	SELECT Pedido COLLATE SQL_Latin1_General_CP1_CI_AI
	FROM #Teste
)


SELECT * 
FROM dbo.FactInternetSales A
WHERE NOT EXISTS (
	SELECT Pedido COLLATE SQL_Latin1_General_CP1_CI_AI
	FROM #Teste
	WHERE Pedido = A.SalesOrderNumber COLLATE SQL_Latin1_General_CP1_CI_AI
)



-------------------------------------------
-- Utilização de INSERT multi-row
-------------------------------------------

-- NÃO RECOMENDÁVEL
INSERT INTO dirceuresende.dbo.Teste (Conta) VALUES ('Teste1');
INSERT INTO dirceuresende.dbo.Teste (Conta) VALUES ('Teste2');
INSERT INTO dirceuresende.dbo.Teste (Conta) VALUES ('Teste3');


-- RECOMENDÁVEL
INSERT INTO dirceuresende.dbo.Teste (Conta)
VALUES
	('Teste1'),
    ('Teste2'),
    ('Teste3')



-------------------------------------------
-- Evite cursores e while sempre que possível
-------------------------------------------

/*

-- CRIAÇÃO DAS TABELAS
IF (OBJECT_ID('tempdb..#Produtos') IS NOT NULL) DROP TABLE #Produtos
CREATE TABLE #Produtos (
    Codigo INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    Ds_Produto VARCHAR(50) NOT NULL,
    Ds_Categoria VARCHAR(50) NOT NULL,
    Preco NUMERIC(18, 2) NOT NULL
)

IF (OBJECT_ID('tempdb..#Vendas') IS NOT NULL) DROP TABLE #Vendas
CREATE TABLE #Vendas (
    Codigo INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    Dt_Venda DATETIME NOT NULL,
    Cd_Produto INT NOT NULL
)


INSERT INTO #Produtos ( Ds_Produto, Ds_Categoria, Preco )
VALUES
    ( 'Processador i7', 'Informática', 1500.00 ),
    ( 'Processador i5', 'Informática', 1000.00 ),
    ( 'Processador i3', 'Informática', 500.00 ),
    ( 'Placa de Vídeo Nvidia', 'Informática', 2000.00 ),
    ( 'Placa de Vídeo Radeon', 'Informática', 1500.00 ),
    ( 'Celular Apple', 'Celulares', 10000.00 ),
    ( 'Celular Samsung', 'Celulares', 2500.00 ),
    ( 'Celular Sony', 'Celulares', 4200.00 ),
    ( 'Celular LG', 'Celulares', 1000.00 ),
    ( 'Cama', 'Utilidades do Lar', 2000.00 ),
    ( 'Toalha', 'Utilidades do Lar', 40.00 ),
    ( 'Lençol', 'Utilidades do Lar', 60.00 ),
    ( 'Cadeira', 'Utilidades do Lar', 200.00 ),
    ( 'Mesa', 'Utilidades do Lar', 1000.00 ),
    ( 'Talheres', 'Utilidades do Lar', 50.00 )

    

DECLARE @Contador INT = 1, @Total INT = 100

WHILE(@Contador <= @Total)
BEGIN

    INSERT INTO #Vendas ( Cd_Produto, Dt_Venda )
    SELECT 
        (SELECT TOP 1 Codigo FROM #Produtos ORDER BY NEWID()) AS Cd_Produto,
        DATEADD(DAY, (CAST(RAND() * 364 AS INT)), '2017-01-01') AS Dt_Venda

    SET @Contador += 1

END

SELECT * FROM #Vendas

*/



-- Agrupando os dados usando CURSOR
IF (OBJECT_ID('tempdb..#Vendas_Agrupadas') IS NOT NULL) DROP TABLE #Vendas_Agrupadas
SELECT 
    IDENTITY(INT, 1, 1) AS Ranking,
    CONVERT(VARCHAR(6), Dt_Venda, 112) AS Periodo,
    COUNT(*) AS Qt_Vendas_No_Mes,
    NULL AS Qt_Vendas_Acumuladas
INTO 
    #Vendas_Agrupadas
FROM 
    #Vendas
GROUP BY
    CONVERT(VARCHAR(6), Dt_Venda, 112)
    

DECLARE
    @Contador INT = 1, 
    @Total INT = (SELECT COUNT(*) FROM #Vendas_Agrupadas),
    @Qt_Vendas_Acumuladas INT = 0,
    @Qt_Vendas_No_Mes INT = 0


WHILE(@Contador <= @Total)
BEGIN
    
    SELECT @Qt_Vendas_No_Mes = Qt_Vendas_No_Mes
    FROM #Vendas_Agrupadas
    WHERE Ranking = @Contador


    SET @Qt_Vendas_Acumuladas += @Qt_Vendas_No_Mes


    UPDATE #Vendas_Agrupadas
    SET Qt_Vendas_Acumuladas = @Qt_Vendas_Acumuladas
    WHERE Ranking = @Contador


    SET @Contador += 1

END


SELECT * FROM #Vendas_Agrupadas


-- Usando window function
IF (OBJECT_ID('tempdb..#Vendas_Agrupadas') IS NOT NULL) DROP TABLE #Vendas_Agrupadas
SELECT 
    CONVERT(VARCHAR(6), Dt_Venda, 112) AS Periodo,
    COUNT(*) AS Qt_Vendas_No_Mes,
    NULL AS Qt_Vendas_Acumuladas
INTO 
    #Vendas_Agrupadas
FROM 
    #Vendas
GROUP BY
    CONVERT(VARCHAR(6), Dt_Venda, 112)


SELECT 
    Periodo,
    SUM(Qt_Vendas_No_Mes) OVER(ORDER BY Periodo ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Qt_Vendas_Acumuladas    
FROM 
    #Vendas_Agrupadas






-------------------------------------------
-- Outra abordagem para substituir o WHILE
-------------------------------------------

DECLARE
	@SQL1 VARCHAR(MAX) = '',
	@Contador INT = 1,
	@Total INT = (SELECT COUNT(*) FROM sys.tables)

WHILE(@Contador <= @Total)
BEGIN

	SELECT @SQL1 = @SQL1 + 'TRUNCATE TABLE [' + B.[name] + '].[' + A.[name] + ']; '
	FROM sys.tables A
	JOIN sys.schemas B ON B.[schema_id] = A.[schema_id]
	
	SET @Contador += 1

END

SELECT @SQL1



-- SEM WHILE AGORA :)

DECLARE @SQL2 VARCHAR(MAX) = ''

SELECT @SQL2 += 'TRUNCATE TABLE [' + B.[name] + '].[' + A.[name] + ']; '
FROM sys.tables A
JOIN sys.schemas B ON B.[schema_id] = A.[schema_id]

SELECT @SQL2



-------------------------------------------
-- Vamos usar PIVOT
-------------------------------------------

IF (OBJECT_ID('tempdb..#Teste') IS NOT NULL) DROP TABLE #Teste
SELECT
	YEAR(OrderDate) as Ano,
    MONTH(OrderDate) AS Mes,
	OrderQuantity
INTO
	#Teste
FROM 
	dbo.FactInternetSales


SELECT
	Ano,
    [1] = sum(case when Mes = 1 then OrderQuantity end),
    [2] = sum(case when Mes = 2 then OrderQuantity end),
    [3] = sum(case when Mes = 3 then OrderQuantity end),
    [4] = sum(case when Mes = 4 then OrderQuantity end),
	[5] = sum(case when Mes = 5 then OrderQuantity end),
	[6] = sum(case when Mes = 6 then OrderQuantity end),
	[7] = sum(case when Mes = 7 then OrderQuantity end),
	[8] = sum(case when Mes = 8 then OrderQuantity end),
	[9] = sum(case when Mes = 9 then OrderQuantity end),
	[10] = sum(case when Mes = 10 then OrderQuantity end),
	[11] = sum(case when Mes = 11 then OrderQuantity end),
	[12] = sum(case when Mes = 12 then OrderQuantity end)
FROM 
	#Teste
GROUP BY 
	Ano
ORDER BY
	Ano

	
-- Agora, com PIVOT
SELECT 
	Ano,
	*
FROM
	#Teste PIVOT ( SUM(OrderQuantity) FOR Mes IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12] )) p 
ORDER BY 
	1;


-------------------------------------------
-- Totalizadores
-------------------------------------------

SELECT 
    *
FROM (

    SELECT 
        B.Ds_Categoria,
        B.Ds_Produto,
        COUNT(*) AS Qt_Vendas,
        SUM(B.Preco) AS Vl_Total
    FROM 
        #Vendas	A
        JOIN #Produtos B ON A.Cd_Produto = B.Codigo
    GROUP BY
        B.Ds_Categoria,
        B.Ds_Produto
    
    UNION ALL

    SELECT 
        B.Ds_Categoria,
        'Subtotal' AS Ds_Produto,
        COUNT(*) AS Qt_Vendas,
        SUM(B.Preco) AS Vl_Total
    FROM 
        #Vendas	A
        JOIN #Produtos B ON A.Cd_Produto = B.Codigo
    GROUP BY
        B.Ds_Categoria
    
    UNION ALL

    SELECT 
        'Total' AS Ds_Categoria,
        'Total' AS Ds_Produto,
        COUNT(*) AS Qt_Vendas,
        SUM(B.Preco) AS Vl_Total
    FROM 
        #Vendas	A
        JOIN #Produtos B ON A.Cd_Produto = B.Codigo
    
) A
ORDER BY
    (CASE WHEN A.Ds_Categoria = 'Total' THEN 1 ELSE 0 END),
    A.Ds_Categoria,
    (CASE WHEN A.Ds_Produto = 'Subtotal' THEN 1 ELSE 0 END),
    A.Ds_Produto



-- Utilizando ROLLUP
SELECT 
    ISNULL(B.Ds_Categoria, 'Total') AS Ds_Categoria,
    ISNULL(B.Ds_Produto, 'Subtotal') AS Ds_Produto,
    COUNT(*) AS Qt_Vendas,
    SUM(B.Preco) AS Vl_Total
FROM 
    #Vendas A
    JOIN #Produtos B ON A.Cd_Produto = B.Codigo
GROUP BY
    ROLLUP(B.Ds_Categoria, B.Ds_Produto)


-- Quebrando por mês
SELECT
    ISNULL(CONVERT(VARCHAR(10), MONTH(A.Dt_Venda)), 'Total') AS Mes_Venda, 
    ISNULL(B.Ds_Categoria, 'Subtotal') AS Ds_Categoria,
    COUNT(*) AS Qt_Vendas,
    SUM(B.Preco) AS Vl_Total
FROM 
    #Vendas A
    JOIN #Produtos B ON A.Cd_Produto = B.Codigo
GROUP BY
    ROLLUP(MONTH(A.Dt_Venda), B.Ds_Categoria)


-- Agrupando por CUBO
SELECT
    ISNULL(CONVERT(VARCHAR(10), MONTH(A.Dt_Venda)), 'Total') AS Mes_Venda, 
    ISNULL(B.Ds_Categoria, 'Subtotal') AS Ds_Categoria,
    COUNT(*) AS Qt_Vendas,
    SUM(B.Preco) AS Vl_Total
FROM 
    #Vendas A
    JOIN #Produtos B ON A.Cd_Produto = B.Codigo
GROUP BY
    CUBE(MONTH(A.Dt_Venda), B.Ds_Categoria)


-- Utilizando GROUPING SETS
SELECT
    MONTH(A.Dt_Venda) AS Mes_Venda, 
    B.Ds_Categoria,
    B.Ds_Produto,
    COUNT(*) AS Qt_Vendas,
    SUM(B.Preco) AS Vl_Total
FROM 
    #Vendas A
    JOIN #Produtos B ON A.Cd_Produto = B.Codigo
GROUP BY
    GROUPING SETS(MONTH(A.Dt_Venda), B.Ds_Categoria, B.Ds_Produto)
