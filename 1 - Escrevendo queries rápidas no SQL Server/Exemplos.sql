-- Retornar as estatísticas de CPU e I/O das consultas
SET STATISTICS TIME ON
SET STATISTICS IO ON

----------------------------------------------
-- Pesquisando um CPF
----------------------------------------------

SELECT * FROM dbo.Teste WHERE CPF = '34975305634'
GO

CREATE CLUSTERED INDEX SK01_Teste ON dbo.Teste(CPF)
GO

SELECT * FROM dbo.Teste WHERE CPF = '34975305634'
GO


----------------------------------------------
-- Tabela variável x Tabela temporária
----------------------------------------------

SET STATISTICS TIME OFF
SET STATISTICS IO OFF

IF (OBJECT_ID('tempdb..#Teste') IS NOT NULL) DROP TABLE #Teste
SELECT CPF
INTO #Teste
FROM dbo.Teste

DECLARE @Teste TABLE (
    CPF VARCHAR(11)
)

INSERT INTO @Teste
SELECT CPF
FROM dbo.Teste


SET STATISTICS TIME ON
SET STATISTICS IO ON

SELECT * FROM #Teste WHERE CPF = '34975305634'
SELECT * FROM @Teste WHERE CPF = '34975305634'


CREATE NONCLUSTERED INDEX SK01 ON [dbo].[#Teste] ([CPF])

SELECT * FROM #Teste WHERE CPF = '34975305634'
SELECT * FROM @Teste WHERE CPF = '34975305634'


----------------------------------------------
-- Evitar criação de tabelas (ou qualquer outro DDL) no meio da query
----------------------------------------------


-- Sem hint
SELECT TOP 100 *
FROM dbo.Teste 

-- Com hint
SELECT TOP 100 *
FROM dbo.Teste 
OPTION(RECOMPILE)


----------------------------------------------
-- Substituir NOT IN por NOT EXISTS ou LEFT JOIN
----------------------------------------------

SET STATISTICS TIME ON
SET STATISTICS IO ON

SELECT COUNT(*) FROM dbo.Teste a
WHERE CPF NOT IN (SELECT CPF FROM dbo.Teste B WHERE Primeiro_Nome = 'Dirceu')

/*

(1 row(s) affected)
Table 'Teste'. Scan count 34, logical reads 6321808, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

(1 row(s) affected)

 SQL Server Execution Times:
   CPU time = 18280 ms,  elapsed time = 5078 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.
*/

SELECT COUNT(*) FROM dbo.Teste A
WHERE NOT EXISTS (SELECT NULL FROM dbo.Teste B WHERE Primeiro_Nome = 'Dirceu' AND A.CPF = B.CPF)
GO

SELECT COUNT(*) 
FROM dbo.Teste A
LEFT JOIN dbo.Teste B ON A.CPF = B.CPF AND B.Primeiro_Nome = 'Dirceu'
WHERE B.CPF IS NULL
GO

/*
Table 'Teste'. Scan count 18, logical reads 30372, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

(1 row(s) affected)

 SQL Server Execution Times:
   CPU time = 2388 ms,  elapsed time = 368 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
*/


----------------------------------------------
-- Analisar uso de elementos NON-SARGABLE em WHERE
----------------------------------------------

SET STATISTICS TIME ON
SET STATISTICS IO ON


CREATE NONCLUSTERED INDEX SK02_Teste ON dbo.Teste(CPF, Primeiro_Nome, Ultimo_Nome)
CREATE NONCLUSTERED INDEX SK03_Teste ON dbo.Teste(Primeiro_Nome, Ultimo_Nome)
CREATE NONCLUSTERED INDEX SK04_Teste ON [dbo].[Teste] ([Ultimo_Nome],[Idade]) INCLUDE ([CPF])

SELECT CPF
FROM dbo.Teste
WHERE (Idade >= 50 AND Ultimo_Nome = 'McGregor')
OR (CPF = '02517158725')


;WITH CTE AS (
    SELECT CPF, Idade, Ultimo_Nome
    FROM dbo.Teste
)
SELECT CPF
FROM CTE
WHERE (Idade >= 50 AND Ultimo_Nome = 'McGregor')

UNION ALL

SELECT CPF
FROM CTE
WHERE (CPF = '02517158725')


----------------------------------------------
-- Evitar o hint OPTION(MAXDOP 1) 
----------------------------------------------

SELECT COUNT(*), AVG(Idade), SUM(Idade), MAX(Idade), MIN(Idade)
FROM dbo.Teste


SELECT COUNT(*), AVG(Idade), SUM(Idade), MAX(Idade), MIN(Idade)
FROM dbo.Teste
OPTION(MAXDOP 1)


----------------------------------------------
-- Evitar o uso das funções LEFT() e SUBSTRING(Texto, 1, X) na cláusula WHERE 
----------------------------------------------

SELECT COUNT(*)
FROM dbo.Teste
WHERE SUBSTRING(CPF, 1, 6) = '123456'

SELECT COUNT(*)
FROM dbo.Teste
WHERE LEFT(CPF, 6) = '123456'

SELECT COUNT(*)
FROM dbo.Teste
WHERE CPF LIKE '123456%'



----------------------------------------------
-- Substituir funções UDF por funções do CLR
----------------------------------------------


SELECT TOP 1000 *
INTO dbo.Teste_1k
FROM dbo.Teste
ORDER BY Dt_Nascimento
GO

CREATE function [dbo].[fncRecupera_Numeros](@str varchar(500))  
returns varchar(500)  
begin  
	declare @startingIndex int  
	set @startingIndex=0  
	while 1=1  
	begin  
		set @startingIndex= patindex('%[^0-9]%',@str)  
		if @startingIndex <> 0  
		begin  
			set @str = replace(@str,substring(@str,@startingIndex,1),'')  
		end  
		else    break;   
	end  

	return NULLIF(@str, '')

end
GO



CREATE FUNCTION [dbo].[fncValida_CPF](@Nr_Documento [varchar](11))
RETURNS [bit]
AS 
BEGIN

    
    IF (ISNUMERIC(@Nr_Documento) = 0)
        RETURN 0


    DECLARE
        @Contador_1 INT,
        @Contador_2 INT,
        @Digito_1 INT,
        @Digito_2 INT,
        @Nr_Documento_Aux VARCHAR(11)

    SET @Nr_Documento_Aux = LTRIM(RTRIM(@Nr_Documento))
    SET @Digito_1 = 0

    IF LEN(@Nr_Documento_Aux) <> 11
        RETURN 0
    ELSE
    BEGIN

        -- Cálculo do segundo dígito
        SET @Nr_Documento_Aux = SUBSTRING(@Nr_Documento_Aux, 1, 9)

        SET @Contador_1 = 2

        WHILE @Contador_1 <= 10
        BEGIN 
            SET @Digito_1 = @Digito_1 + ( @Contador_1 * CAST(SUBSTRING(@Nr_Documento_Aux, 11 - @Contador_1, 1) AS INT) )
            SET @Contador_1 = @Contador_1 + 1
        END 

        SET @Digito_1 = @Digito_1 - ( @Digito_1 / 11 ) * 11

        IF @Digito_1 <= 1
            SET @Digito_1 = 0
        ELSE
            SET @Digito_1 = 11 - @Digito_1

        SET @Nr_Documento_Aux = @Nr_Documento_Aux + CAST(@Digito_1 AS VARCHAR(1))

        IF @Nr_Documento_Aux <> SUBSTRING(@Nr_Documento, 1, 10)
            RETURN 0
        ELSE 
        BEGIN 

            -- Cálculo do segundo dígito
            SET @Digito_2 = 0
            SET @Contador_2 = 2

            WHILE (@Contador_2 <= 11)
            BEGIN 
                SET @Digito_2 = @Digito_2 + ( @Contador_2 * CAST(SUBSTRING(@Nr_Documento_Aux, 12 - @Contador_2, 1) AS INT) )
                SET @Contador_2 = @Contador_2 + 1
            END 

            SET @Digito_2 = @Digito_2 - ( @Digito_2 / 11 ) * 11


            IF @Digito_2 < 2
                SET @Digito_2 = 0
            ELSE
                SET @Digito_2 = 11 - @Digito_2
    

            SET @Nr_Documento_Aux = @Nr_Documento_Aux + CAST(@Digito_2 AS VARCHAR(1))


            IF @Nr_Documento_Aux <> @Nr_Documento
                RETURN 0

        END
                    
    END

    RETURN 1

END
GO



CREATE FUNCTION [dbo].[fncSplit] ( @String varchar(8000), @Separador varchar(8000), @PosBusca int )
RETURNS varchar(8000)
AS BEGIN
	
	DECLARE @Index int, @Max int, @Retorno varchar(8000)

	DECLARE @Partes as TABLE ( Id_Parte int identity(1,1), Texto varchar(8000) )

	SET @Index = charIndex(@Separador,@String)

	WHILE (@Index > 0) BEGIN	
		INSERT INTO @Partes SELECT SubString(@String,1,@Index-1)
		SET @String = Rtrim(Ltrim(SubString(@String,@Index+Len(@Separador),Len(@String))))
		SET @Index = charIndex(@Separador,@String)
	END

	IF (@String != '') INSERT INTO @Partes SELECT @String

	SELECT @Max = Count(*) FROM @Partes

	IF (@PosBusca = 0) SET @Retorno = Cast(@Max as varchar(5))
	IF (@PosBusca < 0) SET @PosBusca = @Max + 1 + @PosBusca
	IF (@PosBusca > 0) SELECT @Retorno = Texto FROM @Partes WHERE Id_Parte = @PosBusca

	RETURN Rtrim(Ltrim(@Retorno))

END
GO



------------------

SELECT TOP 10000 CLR.dbo.fncRecupera_Numeros(CPF)
FROM dbo.Teste

SELECT TOP 10000 dirceuresende.dbo.fncRecupera_Numeros(CPF)
FROM dbo.Teste

------------------

SELECT COUNT(*)
FROM dbo.Teste_1k
WHERE CLR.dbo.fncValida_CPF(CPF) = 1

SELECT COUNT(*)
FROM dbo.Teste_1k
WHERE dirceuresende.dbo.fncValida_CPF(CPF) = 1

------------------

SELECT COUNT(*)
FROM dbo.Teste_1k
WHERE CLR.dbo.fncSplit(Primeiro_Nome + '|' + Ultimo_Nome, '|', 1) = 'Dirceu'

SELECT COUNT(*)
FROM dbo.Teste_1k
WHERE dirceuresende.dbo.fncSplit(Primeiro_Nome + '|' + Ultimo_Nome, '|', 1) = 'Dirceu'


----------------------------------------------
-- Analise os tipos de dados das colunas que são comparadas (Conversão)
----------------------------------------------

SELECT *
FROM dbo.Teste
WHERE CPF = '11111111111'

SELECT *
FROM dbo.Teste
WHERE CPF = 11111111111




----------------------------------------------
-- Analise os tipos de dados das colunas que são comparadas (Conversão)
----------------------------------------------

CREATE FUNCTION [dbo].[fncPrimeiroDiaMes](@Dt_Referencia DATETIME)
RETURNS DATETIME
AS
BEGIN
    RETURN DATEADD(DAY,-(DAY(@Dt_Referencia)-1), CAST(FLOOR(CAST(@Dt_Referencia AS FLOAT)) AS DATETIME))
END
GO


SELECT TOP 50000 *
INTO dbo.Teste_50k
FROM dbo.Teste
ORDER BY NEWID()
GO

-------------------------


SELECT COUNT(*) 
FROM dbo.Teste_50k
WHERE dbo.fncUltimoDiaMes(Dt_Nascimento) = '1987-05-31'


SELECT COUNT(*) 
FROM dbo.Teste_50k
WHERE dateadd(day,-1,dateadd(month,+1,DATEADD(DAY,-(DAY(Dt_Nascimento)-1), CAST(FLOOR(CAST(Dt_Nascimento AS FLOAT)) AS DATETIME)))) = '1987-05-31'



SELECT TOP 100000 dbo.fncUltimoDiaMes(Dt_Nascimento)
FROM dbo.Teste_50k


SELECT TOP 100000 dateadd(day,-1,dateadd(month,+1,DATEADD(DAY,-(DAY(Dt_Nascimento)-1), CAST(FLOOR(CAST(Dt_Nascimento AS FLOAT)) AS DATETIME))))
FROM dbo.Teste_50k



----------------------------------------------
-- Colunas computadas são indexáveis!
----------------------------------------------

SELECT COUNT(*)
FROM dbo.Teste
WHERE Primeiro_Nome + ' ' + Ultimo_Nome = 'Dirceu Smith'


ALTER TABLE dbo.Teste ADD Nome_Completo AS (Primeiro_Nome + ' ' + Ultimo_Nome)
CREATE NONCLUSTERED INDEX SK07_Teste ON dbo.Teste(Nome_Completo)

SELECT COUNT(*)
FROM dbo.Teste
WHERE Nome_Completo = 'Dirceu Smith'

