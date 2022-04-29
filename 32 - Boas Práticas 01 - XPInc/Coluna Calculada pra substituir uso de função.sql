
SET STATISTICS TIME, IO ON
SET STATISTICS PROFILE OFF


-- Preciso pegar uma parte da string serializada
-- EXEMPLO: 2015-01-01 23:02:00|5|9|0
SELECT TOP 2000 Dados_Serializados
FROM _Clientes2
WHERE dbo.fncSplit(Dados_Serializados, '|', 3) = '6'



---------------------------------------------
-- SOLUÇÃO
---------------------------------------------

-- Crio uma nova coluna calculada com essa função
ALTER TABLE _Clientes2 ADD Coluna_Teste AS (dbo.fncSplit(Dados_Serializados, '|', 3))
GO
 
-- Cria um índice para a nova coluna criada
CREATE NONCLUSTERED INDEX SK04_Clientes2 ON dbo._Clientes2(Coluna_Teste) INCLUDE(Dados_Serializados)
GO

-- DROP INDEX SK04_Clientes2 ON dbo._Clientes2
-- ALTER TABLE _Clientes2 DROP COLUMN Coluna_Teste
 
-- Executa a consulta nova
SELECT TOP 2000 Dados_Serializados
FROM _Clientes2
WHERE Coluna_Teste = '6'



---------------------------------------------
-- SOLUÇÃO
---------------------------------------------

-- Utilizamos o SQLCLR
SELECT Dados_Serializados
FROM _Clientes2
WHERE CLR.dbo.fncSplit(Dados_Serializados, '|', 3) = '6' COLLATE SQL_Latin1_General_CP1_CI_AI



