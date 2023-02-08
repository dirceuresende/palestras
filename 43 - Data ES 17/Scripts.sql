

/*

pbidemo-db.database.windows.net

- powerbi-db-dev (pbi-db-reader-dev / VbkI@A2PZCfC&8!ubTKp%1wS$nxkYMhomNI7^FEsRFJco7gEuZ)
- powerbi-db-prod (pbi-db-reader-prod / PmK^!8O6c7tB4kua#3C@HanBD$C3a!psY&s89Xn!EruQ%*ozzS)
    
*/



IF (OBJECT_ID('dbo.Clientes') IS NOT NULL) DROP TABLE dbo.Clientes
CREATE TABLE dbo.Clientes (
	Id_Cliente INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[Nome] VARCHAR(100) NOT NULL,
    [Dt_Nascimento] DATE NOT NULL
)

IF (OBJECT_ID('dbo.Funcionarios') IS NOT NULL) DROP TABLE dbo.Funcionarios
CREATE TABLE dbo.Funcionarios (
	Id_Funcionario INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[Nome] VARCHAR(100) NOT NULL,
    [Dt_Nascimento] DATE NOT NULL,
	[Salario] NUMERIC(18, 2) NOT NULL
)

IF (OBJECT_ID('dbo.Produtos') IS NOT NULL) DROP TABLE dbo.Produtos
CREATE TABLE dbo.Produtos (
	Id_Produto INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[Nome] VARCHAR(100) NOT NULL,
	[Custo] NUMERIC(18, 2) NOT NULL,
	[Venda] NUMERIC(18, 2) NOT NULL
)

IF (OBJECT_ID('dbo.Pedidos') IS NOT NULL) DROP TABLE dbo.Pedidos
CREATE TABLE dbo.Pedidos (
	Id_Pedido INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[Id_Cliente] INT NOT NULL,
    [Id_Vendedor] INT NOT NULL,
    [Id_Produto] INT NOT NULL,
    [Quantidade] INT NOT NULL
)

------------------------------------------------------------------------------

INSERT INTO dbo.[Clientes] (
    [Nome],
    [Dt_Nascimento]
)
VALUES('Dirceu Resende', '1987-01-01'), ('Eduardo Cerqueira', '1988-01-01')

------------------------------------------------------------------------------

INSERT INTO dbo.[Funcionarios] (
    [Nome],
    [Dt_Nascimento],
    [Salario]
)
VALUES
    ('Jackie Chan', '1952-01-01', 7600),
    ('Donnie Yen', '1962-01-01', 5200),
    ('Jet Li', '1965-01-01', 6600)

------------------------------------------------------------------------------

INSERT INTO dbo.[Produtos] (
    [Nome],
    [Custo],
    [Venda]
)
VALUES
(
    'Kimono', -- Nome - varchar(100)
    250,  -- Custo - numeric(18, 2)
    650   -- Venda - numeric(18, 2)
),
(
    'Luva', -- Nome - varchar(100)
    82,  -- Custo - numeric(18, 2)
    129   -- Venda - numeric(18, 2)
),
(
    'Faixa', -- Nome - varchar(100)
    49,  -- Custo - numeric(18, 2)
    119   -- Venda - numeric(18, 2)
)


------------------------------------------------------------------------------


INSERT INTO dbo.[Pedidos] (
    [Id_Cliente],
    [Id_Vendedor],
    [Id_Produto],
    [Quantidade]
)
SELECT 
    (SELECT TOP(1) [Id_Cliente] FROM [dbo].[Clientes] ORDER BY NEWID()) AS [Id_Cliente],
    (SELECT TOP(1) [Id_Funcionario] FROM [dbo].[Funcionarios] ORDER BY NEWID()) AS [Id_Vendedor],
    (SELECT TOP(1) [Id_Produto] FROM [dbo].[Produtos] ORDER BY NEWID()) AS [Id_Produto],
    ((ABS(CHECKSUM(PWDENCRYPT(N''))) / 2147483647.0) * 5) + 1 AS Quantidade
FROM
    sys.[tables] AS [T];
GO 10



-------------------------------------------------------------------------------

CREATE USER [pbi-db-reader-dev] WITH PASSWORD = 'VbkI@A2PZCfC&8!ubTKp%1wS$nxkYMhomNI7^FEsRFJco7gEuZ';
GO

ALTER ROLE [db_datareader] ADD MEMBER [pbi-db-reader-dev];
GO



CREATE USER [pbi-db-reader-prod] WITH PASSWORD = 'PmK^!8O6c7tB4kua#3C@HanBD$C3a!psY&s89Xn!EruQ%*ozzS';
GO

ALTER ROLE [db_datareader] ADD MEMBER [pbi-db-reader-prod];
GO


-- https://app.powerbi.com/admin-portal/tenantSettings
-- Allow service principals to use Power BI APIs

-- PowerBI_DevOps
-- PowerBI-ServicePrincipals (Security Group)
-- Object ID: c7bbd940-9037-4a5e-8b1c-fd56df6bcc20
-- app:2580fb64-a3af-4df7-ae65-01ac7d41390f@b7ce7a9f-ef05-4653-b49b-40cf4e3e9901
-- ki58Q~y0uhE~MIXMxurU5yZrqJt2vXtHaXZJHaeY