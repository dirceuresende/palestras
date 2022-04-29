

IF (OBJECT_ID('dbo.fncRand') IS NULL) EXEC('CREATE FUNCTION dbo.fncRand(@a INT) RETURNS INT AS BEGIN RETURN 1 END')
GO

ALTER FUNCTION dbo.fncRand(
    @Numero BIGINT
)
RETURNS BIGINT
AS
BEGIN
    RETURN (ABS(CHECKSUM(PWDENCRYPT(N''))) / 2147483647.0) * @Numero
END
GO



------------------------------------------------------------------------
-- CRIAÇÃO DAS DIMENSÕES
------------------------------------------------------------------------

IF (OBJECT_ID('dim.Cliente') IS NULL)
BEGIN

	-- DROP TABLE dim.Cliente
	CREATE TABLE dim.Cliente (
		Id_Cliente INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		Nome VARCHAR(50) NOT NULL,
		Dt_Nascimento DATE NOT NULL,
		Estado VARCHAR(2) NOT NULL,
		Idade AS (CONVERT(INT, DATEDIFF(DAY, Dt_Nascimento, GETDATE()) / 365.25))
	) WITH(DATA_COMPRESSION=PAGE)
	
	
	;WITH random AS (
		SELECT 
			dbo.fncRand(10) + 1 AS randomPrimeiroNome,
			dbo.fncRand(10) + 1 AS randomSegundoNome,
			dbo.fncRand(10) + 1 AS randomEstado
		FROM
			msdb.sys.all_columns
	)
	INSERT INTO dim.Cliente
	SELECT
		CONCAT(CHOOSE(random.randomPrimeiroNome, 'João', 'Daniel', 'Pedro', 'Josué', 'Matheus', 'Paulo', 'Moisés', 'Arão', 'Elias', 'José'), ' ', CHOOSE(random.randomSegundoNome, 'Resende', 'Silva', 'Sousa', 'Rosa', 'Nascimento', 'Dias', 'Mendonça', 'Garcia', 'Lacerda', 'Lima')) AS Nome,
		DATEADD(DAY, dbo.fncRand(11000), '1990-01-01') AS randomDataNascimento,
		CHOOSE(random.randomEstado, 'ES', 'RJ', 'SP', 'MG', 'DF', 'SC', 'MT', 'GO', 'CE', 'AM')
	FROM 
		random


END



SET IDENTITY_INSERT dim.Cliente ON

INSERT INTO dim.Cliente (Id_Cliente, Nome, Dt_Nascimento, Estado)
VALUES(0, 'Não informado', '1900-01-01', 'NI')

SET IDENTITY_INSERT dim.Cliente OFF





IF (OBJECT_ID('dim.Produto') IS NOT NULL) DROP TABLE dim.Produto
CREATE TABLE dim.Produto (
	Codigo INT IDENTITY(1, 1),
	Nome VARCHAR(100),
	Peso INT,
	Categoria VARCHAR(50),
	Preco FLOAT
)
 
INSERT INTO dim.Produto
VALUES
	('Toalha', 25, 'Cama, Mesa e Banho', 19.99),
	('TV 55', 3200, 'Eletro', 3500),
	('TV 42', 2500, 'Eletro', 2359.70),
	('Celular Top Android Novo', 120, 'Celulares', 1890),
	('Celular Top iOS Usado', 114, 'Celulares', 4999.99),
	('Cama Box', 7510, 'Cama, Mesa e Banho', 1249.99),
	('Toalha de Rosto', 15, 'Cama, Mesa e Banho', 12.99),
	('Prato', 250, 'Cozinha', 34.80),
	('Talher', 25, 'Cozinha', 22.50),
	('Panela', 250, 'Cozinha', 69.80),
	('Microondas', 1450, 'Eletro', 369.99),
	('Encosto de Mesa', 35, 'Cama, Mesa e Banho', 15.50)
	
	

------------------------------------------------------------------------
-- CRIAÇÃO DA FATO
------------------------------------------------------------------------

IF (OBJECT_ID('fato.Venda') IS NOT NULL) DROP TABLE fato.Venda
CREATE TABLE fato.Venda (
    Cod_Cliente INT,
    Cod_Produto INT,
    Dt_Venda DATETIME,
	Quantidade INT,
    Vl_Venda FLOAT
)


DECLARE
    @Contador INT = 1, 
	@Total INT = 30, 
	@Max_Cliente INT = (SELECT MAX(Id_Cliente) FROM dim.Cliente)
	

WHILE(@Contador <= @Total)
BEGIN
    
	
    
    INSERT INTO fato.Venda
    SELECT
        dbo.fncRand(@Max_Cliente + 1) AS Cod_Cliente,
        Codigo AS Cod_Produto,
        DATEADD(DAY, dbo.fncRand(1885), '2012-01-01') AS Dt_Venda,
		dbo.fncRand(10 + 1) AS Quantidade,
        Preco AS Vl_Venda
    FROM
		dim.Produto
    

    SET @Contador += 1


END



-- DECLARE @Contador INT, @Total INT, @Max_Cliente INT = (SELECT MAX(Id_Cliente) FROM dim.Cliente)

SELECT @Contador = 1, @Total = 3

WHILE(@Contador <= @Total)
BEGIN
    
    INSERT INTO fato.Venda
    SELECT
        dbo.fncRand(@Max_Cliente + 1) AS Cod_Cliente,
        Cod_Produto,
        DATEADD(DAY, dbo.fncRand(1885), '2012-01-01') AS Dt_Venda,
		dbo.fncRand(10 + 1) AS Quantidade,
        Vl_Venda
    FROM
		fato.Venda
    

    SET @Contador += 1


END

