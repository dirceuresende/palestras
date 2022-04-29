CREATE FUNCTION dbo.fncRand(@Numero BIGINT)
RETURNS BIGINT
AS
BEGIN
    RETURN (ABS(CHECKSUM(PWDENCRYPT(N''))) / 2147483647.0) * @Numero
END
GO


IF (OBJECT_ID('dbo.Teste') IS NOT NULL) DROP TABLE dbo.Teste
SELECT
    DATEADD(DAY, dbo.fncRand(12000), '1980-01-01') AS Dt_Nascimento,
    RIGHT(REPLICATE('0', 11) + CAST(dbo.fncRand(99999999999) AS VARCHAR(11)), 11) AS CPF,
    dbo.fncRand(110) AS Idade,
    (CASE dbo.fncRand(4)
        WHEN 0 THEN 'Dirceu'
        WHEN 1 THEN 'Vithor'
        WHEN 2 THEN 'Fabricio'
        ELSE 'Tiago'
    END) AS Primeiro_Nome,
    (CASE dbo.fncRand(19)
        WHEN 0 THEN 'Doe'
        WHEN 1 THEN 'Smith'
        WHEN 2 THEN 'McGregor'
        WHEN 3 THEN 'Kent'
        WHEN 4 THEN 'Johnson'
        WHEN 5 THEN 'Williams'
        WHEN 6 THEN 'Jones'
        WHEN 7 THEN 'Brown'
        WHEN 8 THEN 'Davis'
        WHEN 9 THEN 'Miller'
        WHEN 10 THEN 'Wilson'
        WHEN 11 THEN 'Moore'
        WHEN 12 THEN 'Taylor'
        WHEN 13 THEN 'Anderson'
        WHEN 14 THEN 'Jackson'
        WHEN 15 THEN 'White'
        WHEN 16 THEN 'Harris'
        WHEN 17 THEN 'Martin'
        WHEN 18 THEN 'Thompson'
        ELSE 'Klein'
    END) AS Ultimo_Nome
INTO
    dbo.Teste
FROM
    (SELECT 1 AS 'OK') A
    
        
DECLARE
    @Contador INT = 1,
    @Total INT = 21
   
    
WHILE(@Contador <= @Total)
BEGIN 
    
    INSERT INTO dbo.Teste
    SELECT
        DATEADD(DAY, dbo.fncRand(12000), '1980-01-01') AS Dt_Nascimento,
        RIGHT(REPLICATE('0', 11) + CAST(dbo.fncRand(99999999999) AS VARCHAR(11)), 11) AS CPF,
        dbo.fncRand(110) AS Idade,
        (CASE dbo.fncRand(4)
            WHEN 0 THEN 'Dirceu'
            WHEN 1 THEN 'Vithor'
            WHEN 2 THEN 'Fabricio'
            ELSE 'Tiago'
        END) AS Primeiro_Nome,
        (CASE dbo.fncRand(19)
            WHEN 0 THEN 'Doe'
            WHEN 1 THEN 'Smith'
            WHEN 2 THEN 'McGregor'
            WHEN 3 THEN 'Kent'
            WHEN 4 THEN 'Johnson'
            WHEN 5 THEN 'Williams'
            WHEN 6 THEN 'Jones'
            WHEN 7 THEN 'Brown'
            WHEN 8 THEN 'Davis'
            WHEN 9 THEN 'Miller'
            WHEN 10 THEN 'Wilson'
            WHEN 11 THEN 'Moore'
            WHEN 12 THEN 'Taylor'
            WHEN 13 THEN 'Anderson'
            WHEN 14 THEN 'Jackson'
            WHEN 15 THEN 'White'
            WHEN 16 THEN 'Harris'
            WHEN 17 THEN 'Martin'
            WHEN 18 THEN 'Thompson'
            ELSE 'Klein'
        END) AS Ultimo_Nome
    FROM
        dbo.Teste WITH(NOLOCK)


    SET @Contador += 1


END
GO
