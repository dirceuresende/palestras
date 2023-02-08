DECLARE @Teste TABLE ( Nome VARCHAR ( 100 ) COLLATE SQL_Latin1_General_CP1_CS_AS )
INSERT INTO @Teste VALUES ( 'Dirceu' ) , ( 'dirceu' ) , ( 'Diego' ) , ( 'Diogo' ) , ( 'Diógenes' ) , ( 'Daniel' ) , ( 'DAniel' )
   
-- Like COMUM , utilizando a collation do banco
SELECT *
FROM @Teste
WHERE Nome LIKE 'dir%'

-- Retorna linhas onde a primeira letra seja "d" , a segunda seja "i" e a terceira seja "r"
SELECT *
FROM @Teste
WHERE Nome LIKE '[d][i][r]%'

-- Retorna linhas onde a primeira letra seja "D", a segunda seja "i" e a terceira seja "r"
SELECT *
FROM @Teste
WHERE Nome LIKE '[D][i][r]%'

-- Retorna linhas onde a primeira letra seja "D" ou "d" e a segunda seja "I" ou "i"
SELECT *
FROM @Teste
WHERE Nome LIKE '[D-d][I-i]%'



DECLARE @Teste TABLE ( Nome VARCHAR ( 100 ) COLLATE SQL_Latin1_General_CP1_CS_AS )
INSERT INTO @Teste VALUES ( 'Dirceu' ), ( 'Maria' ) , ( 'Khloe' ) , ( 'Sofía' )

-- Recuperando nomes que a primeira letra é " D " , " P " ou " 1 " ( minúsculo )
SELECT *
FROM @Teste
WHERE Nome LIKE '[DM]%'


DECLARE @Teste TABLE ( Nome VARCHAR ( 100 ) COLLATE Latini General BIN )
INSERT INTO @Teste VALUES ( 'Dirceu' ) , ( 'Maria' ) , ( 'Khloe' ) , ( 'Sofía' ) , ( 'D' ) , ( 'DI' ) , ( 'S9' ) , ( 's9' ) , ( 'ZF' ) , ( '9S' ) , ( '?A' ) , ( '@4' ) , ( 'J' )


-- Recuperando nomes que possuem apenas 1 letra .
SELECT *
FROM @Teste
WHERE Nome LIKE '[A-Z]'

-- Recuperando nomes que possuem apenas 2 caracteres : O primeiro será uma letra e o segundo um número
SELECT *
FROM @Teste
WHERE Nome LIKE '[A-Z][0-9]'

-- Recuperando nomes que possuem apenas 2 caracteres : O primeiro será uma letra ( minúscula ) e o segundo um número
SELECT *
FROM @Teste
WHERE Nome LIKE '[a-z][0-9]'
