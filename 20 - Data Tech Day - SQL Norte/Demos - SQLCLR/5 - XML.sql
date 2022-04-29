
DECLARE @XML_Bruto VARCHAR(MAX) = CLR.dbo.fncArquivo_Ler_Retorna_String('D:\Exemplo.xml')

IF (OBJECT_ID('tempdb..#XML') IS NOT NULL) DROP TABLE #XML
CREATE TABLE #XML (
    Ds_XML VARCHAR(MAX)
)

INSERT INTO #XML
SELECT @XML_Bruto


SET @XML_Bruto = CLR.dbo.fncArquivo_Ler_Retorna_String('D:\Aluno.xml')

IF (OBJECT_ID('tempdb..#XML2') IS NOT NULL) DROP TABLE #XML2
CREATE TABLE #XML2 (
    Ds_XML VARCHAR(MAX)
)

INSERT INTO #XML2
SELECT @XML_Bruto


---------------------------------------------------------------------------------------------------


DECLARE @XML XML = (SELECT TOP 1 Ds_XML FROM #XML)
 
SELECT
    @XML.value('(/Root/Cliente[1]/@Nome)[1]','varchar(100)') AS Cliente1_Nome,
    @XML.value('(/Root/Cliente[1]/@Idade)[1]','int') AS Cliente1_Idade,
    @XML.value('(/Root/Cliente[1]/@CPF)[1]','varchar(100)') AS Cliente1_CPF,
    @XML.value('(/Root/Cliente[1]/@Email)[1]','varchar(100)') AS Cliente1_Email,
    @XML.value('(/Root/Cliente[1]/@Celular)[1]','varchar(100)') AS Cliente1_Celular,
 
    @XML.value('(/Root/Cliente[1]/Endereco[1]/@Cidade)[1]','varchar(100)') AS Cliente1_Endereco1_Cidade,
    @XML.value('(/Root/Cliente[1]/Endereco[2]/@Cidade)[1]','varchar(100)') AS Cliente1_Endereco2_Cidade
 
 
SELECT
    @XML.value('(/Root/Cliente[2]/@Nome)[1]','varchar(100)') AS Cliente2_Nome,
    @XML.value('(/Root/Cliente[2]/@Idade)[1]','int') AS Cliente2_Idade,
    @XML.value('(/Root/Cliente[2]/@CPF)[1]','varchar(100)') AS Cliente2_CPF,
    @XML.value('(/Root/Cliente[2]/@Email)[1]','varchar(100)') AS Cliente2_Email,
    @XML.value('(/Root/Cliente[2]/@Celular)[1]','varchar(100)') AS Cliente2_Celular,
 
    @XML.value('(/Root/Cliente[2]/Endereco[1]/@Cidade)[1]','varchar(100)') AS Cliente1_Endereco1_Cidade,
    @XML.value('(/Root/Cliente[2]/Endereco[2]/@Cidade)[1]','varchar(100)') AS Cliente1_Endereco2_Cidade
    
    
---------------------------------------------------------------------------------------------------


DECLARE @XML XML = (SELECT TOP 1 Ds_XML FROM #XML)

SELECT
    Clientes.linha.value('@Nome','varchar(100)') AS Nome,
    Clientes.linha.value('@Idade','int') AS Idade,
    Clientes.linha.value('@CPF','varchar(14)') AS CPF,
    Clientes.linha.value('@Email','varchar(200)') AS Email,
    Clientes.linha.value('@Celular','varchar(20)') AS Celular
FROM   
    @XML.nodes('/Root/Cliente') Clientes(linha)
    
    
---------------------------------------------------------------------------------------------------
    
    
DECLARE @XML XML = (SELECT TOP 1 Ds_XML FROM #XML)

SELECT
    @XML.exist('(/Root/Cliente[1]/@Nome)[1]') AS Cliente1_Existe,
    @XML.exist('(/Root/Cliente[2]/@Nome)[1]') AS Cliente2_Existe,
    @XML.exist('(/Root/Cliente[3]/@Nome)[1]') AS Cliente3_Existe
    
    
---------------------------------------------------------------------------------------------------
    
    
DECLARE @XML XML = (SELECT TOP 1 Ds_XML FROM #XML)

SELECT

    (CASE WHEN @XML.exist('(/Root/Cliente[1]/@Nome)[1]') = 1 
        THEN @XML.value('(/Root/Cliente[1]/@Nome)[1]', 'varchar(100)') 
        ELSE 'Não existe' 
    END) AS Cliente1_Nome,

    (CASE WHEN @XML.exist('(/Root/Cliente[2]/@Nome)[1]') = 1 
        THEN @XML.value('(/Root/Cliente[2]/@Nome)[1]', 'varchar(100)') 
        ELSE 'Não existe' 
    END) AS Cliente2_Nome,

    (CASE WHEN @XML.exist('(/Root/Cliente[3]/@Nome)[1]') = 1 
        THEN @XML.value('(/Root/Cliente[3]/@Nome)[1]', 'varchar(100)') 
        ELSE 'Não existe' 
    END) AS Cliente3_Nome
    
    
---------------------------------------------------------------------------------------------------

    
DECLARE @XML XML = (SELECT TOP 1 Ds_XML FROM #XML)

SELECT
    Clientes.linha.value('@Nome','varchar(100)') AS Nome,
    Clientes.linha.value('@Idade','int') AS Idade,
    Clientes.linha.value('@CPF','varchar(14)') AS CPF,
    Clientes.linha.value('@Email','varchar(200)') AS Email,
    Clientes.linha.value('@Celular','varchar(20)') AS Celular,

    Enderecos.linha.value('@Cidade','varchar(60)') AS Cidade,
    Enderecos.linha.value('@Estado','varchar(2)') AS UF,
    Enderecos.linha.value('@Pais','varchar(50)') AS Pais,
    Enderecos.linha.value('@CEP','varchar(10)') AS CEP
FROM
    @XML.nodes('/Root/Cliente') Clientes(linha)
    CROSS APPLY Clientes.linha.nodes('Endereco') Enderecos(linha)
    
    
---------------------------------------------------------------------------------------------------

-- ERRO NO RETORNO: TEM ENDEREÇO SEM TELEFONE E QUE NÃO RETORNOU...

DECLARE @XML XML = (SELECT TOP 1 Ds_XML FROM #XML)

SELECT
    Clientes.linha.value('@Nome','varchar(100)') AS Nome,
    Clientes.linha.value('@Idade','int') AS Idade,
    Clientes.linha.value('@CPF','varchar(14)') AS CPF,
    Clientes.linha.value('@Email','varchar(200)') AS Email,
    Clientes.linha.value('@Celular','varchar(20)') AS Celular,

    Enderecos.linha.value('@Cidade','varchar(60)') AS Cidade,
    Enderecos.linha.value('@Estado','varchar(2)') AS UF,
    Enderecos.linha.value('@Pais','varchar(50)') AS Pais,
    Enderecos.linha.value('@CEP','varchar(10)') AS CEP,

    Telefones.linha.value('@Fixo','varchar(20)') AS Telefone_Fixo,
    Telefones.linha.value('@Piscina','varchar(20)') AS Tem_Piscina,
    Telefones.linha.value('@Quintal','varchar(20)') AS Tem_Quintal,
    Telefones.linha.value('@Quadra','varchar(20)') AS Tem_Quadra,
    Telefones.linha.value('@NaoExiste','varchar(20)') AS Atributo_Nao_Existe
FROM
    @XML.nodes('/Root/Cliente') Clientes(linha)
    CROSS APPLY Clientes.linha.nodes('Endereco') Enderecos(linha)
    CROSS APPLY Enderecos.linha.nodes('Telefone') Telefones(linha)
    
    
---------------------------------------------------------------------------------------------------
    
    
DECLARE @XML XML = (SELECT TOP 1 Ds_XML FROM #XML)

SELECT
    Clientes.linha.value('@Nome','varchar(100)') AS Nome,
    Clientes.linha.value('@Idade','int') AS Idade,
    Clientes.linha.value('@CPF','varchar(14)') AS CPF,
    Clientes.linha.value('@Email','varchar(200)') AS Email,
    Clientes.linha.value('@Celular','varchar(20)') AS Celular,

    Enderecos.linha.value('@Cidade','varchar(60)') AS Cidade,
    Enderecos.linha.value('@Estado','varchar(2)') AS UF,
    Enderecos.linha.value('@Pais','varchar(50)') AS Pais,
    Enderecos.linha.value('@CEP','varchar(10)') AS CEP,

    Telefones.linha.value('@Fixo','varchar(20)') AS Telefone_Fixo,
    Telefones.linha.value('@Piscina','varchar(20)') AS Tem_Piscina,
    Telefones.linha.value('@Quintal','varchar(20)') AS Tem_Quintal,
    Telefones.linha.value('@Quadra','varchar(20)') AS Tem_Quadra,
    Telefones.linha.value('@NaoExiste','varchar(20)') AS Atributo_Nao_Existe
FROM
    @XML.nodes('/Root/Cliente') Clientes(linha)
    CROSS APPLY Clientes.linha.nodes('Endereco') Enderecos(linha)
    OUTER APPLY Enderecos.linha.nodes('Telefone') Telefones(linha)
    
    
---------------------------------------------------------------------------------------------------
    
    
DECLARE @XML XML = (SELECT TOP 1 Ds_XML FROM #XML2)

SELECT 
    @XML.value('(Escola/Turma/Aluno)[1]', 'varchar(60)') AS Aluno1,
    @XML.value('(Escola/Turma/Aluno)[2]', 'varchar(60)') AS Aluno2,
    @XML.value('(Escola/Turma/Aluno)[3]', 'varchar(60)') AS Aluno3,
    @XML.value('(Escola/Turma/Aluno)[4]', 'varchar(60)') AS Aluno4,
    @XML.value('(Escola/Turma/Aluno)[5]', 'varchar(60)') AS Aluno5,
    @XML.value('(Escola/Turma/Aluno)[6]', 'varchar(60)') AS Aluno6,
    @XML.value('(Escola/Turma/Aluno)[14]', 'varchar(60)') AS Aluno14_Nao_Existe
    
    
---------------------------------------------------------------------------------------------------


DECLARE @XML XML = (SELECT TOP 1 Ds_XML FROM #XML2)

SELECT
    Alunos.linha.value('.','varchar(100)') AS Nome
FROM
    @XML.nodes('/Escola/Turma/Aluno') Alunos(linha)
    
    
---------------------------------------------------------------------------------------------------   


DECLARE @XML XML = (SELECT TOP 1 Ds_XML FROM #XML2)

SELECT
    Alunos.linha.value('.', 'varchar(60)') AS Aluno,

    Turmas.linha.value('@Nome','varchar(100)') AS Turma,
    Turmas.linha.value('@Serie','int') AS Serie,

    (CASE WHEN Alunos.linha.value('@Apostolo','varchar(60)') = '1' THEN 'SIM' ELSE 'NÃO' END) AS Apostolo,
    (CASE WHEN Alunos.linha.value('@Traidor','varchar(2)') = '1' THEN 'SIM' ELSE 'NÃO' END) AS Traidor
FROM
    @XML.nodes('/Escola/Turma') Turmas(linha)
    CROSS APPLY Turmas.linha.nodes('Aluno') Alunos(linha)


---------------------------------------------------------------------------------------------------


DECLARE @XML XML = (SELECT TOP 1 Ds_XML FROM #XML2)

SELECT
    @XML.query('.') AS XML_Completo,
    @XML.query('Escola/Turma[1]/Aluno[1]') AS XML_Turma1_Aluno1,
    @XML.query('Escola/Turma[1]/Aluno[1]/text()') AS XML_Turma1_Aluno1_Nome,
    @XML.query('Escola/Turma[1]/Aluno[1]').value('.', 'varchar(100)') AS Turma1_Aluno1_Nome
    

---------------------------------------------------------------------------------------------------


DECLARE @XML XML = (SELECT TOP 1 Ds_XML FROM #XML2)

SELECT
    @XML.query('Escola/Turma[@Serie=''2'']') AS XML_Turma_2a_Serie,
    @XML.query('Escola/Turma[@Nome=''Turma 1'']') AS XML_Turma1,
    @XML.query('Escola/Turma/Aluno[@Traidor=''1'']') AS XML_Judas,
    @XML.query('Escola/Turma/Aluno[@Apostolo=''0'']') AS XML_Paulo,
    @XML.query('Escola/Turma/Aluno[.=''Pedro'']') AS XML_Pedro
    
    
---------------------------------------------------------------------------------------------------


DECLARE @XML XML = (SELECT TOP 1 Ds_XML FROM #XML2)
DECLARE @XML2 XML = (SELECT @XML.query('Escola/Turma/Aluno[.=''Pedro'']'))

SELECT 
    Alunos.linhas.value('.', 'varchar(100)') AS Nome,
    Alunos.linhas.value('@Nota', 'float') AS Nota,
    Alunos.linhas.value('@Apostolo', 'bit') AS Apostolo,
    Alunos.linhas.value('@Traidor', 'bit') AS Apostolo
FROM 
    @XML2.nodes('/Aluno') AS Alunos(linhas)
    
    
---------------------------------------------------------------------------------------------------
    
    
DECLARE @XML XML = (SELECT TOP 1 Ds_XML FROM #XML2)

DECLARE @XML_Aprovados XML = (SELECT @XML.query('//Aluno[@Nota>=7]'))
DECLARE @XML_Reprovados XML = (SELECT @XML.query('//Aluno[@Nota<7]'))

SELECT 
    Alunos.linhas.value('.', 'varchar(100)') AS Nome,
    Alunos.linhas.value('@Nota', 'float') AS Nota,
    Alunos.linhas.value('@Apostolo', 'bit') AS Apostolo,
    Alunos.linhas.value('@Traidor', 'bit') AS Apostolo
FROM 
    @XML_Aprovados.nodes('/Aluno') AS Alunos(linhas)
ORDER BY
    Nota DESC

SELECT 
    Alunos.linhas.value('.', 'varchar(100)') AS Nome,
    Alunos.linhas.value('@Nota', 'float') AS Nota,
    Alunos.linhas.value('@Apostolo', 'bit') AS Apostolo,
    Alunos.linhas.value('@Traidor', 'bit') AS Apostolo
FROM 
    @XML_Reprovados.nodes('/Aluno') AS Alunos(linhas)
ORDER BY
    Nota
    
    

---------------------------------------------------------------------------------------------------

    
    
DECLARE @XML XML = (SELECT TOP 1 Ds_XML FROM #XML2)

SELECT 
    @XML.value('max(//Aluno/@Nota)', 'float') AS Maior_Nota,
    @XML.value('min(//Aluno/@Nota)', 'float') AS Menor_Nota,
    @XML.value('avg(//Aluno/@Nota)', 'float') AS Media_Nota,
    @XML.value('sum(//Aluno/@Nota)', 'float') AS Soma_Nota,
    @XML.value('count(//Aluno/@Nota)', 'int') AS Qtde_Nota,
    @XML.value('count(//Aluno[@Nota>=7]/@Nota)', 'int') AS Qtde_Nota_Maior7,
    @XML.value('count(//Aluno[@Nota<7]/@Nota)', 'int') AS Qtde_Nota_Menor7
    
    
    
---------------------------------------------------------------------------------------------------


DECLARE @XML XML = (SELECT TOP 1 Ds_XML FROM #XML2)

SELECT 
    @XML.value('(//Aluno[.=''Pedro''])[1]', 'varchar(100)') AS Pedro,
    @XML.value('string-length((//Aluno[.=''Pedro''])[1])', 'varchar(100)') AS Tamanho_Nome_Pedro,
    @XML.value('concat((//Aluno[.=''Pedro''])[1], '' Teste'')', 'varchar(100)') AS [Concat],
    @XML.value('substring((//Aluno[.=''Pedro''])[1], 1, 1)', 'varchar(100)') AS [Primeira_Letra]
    
    
---------------------------------------------------------------------------------------------------


DECLARE @XML XML = (SELECT TOP 1 Ds_XML FROM #XML2)

SELECT 
    Alunos.linha.value('.', 'varchar(100)') AS Pedro,
    Alunos.linha.value('string-length((.))', 'varchar(100)') AS Tamanho_Nome_Pedro,
    Alunos.linha.value('concat((.), '' Teste'')', 'varchar(100)') AS [Concat],
    Alunos.linha.value('substring((.), 1, 1)', 'varchar(100)') AS [Primeira_Letra]
FROM
    @XML.nodes('//Aluno') AS Alunos(linha)
WHERE
    Alunos.linha.value('contains((.), "Pedro")', 'bit') = 1
    
    
---------------------------------------------------------------------------------------------------


DECLARE @XML XML = (SELECT TOP 1 Ds_XML FROM #XML2)

SELECT 
    Alunos.linha.value('.', 'varchar(100)') AS Pedro,
    Alunos.linha.value('string-length((.))', 'varchar(100)') AS Tamanho_Nome_Pedro,
    Alunos.linha.value('concat((.), '' Teste'')', 'varchar(100)') AS [Concat],
    Alunos.linha.value('substring((.), 1, 1)', 'varchar(100)') AS [Primeira_Letra]
FROM
    @XML.nodes('//Aluno') AS Alunos(linha)
WHERE
    Alunos.linha.value('.', 'varchar(100)') = 'Pedro'
    
    
    
---------------------------------------------------------------------------------------------------


DECLARE @XML XML = (SELECT TOP 1 Ds_XML FROM #XML2)

SELECT @XML.value('(//Aluno[.="Pedro"]/@Nota)[1]', 'float') AS Nota_Antes


DECLARE @Tabela_XML TABLE ( Dados XML )

INSERT INTO @Tabela_XML
SELECT Ds_Xml FROM #XML2

UPDATE @Tabela_XML
SET Dados.modify('replace value of (//Aluno[.="Pedro"]/@Nota)[1] with("8.5")')

SET @XML = (SELECT TOP 1 Dados FROM @Tabela_XML)

SELECT @XML.value('(//Aluno[.="Pedro"]/@Nota)[1]', 'float') AS Nota_Depois


---------------------------------------------------------------------------------------------------


DECLARE @XML XML = (SELECT TOP 1 Ds_XML FROM #XML2)

SET @XML.modify('insert <Aluno Apostolo="0" Traidor="0" Nota="2.6">Dirceu Turma 1</Aluno>
into (//Turma)[1]')

SET @XML.modify('insert <Aluno Apostolo="0" Traidor="0" Nota="2.9">Dirceu Turma 2</Aluno>
into (//Turma)[2]')

SELECT 
    Alunos.linha.value('.', 'varchar(100)') AS Alunos_Aprovados,
    Alunos.linha.value('@Nota', 'float') AS Nota
FROM @XML.nodes('//Aluno') Alunos(linha)



---------------------------------------------------------------------------------------------------


DECLARE @XML XML = (SELECT TOP 1 Ds_XML FROM #XML2)

DECLARE @XML2 XML = (SELECT @XML.query('for $A in //Aluno[@Nota>=7] return $A'))

SELECT
    Alunos.linha.value('.', 'varchar(100)') AS Nome,
    Alunos.linha.value('@Nota', 'float') AS Nota
FROM
    @XML2.nodes('//Aluno') Alunos(linha)
    
    
    
---------------------------------------------------------------------------------------------------


DECLARE @XML XML = (SELECT TOP 1 Ds_XML FROM #XML2)

DECLARE @XML2 XML = (SELECT @XML.query('
for $A 
in //Aluno
where ($A = "Pedro" or $A = "Marcos" or $A = "Andre" or $A = "Joao")
order by $A descending
return $A'))

SELECT
    Alunos.linha.value('.', 'varchar(100)') AS Nome,
    Alunos.linha.value('@Nota', 'float') AS Nota
FROM
    @XML2.nodes('//Aluno') Alunos(linha)
    
    
---------------------------------------------------------------------------------------------------


IF (OBJECT_ID('dbo.Teste_XML') IS NOT NULL) DROP TABLE dbo.Teste_XML
CREATE TABLE dbo.Teste_XML (
    Categoria VARCHAR(100),
    Descricao VARCHAR(100)
)

INSERT INTO dbo.Teste_XML ( Categoria, Descricao )
VALUES ('Brinquedo', 'Bola'),
('Brinquedo', 'Carrinho'),
('Brinquedo', 'Boneco'),
('Brinquedo', 'Jogo'),
('Cama e Mesa', 'Toalha'),
('Cama e Mesa', 'Edredom'),
('Informatica', 'Teclado'),
('Informatica', 'Mouse'),
('Informatica', 'HD'),
('Informatica', 'CPU'),
('Informatica', 'Memoria'),
('Informatica', 'Placa-Mae'),
(NULL, 'TV')


SELECT *
FROM dbo.Teste_XML
FOR XML RAW


SELECT *
FROM dbo.Teste_XML
FOR XML RAW('Produto'), ROOT('Produtos')


SELECT *
FROM dbo.Teste_XML
FOR XML RAW('Produto'), ROOT('Produtos'), ELEMENTS


SELECT *
FROM dbo.Teste_XML
FOR XML RAW('Produto'), ROOT('Produtos'), ELEMENTS XSINIL


SELECT *
FROM dbo.Teste_XML
FOR XML RAW('Produto'), ROOT('Produtos'), ELEMENTS XSINIL, XMLSCHEMA


SELECT *
FROM dbo.Teste_XML
FOR XML AUTO



SELECT 
    Id AS '@Id_Produto', -- Atributo
    Categoria AS 'DadosProduto/Categoria', -- Elemento
    Descricao AS 'DadosProduto/Descricao'-- Elemento
FROM 
    dbo.Teste_XML
FOR XML PATH('Produto'), ROOT('Produtos'), ELEMENTS



-- Cabeçalho
SELECT 
    1 AS Tag,
   NULL AS Parent,
   NULL AS [Produtos!1!Id],
   NULL AS [Produto!2!Categoria!ELEMENT],
   NULL AS [Produto!2!Descricao!ELEMENT]

UNION ALL

-- Conteúdo
SELECT 
    2 AS Tag,
    1 AS Parent,
    NULL,
    Categoria,
    Descricao
FROM 
    dbo.Teste_XML
FOR	
    XML EXPLICIT
    
    
    
ALTER TABLE dbo.Teste_XML ADD Id INT IDENTITY(1,1)




-- Cabeçalho
SELECT 
    1 AS Tag,
    NULL AS Parent,
    Id AS [Produtos!1!Id_Produto],
    NULL AS [Produto!2!Categoria!ELEMENT],
    NULL AS [Produto!2!Descricao!ELEMENT]
FROM
    dbo.Teste_XML

UNION ALL

-- Conteúdo
SELECT 
    2 AS Tag,
    1 AS Parent,
    Id AS Id_Produto,
    ISNULL(Categoria, ''),
    Descricao
FROM 
    dbo.Teste_XML
ORDER BY 
    [Produtos!1!Id_Produto], 
    [Produto!2!Categoria!ELEMENT]
FOR	
    XML EXPLICIT
    
    
    




-- Cabeçalho
SELECT 
    1 AS Tag,
    NULL AS Parent,
    Id AS [Produtos!1!Id_Produto!ELEMENT],
    NULL AS [Produto!2!Categoria!ELEMENT],
    NULL AS [Produto!2!Descricao!ELEMENT]
FROM
    dbo.Teste_XML

UNION ALL

-- Conteúdo
SELECT 
    2 AS Tag,
    1 AS Parent,
    Id AS Id_Produto,
    ISNULL(Categoria, ''),
    Descricao
FROM 
    dbo.Teste_XML
ORDER BY 
    [Produtos!1!Id_Produto!ELEMENT], 
    [Produto!2!Categoria!ELEMENT]
FOR	
    XML EXPLICIT
    
    
    
    
-- Cabeçalho
SELECT 
    1 AS Tag,
    NULL AS Parent,
    Id AS [Produtos!1!Id_Produto!ELEMENT],
    NULL AS [Produto!2!Categoria!ELEMENTXSINIL],
    NULL AS [Produto!2!Descricao!ELEMENT]
FROM
    dbo.Teste_XML

UNION ALL

-- Conteúdo
SELECT 
    2 AS Tag,
    1 AS Parent,
    Id AS Id_Produto,
    Categoria,
    Descricao
FROM 
    dbo.Teste_XML
ORDER BY 
    [Produtos!1!Id_Produto!ELEMENT], 
    [Produto!2!Descricao!ELEMENT]
FOR	
    XML EXPLICIT