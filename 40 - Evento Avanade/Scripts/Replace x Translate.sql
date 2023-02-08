DECLARE @Texto VARCHAR(100) = 'Testando essa string com c4r4ct3r3$ 3$p3c141$'

-- O QUE EU QUERO?
-- SUBSTITUIR "4" por "a" | "3" por "e" | "$" por "s" | "1" por "i"

-- REPLACE
SELECT REPLACE(REPLACE(REPLACE(REPLACE(@Texto, '4', 'a'), '3', 'e'), '$', 's'), '1', 'i') AS [REPLACE]

-- TRANSLATE
SELECT TRANSLATE(@Texto, '43$1', 'aesi') AS [TRANSLATE]



DECLARE 
    @Texto VARCHAR(100) = 'Testando essa string com ca$r@a@c%t&e(r)e+s e!s~p^e`c´i<a>i:s;?ª{}',
    @Encontrar VARCHAR(100) = '$@%&()+!~^`´<>:;?ª{}',
    @Substituir VARCHAR(100) = ''

SET @Substituir = REPLICATE(' ', LEN(@Encontrar))


-- REPLACE
SELECT
    REPLACE( REPLACE( REPLACE( REPLACE( 
        REPLACE( REPLACE( REPLACE( REPLACE( 
            REPLACE( REPLACE( REPLACE( REPLACE( 
                REPLACE( REPLACE( REPLACE( REPLACE( 
                    REPLACE( REPLACE( REPLACE( REPLACE( @Texto, '$', '' ), 
                '@', '' ), '%', '' ), '&', '' ), '(', '' ), 
            ')', '' ), '+', '' ), '!', '' ), '~', '' ), '^', '' ), 
        '`', '' ), '´', '' ), '<', '' ), '>', '' ), ':', '' ), 
    ';', '' ), '?', '' ), 'ª', '' ), '{', '' ), '}', '' );



-- TRANSLATE
SELECT TRANSLATE(@Texto, @Encontrar, @Substituir)




DECLARE 
    @Texto VARCHAR(100) = 'Testando essa string com ca$r@a@c%t&e(r)e+s e!s~p^e`c´i<a>i:s;?ª{}',
    @Encontrar VARCHAR(100) = '$@%&()+!~^`´<>:;?ª{}',
    @Substituir VARCHAR(100) = ''

-- TRANSLATE
SELECT TRANSLATE(@Texto, @Encontrar, REPLICATE(@Substituir, LEN(@Encontrar)))



DECLARE 
    @Texto VARCHAR(100) = 'Testando essa string com ca$r@a@c%t&e(r)e+s e!s~p^e`c´i<a>i:s;?ª{}',
    @Encontrar VARCHAR(100) = '$@%&()+!~^`´<>:;?ª{}',
    @Substituir VARCHAR(100) = CHAR(0)

-- TRANSLATE + REPLACE
SELECT 
    REPLACE(
        TRANSLATE(@Texto, @Encontrar, REPLICATE(@Substituir, LEN(@Encontrar))), 
    @Substituir, '')





SELECT
    [V].[AccountNumber],
	REPLACE(TRANSLATE( [V].[AccountNumber], '0123456789', REPLICATE( CHAR( 0 ), 10)), CHAR(0), '') AS AccountNumberSemNumeros,
    REPLACE(TRANSLATE( [V].[AccountNumber], 'ABCDEFGHIJLMNOPQRSTUVXZWYK', REPLICATE( CHAR(0), 26)), CHAR(0), '') AS AccountNumberSemLetras
FROM
    AdventureWorks2019.[Purchasing].[Vendor] AS [V]
    
