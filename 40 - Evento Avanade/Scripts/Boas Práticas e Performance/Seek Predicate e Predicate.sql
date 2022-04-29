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


-- Vamos criar uma estat�stica pra coluna de status de analisar o histograma dela
CREATE STATISTICS Vendas_Status ON dbo.Vendas(Status) WITH FULLSCAN
GO

DBCC SHOW_STATISTICS('Vendas', Vendas_Status)
GO


-- Vamos criar uma estat�stica pra coluna de Dt_Pedido de analisar o histograma dela
CREATE STATISTICS Vendas_DtPedido ON dbo.Vendas(Dt_Pedido) WITH FULLSCAN
GO

DBCC SHOW_STATISTICS('Vendas', Vendas_DtPedido)
GO


---------------------------------------------
-- SOLU��O
---------------------------------------------

-- Vamos refazer os �ndices para aproveitar melhor a opera��o de Seek
DROP INDEX SK02_Pedidos ON dbo.Vendas
GO

CREATE NONCLUSTERED INDEX SK02_Pedidos ON dbo.Vendas (Dt_Pedido, [Status]) INCLUDE(Quantidade, Valor)
GO


-- Refa�o a consulta
SELECT *
FROM dbo.Vendas
WHERE Dt_Pedido >= '2019-02-06'
AND Dt_Pedido < '2019-02-09'
AND [Status] < 5




-- Nova consulta, agora com igualdade ao inv�s de range no Status
SELECT Quantidade * Valor
FROM dbo.Vendas
WHERE Dt_Pedido > '2019-02-06'
AND Dt_Pedido < '2019-02-09'
AND [Status] = 5



---------------------------------------------
-- SOLU��O
---------------------------------------------

-- Recrio os �ndices de novo para se adequar melhor � nova situa��o
DROP INDEX SK02_Pedidos ON dbo.Vendas
GO

CREATE NONCLUSTERED INDEX SK02_Pedidos ON dbo.Vendas ([Status], Dt_Pedido) INCLUDE(Quantidade, Valor)
GO


-- Refa�o a consulta
SELECT Quantidade * Valor
FROM dbo.Vendas
WHERE Dt_Pedido > '2019-02-06'
AND Dt_Pedido < '2019-02-09'
AND [Status] = 5

