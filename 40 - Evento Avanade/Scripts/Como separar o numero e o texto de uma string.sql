IF (OBJECT_ID('tempdb..#Teste') IS NOT NULL) DROP TABLE #Teste
CREATE TABLE #Teste (
    Nr_Documento VARCHAR(50)
)

INSERT INTO #Teste
VALUES 
    ('12345678909'),
    ('123.456.789-09'),
    ('Dirceu12345Resende678909.com'),
    (' 12345678909 '),
    ('"12345678909"'),
    ('d12345678909'),
    ('12345+6789-09'),
    ('123456.789'),
    ('R$ 123456.789'),
    ('$ 123456.789'),
    ('+123456.789'),
    ('-123456.789'),
    ('Dirceu Resende'),
    ('Dirceu[Resende]')
    
    

-- Exemplo 1 – Como retornar linhas com apenas números (NOT LIKE)
SELECT * 
FROM #Teste
WHERE Nr_Documento IS NOT NULL
AND Nr_Documento NOT LIKE '%a%'
AND Nr_Documento NOT LIKE '%b%'
AND Nr_Documento NOT LIKE '%c%'
AND Nr_Documento NOT LIKE '%d%'
AND Nr_Documento NOT LIKE '%e%'
AND Nr_Documento NOT LIKE '%f%'
AND Nr_Documento NOT LIKE '%g%'
AND Nr_Documento NOT LIKE '%h%'
AND Nr_Documento NOT LIKE '%i%'
AND Nr_Documento NOT LIKE '%j%'
AND Nr_Documento NOT LIKE '%k%'
AND Nr_Documento NOT LIKE '%l%'
AND Nr_Documento NOT LIKE '%m%'
AND Nr_Documento NOT LIKE '%n%'
AND Nr_Documento NOT LIKE '%o%'
AND Nr_Documento NOT LIKE '%p%'
AND Nr_Documento NOT LIKE '%q%'
AND Nr_Documento NOT LIKE '%r%'
AND Nr_Documento NOT LIKE '%s%'
AND Nr_Documento NOT LIKE '%t%'
AND Nr_Documento NOT LIKE '%u%'
AND Nr_Documento NOT LIKE '%v%'
AND Nr_Documento NOT LIKE '%x%'
AND Nr_Documento NOT LIKE '%w%'
AND Nr_Documento NOT LIKE '%z%'
AND Nr_Documento NOT LIKE '%y%'
AND Nr_Documento NOT LIKE '%.%'
AND Nr_Documento NOT LIKE '%-%'
AND Nr_Documento NOT LIKE '%"%'
AND Nr_Documento NOT LIKE '%[%'
AND Nr_Documento NOT LIKE '%]%'



-- Exemplo 2 – Como retornar linhas com apenas números (ISNUMERIC)
SELECT * 
FROM #Teste
WHERE ISNUMERIC(Nr_Documento) = 1



-- Exemplo 3 – Como retornar linhas com apenas números (NOT LIKE e Expressão Regular)
SELECT * 
FROM #Teste
WHERE Nr_Documento NOT LIKE '%[A-z]%'



-- Exemplo 4 – Como retornar linhas com apenas letras
SELECT * 
FROM #Teste
WHERE Nr_Documento NOT LIKE '%[^0-9]%'


SELECT * 
FROM #Teste
WHERE Nr_Documento NOT LIKE '%[^A-z ]%' -- Reparem esse espaço no final



-- Exemplo 5 – Como retornar linhas que contém caracteres especiais
-- Estou permitindo também, os caracteres (+), (.) e (-), além do espaço
SELECT * 
FROM #Teste
WHERE Nr_Documento LIKE '%[^A-z0-9 +.-]%'



-- Como separar a parte numérica e a parte texto de uma string
SELECT 
    Nr_Documento,
    dbo.fncRecupera_Numeros(Nr_Documento)
FROM
    #Teste
WHERE
    dbo.fncRecupera_Numeros(Nr_Documento) = '12345678909'
    
    
  
-- Também consigo fazer a mesma coisa com a parte textual, onde vou retornar as linhas cuja frase 
-- textual seja “Dirceu Resende”:
SELECT 
    Nr_Documento,
    dbo.fncRecupera_Numeros(Nr_Documento) AS Parte_Numerica,
    dbo.fncRecupera_Letras(Nr_Documento) AS Parte_Textual
FROM
    #Teste
WHERE
    dbo.fncRecupera_Letras(Nr_Documento) IN ('Dirceu Resende', 'DirceuResende')
    
    

-- Analisando todas as linhas dessa tabela, agora utilizando também as 2 funções:
SELECT 
    Nr_Documento,
    dbo.fncRecupera_Numeros(Nr_Documento) AS Parte_Numerica,
    dbo.fncRecupera_Letras(Nr_Documento) AS Parte_Textual
FROM
    #Teste
    
    
    
    
    
-------------------------

CREATE FUNCTION [dbo].[fncRecupera_Letras] ( @str VARCHAR(500) )
RETURNS VARCHAR(500)
BEGIN

    DECLARE @startingIndex INT = 0
    
    WHILE (1 = 1)
    BEGIN
        
        SET @startingIndex = PATINDEX('%[^a-Z|^ ]%', @str)
        
        IF @startingIndex <> 0
        BEGIN
            SET @str = REPLACE(@str, SUBSTRING(@str, @startingIndex, 1), '')
        END
        ELSE
            BREAK

    END

    RETURN @str

END
GO


CREATE FUNCTION [dbo].[fncRecupera_Numeros] ( @str VARCHAR(500) )
RETURNS VARCHAR(500)
BEGIN

    DECLARE @startingIndex INT = 0
    
    WHILE (1 = 1)
    BEGIN
        
        SET @startingIndex = PATINDEX('%[^0-9]%', @str)
        
        IF @startingIndex <> 0
        BEGIN
            SET @str = REPLACE(@str, SUBSTRING(@str, @startingIndex, 1), '')
        END
        ELSE
            BREAK

    END

    RETURN @str

END
GO
