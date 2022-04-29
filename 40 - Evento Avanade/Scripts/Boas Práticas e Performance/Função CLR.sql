SET STATISTICS TIME, IO ON
SET STATISTICS PROFILE OFF

-- Preciso validar um CPF numa consulta
SELECT COUNT(*)
FROM dbo.Teste_Performance
WHERE dbo.fncValida_CPF(CPF) = 1



---------------------------------------------
-- SOLU��O
---------------------------------------------

-- Utilizar SQLCLR
SELECT COUNT(*)
FROM dbo.Teste_Performance
WHERE CLR.dbo.fncValida_CPF(CPF) = 1


-- Preciso retornar apenas a parte num�rica de uma string
SELECT COUNT(*)
FROM dbo.Teste_Performance
WHERE dbo.fncRecupera_Numeros(Nome) = 2441040576087469698


---------------------------------------------
-- SOLU��O
---------------------------------------------

-- Utilizar SQLCLR
SELECT COUNT(*)
FROM dbo.Teste_Performance
WHERE CLR.dbo.fncRecupera_Numeros(Nome) = 2441040576087469698