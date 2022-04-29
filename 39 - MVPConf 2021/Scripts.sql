TRUNCATE TABLE [dbo].[Clientes]


INSERT INTO dbo.[Clientes] (
                           [Nome],
                           [Dt_Nascimento]
                       )
VALUES('Dirceu Resende', '1987-01-01'), ('Eduardo Cerqueira', '1988-01-01')

------------------------------------------------------------------------------

TRUNCATE TABLE [dbo].[Funcionarios]


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

TRUNCATE TABLE [dbo].[Produtos]


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


TRUNCATE TABLE [dbo].[Pedidos]


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

CREATE USER [adf-mvpconf-dev] FROM EXTERNAL PROVIDER;
GO

ALTER ROLE [db_datareader] ADD MEMBER [adf-mvpconf-dev];
GO

ALTER ROLE [db_datawriter] ADD MEMBER [adf-mvpconf-dev];
GO

ALTER ROLE [db_ddladmin] ADD MEMBER [adf-mvpconf-dev];
GO


CREATE USER [asmvpconfdev] WITH PASSWORD = 'lh^iG3*cVOy3VnNnqX$$y0N!78$vrYK7*ipY%v16S!TQWUPn&T';
GO

ALTER ROLE [db_datareader] ADD MEMBER [asmvpconfdev];
GO


CREATE USER [pbimvpconfqa] WITH PASSWORD = 'PmK^!8O6c7tB4kua#3C@HanBD$C3a!psY&s89Xn!EruQ%*ozzS';
GO

ALTER ROLE [db_datareader] ADD MEMBER [pbimvpconfqa];
GO



CREATE USER [pbimvpconfprod] WITH PASSWORD = 'PmK^!8O6c7tB4kua#3C@HanBD$C3a!psY&s89Xn!EruQ%*ozzS';
GO

ALTER ROLE [db_datareader] ADD MEMBER [pbimvpconfprod];
GO