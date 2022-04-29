
SET STATISTICS TIME, IO ON
SET STATISTICS PROFILE OFF



-- Exemplo dos dados da tabela
SELECT Dados_Serializados
FROM _Clientes
WHERE Dados_Serializados = N'2015-01-01 00:08:19|4|6|0'



-- Vou tentar usar variável para resolver esse problema
DECLARE @Busca NVARCHAR(200) = N'2015-01-01 00:08:19|4|6|0'

SELECT Dados_Serializados
FROM _Clientes
WHERE Dados_Serializados = @Busca


---------------------------------------------
-- SOLUÇÃO
---------------------------------------------

-- Vou utilizar o tipo correto dos dados
SELECT Dados_Serializados
FROM _Clientes
WHERE Dados_Serializados = '2015-01-01 00:08:19|4|6|0'


DECLARE @Busca VARCHAR(200) = '2015-01-01 00:08:19|4|6|0'

SELECT Dados_Serializados
FROM _Clientes
WHERE Dados_Serializados = @Busca


-- O inverso, porém, não acontece
SELECT Dados_Serializados_N
FROM _Clientes
WHERE Dados_Serializados_N = '2015-01-01 00:08:19|4|6|0'

