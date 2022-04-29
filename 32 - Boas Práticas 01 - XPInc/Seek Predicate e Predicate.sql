SET STATISTICS TIME, IO ON
SET STATISTICS PROFILE OFF


-- Consultando dados de venda
SELECT *
FROM dbo.Vendas
WHERE Dt_Pedido >= '2019-02-06'
AND Dt_Pedido < '2019-02-09'
AND [Status] < 5




-- Vou analisar o profile da consulta
SET STATISTICS PROFILE ON

SELECT *
FROM dbo.Vendas
WHERE Dt_Pedido >= '2019-02-06'
AND Dt_Pedido < '2019-02-09'
AND [Status] < 5


-- Vamos criar uma estatística pra coluna de status de analisar o histograma dela
CREATE STATISTICS Vendas_Status ON dbo.Vendas(Status) WITH FULLSCAN
GO

DBCC SHOW_STATISTICS('Vendas', Vendas_Status)
GO


-- Vamos criar uma estatística pra coluna de Dt_Pedido de analisar o histograma dela
CREATE STATISTICS Vendas_DtPedido ON dbo.Vendas(Dt_Pedido) WITH FULLSCAN
GO

DBCC SHOW_STATISTICS('Vendas', Vendas_DtPedido)
GO


---------------------------------------------
-- SOLUÇÃO
---------------------------------------------

-- Vamos refazer os índices para aproveitar melhor a operação de Seek
DROP INDEX SK02_Pedidos ON dbo.Vendas
GO

CREATE NONCLUSTERED INDEX SK02_Pedidos ON dbo.Vendas (Dt_Pedido, [Status]) INCLUDE(Quantidade, Valor)
GO


-- Refaço a consulta
SELECT *
FROM dbo.Vendas
WHERE Dt_Pedido >= '2019-02-06'
AND Dt_Pedido < '2019-02-09'
AND [Status] < 5




-- Nova consulta, agora com igualdade ao invés de range no Status
SELECT Quantidade * Valor
FROM dbo.Vendas
WHERE Dt_Pedido > '2019-02-06'
AND Dt_Pedido < '2019-02-09'
AND [Status] = 5



---------------------------------------------
-- SOLUÇÃO
---------------------------------------------

-- Recrio os índices de novo para se adequar melhor à nova situação
DROP INDEX SK02_Pedidos ON dbo.Vendas
GO

CREATE NONCLUSTERED INDEX SK02_Pedidos ON dbo.Vendas ([Status], Dt_Pedido) INCLUDE(Quantidade, Valor)
GO


-- Refaço a consulta
SELECT Quantidade * Valor
FROM dbo.Vendas
WHERE Dt_Pedido > '2019-02-06'
AND Dt_Pedido < '2019-02-09'
AND [Status] = 5

