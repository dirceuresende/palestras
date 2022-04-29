/*

IF (OBJECT_ID('_Clientes') IS NOT NULL) DROP TABLE _Clientes
CREATE TABLE _Clientes (
    Id_Cliente INT IDENTITY(1,1),
    Dados_Serializados VARCHAR(200)
)

INSERT INTO _Clientes ( Dados_Serializados )
SELECT
    CONVERT(VARCHAR(19), DATEADD(SECOND, (ABS(CHECKSUM(PWDENCRYPT(N''))) / 2147483647.0) * 199999999, '2015-01-01'), 121) + '|' +
    CONVERT(VARCHAR(20), CONVERT(INT, (ABS(CHECKSUM(PWDENCRYPT(N''))) / 2147483647.0) * 9)) + '|' +
    CONVERT(VARCHAR(20), CONVERT(INT, (ABS(CHECKSUM(PWDENCRYPT(N''))) / 2147483647.0) * 10)) + '|' +
    CONVERT(VARCHAR(20), CONVERT(INT, 0.459485495 * (ABS(CHECKSUM(PWDENCRYPT(N''))) / 2147483647.0)) * 1999)
GO 100000

INSERT INTO _Clientes ( Dados_Serializados )
SELECT Dados_Serializados
FROM _Clientes
GO 9

CREATE CLUSTERED INDEX SK01_Pedidos ON _Clientes(Id_Cliente)
CREATE NONCLUSTERED INDEX SK02_Pedidos ON _Clientes(Dados_Serializados)
GO


ALTER TABLE _Clientes ADD Dados_Serializados_N NVARCHAR(200)
GO

UPDATE _Clientes
SET Dados_Serializados_N = Dados_Serializados

CREATE NONCLUSTERED INDEX SK03_Pedidos ON _Clientes(Dados_Serializados_N)

*/










/*

-- Criar uma tabela menor para alguns exemplos
IF (OBJECT_ID('_Clientes2') IS NOT NULL) DROP TABLE _Clientes2
SELECT TOP(100000) *
INTO _Clientes2
FROM _Clientes
GO

CREATE CLUSTERED INDEX SK01_Clientes2 ON _Clientes2(Id_Cliente)
CREATE NONCLUSTERED INDEX SK02_Clientes2 ON _Clientes2(Dados_Serializados)
GO

CREATE OR ALTER FUNCTION [dbo].[fncSplit] ( @String varchar(8000), @Separador varchar(8000), @PosBusca int )
RETURNS varchar(8000)
WITH SCHEMABINDING
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

    RETURN RTRIM(LTRIM(@Retorno))

END
GO


*/






/*

IF (OBJECT_ID('dbo.Vendas') IS NOT NULL) DROP TABLE dbo.Vendas
CREATE TABLE dbo.Vendas (
    Id_Pedido INT IDENTITY(1,1),
    Dt_Pedido DATETIME,
    [Status] INT,
    Quantidade INT,
    Valor NUMERIC(18, 2)
)

CREATE CLUSTERED INDEX SK01_Pedidos ON dbo.Vendas(Id_Pedido)
CREATE NONCLUSTERED INDEX SK02_Pedidos ON dbo.Vendas ([Status], Dt_Pedido) INCLUDE(Quantidade, Valor)
GO

INSERT INTO dbo.Vendas ( Dt_Pedido, [Status], Quantidade, Valor )
SELECT
    DATEADD(SECOND, (ABS(CHECKSUM(PWDENCRYPT(N''))) / 2147483647.0) * 199999999, '2015-01-01'),
    (ABS(CHECKSUM(PWDENCRYPT(N''))) / 2147483647.0) * 9,
    (ABS(CHECKSUM(PWDENCRYPT(N''))) / 2147483647.0) * 10,
    0.459485495 * (ABS(CHECKSUM(PWDENCRYPT(N''))) / 2147483647.0) * 1999
GO 10000


INSERT INTO dbo.Vendas ( Dt_Pedido, [Status], Quantidade, Valor )
SELECT Dt_Pedido, [Status], Quantidade, Valor FROM dbo.Vendas
GO 9

*/






/*

CREATE OR ALTER FUNCTION dbo.fncRand(
    @Numero BIGINT
)
RETURNS BIGINT
AS
BEGIN
    RETURN (ABS(CHECKSUM(PWDENCRYPT(N''))) / 2147483647.0) * @Numero
END
GO


IF (OBJECT_ID('dbo.Teste_Performance') IS NOT NULL) DROP TABLE dbo.Teste_Performance
CREATE TABLE dbo.Teste_Performance (
    Id INT IDENTITY(1, 1),
    Nome VARCHAR(200),
    Numero INT,
    [Data] DATETIME,
    Observacao VARCHAR(MAX),
    CPF VARCHAR(11)
)

INSERT INTO dbo.Teste_Performance ( Nome, Numero, [Data], Observacao, CPF )
SELECT 
    CAST(NEWID() AS VARCHAR(50)),
    dbo.fncRand(99999999),
    DATEADD(SECOND, (CAST(RAND() * 31536000 AS INT)), '2017-01-01') AS Dt_Venda,
    CAST(NEWID() AS VARCHAR(50)) + ';' + CAST(NEWID() AS VARCHAR(50)) + ';' + CAST(NEWID() AS VARCHAR(50)),
    RIGHT(REPLICATE('0', 11) + CAST(dbo.fncRand(99999999999) AS VARCHAR(11)), 11) AS CPF
GO


DECLARE @Contador INT = 1, @Total INT = 21


WHILE(@Contador <= @Total)
BEGIN
 
    INSERT INTO dbo.Teste_Performance ( Nome, Numero, [Data], Observacao, CPF )
    SELECT 
        CAST(NEWID() AS VARCHAR(50)),
        dbo.fncRand(99999999),
        DATEADD(SECOND, (CAST(RAND() * 31536000 AS INT)), '2017-01-01') AS Dt_Venda,
        CAST(NEWID() AS VARCHAR(50)) + ';' + CAST(NEWID() AS VARCHAR(50)) + ';' + CAST(NEWID() AS VARCHAR(50)),
        RIGHT(REPLICATE('0', 11) + CAST(dbo.fncRand(99999999999) AS VARCHAR(11)), 11) AS CPF
    FROM
        dbo.Teste_Performance


    SET @Contador += 1
 

END
GO


CREATE OR ALTER FUNCTION [dbo].[fncValida_CPF](@Nr_Documento [varchar](11))
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


CREATE OR ALTER function [dbo].[fncRecupera_Numeros](@str varchar(500))  
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

*/
