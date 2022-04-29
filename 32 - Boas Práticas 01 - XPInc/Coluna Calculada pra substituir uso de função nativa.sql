SET STATISTICS TIME, IO ON
SET STATISTICS PROFILE OFF

-- Retornando uma data usando substring/left
SELECT Dados_Serializados
FROM _Clientes
WHERE SUBSTRING(Dados_Serializados, 1, 10) = '2015-01-01'


SELECT Dados_Serializados
FROM _Clientes
WHERE LEFT(Dados_Serializados, 10) = '2015-01-01'


---------------------------------------------
-- SOLUÇÃO
---------------------------------------------

-- Retornando a mesma data usando like
SELECT Dados_Serializados
FROM _Clientes
WHERE Dados_Serializados LIKE '2015-01-01%'









-- Agora pegar o final de uma string
SELECT Dados_Serializados
FROM _Clientes
WHERE Dados_Serializados LIKE '%4|6|0'

---------------------------------------------
-- SOLUÇÃO
---------------------------------------------

-- Crio a nova coluna calculada
ALTER TABLE _Clientes ADD Right_5 AS (RIGHT(Dados_Serializados, 5))
GO

-- Crio um índice para a nova coluna criada
CREATE NONCLUSTERED INDEX SK03_Clientes ON dbo._Clientes(Right_5)
GO

-- Executa a consulta nova
SELECT Right_5
FROM _Clientes
WHERE Right_5 = '4|6|0'
