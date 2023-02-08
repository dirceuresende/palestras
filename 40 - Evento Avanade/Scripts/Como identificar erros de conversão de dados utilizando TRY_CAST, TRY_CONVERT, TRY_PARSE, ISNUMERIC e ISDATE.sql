IF ( OBJECT_ID ( 'tempdb..#Teste' ) IS NOT NULL ) DROP TABLE #Teste
SELECT
    CAST ( BusinessEntityID AS VARCHAR ( MAX ) ) AS BusinessEntityID ,
    Title ,
    FirstName ,
    LastName ,
    rowguid ,
    CONVERT ( VARCHAR ( MAX ) , ModifiedDate , 112 ) AS ModifiedDate
INTO
    #Teste
FROM
    AdventureWorks2019.Person.Person


-- Simulando alguns erros
UPDATE #Teste
SET
    ModifiedDate = LEFT ( ModifiedDate , 7 ) + '2'
WHERE
    BusinessEntityID BETWEEN 1 AND 20
    OR BusinessEntityID BETWEEN 5000 AND 6000


UPDATE #Teste
SET
    BusinessEntityID += 'D'
WHERE
	BusinessEntityID BETWEEN 1400 AND 1450


SELECT *
FROM #Teste


SELECT *
FROM #Teste
WHERE BusinessEntityID LIKE '%D'
OR BusinessEntityID BETWEEN 1 AND 50
OR BusinessEntityID BETWEEN 5000 AND 6000



SELECT CONVERT ( INT , BusinessEntityID )
FROM #Teste


SELECT CONVERT ( DATE , ModifiedDate , 112 )
FROM #Teste


SELECT BusinessEntityID
FROM #Teste
WHERE TRY_CAST ( BusinessEntityID AS INT ) IS NULL


SELECT ModifiedDate
FROM #Teste
WHERE TRY_CONVERT ( DATE , ModifiedDate , 112 ) IS NULL


SELECT ModifiedDate , TRY_CONVERT ( DATE , ModifiedDate , 112 )
FROM #Teste


SELECT * 
FROM #Teste
WHERE ISNUMERIC ( BusinessEntityID ) = 0


SELECT * FROM #Teste
WHERE ISDATE ( ModifiedDate ) = 0