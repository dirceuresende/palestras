
DECLARE @Versao VARCHAR(20) = NULL

--------------------------------------------------------------------------------
-- Habilitando o OLE Automation (Se não estiver ativado)
--------------------------------------------------------------------------------

DECLARE @Fl_Ole_Automation_Ativado BIT = (SELECT (CASE WHEN CAST([value] AS VARCHAR(MAX)) = '1' THEN 1 ELSE 0 END) FROM sys.configurations WHERE [name] = 'Ole Automation Procedures')

IF (@Fl_Ole_Automation_Ativado = 0)
BEGIN

    EXECUTE sp_configure 'show advanced options', 1
    RECONFIGURE WITH OVERRIDE

    EXEC sp_configure 'Ole Automation Procedures', 1
    RECONFIGURE WITH OVERRIDE

END



DECLARE 
    @obj INT,
    @Url VARCHAR(8000),
    @xml VARCHAR(MAX),
    @resposta VARCHAR(MAX)
    
SET @Url = 'http://sqlserverbuilds.blogspot.com/'

EXEC sys.sp_OACreate 'MSXML2.ServerXMLHTTP', @obj OUT
EXEC sys.sp_OAMethod @obj, 'open', NULL, 'GET', @Url, false
EXEC sys.sp_OAMethod @obj, 'send'


DECLARE @xml_versao_sql TABLE (
    Ds_Dados VARCHAR(MAX)
)

INSERT INTO @xml_versao_sql(Ds_Dados)
EXEC sys.sp_OAGetProperty @obj, 'responseText' --, @resposta OUT


EXEC sys.sp_OADestroy @obj



--------------------------------------------------------------------------------
-- Desativando o OLE Automation (Se não estava habilitado antes)
--------------------------------------------------------------------------------

IF (@Fl_Ole_Automation_Ativado = 0)
BEGIN

    EXEC sp_configure 'Ole Automation Procedures', 0
    RECONFIGURE WITH OVERRIDE

    EXECUTE sp_configure 'show advanced options', 0
    RECONFIGURE WITH OVERRIDE

END



DECLARE
    @Versao_SQL_Build VARCHAR(20)

IF (@Versao IS NOT NULL)
    SET @Versao_SQL_Build = @Versao

ELSE BEGIN

    SET @Versao_SQL_Build = (CASE LEFT(CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion')), 2)
        WHEN '8.' THEN '2000'
        WHEN '9.' THEN '2005'
        WHEN '10' THEN (
            CASE
                WHEN LEFT(CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion')), 4) = '10.5' THEN '2008 R2' 
                WHEN LEFT(CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion')), 4) = '10.0' THEN '2008' 
            END)
        WHEN '11' THEN '2012'
        WHEN '12' THEN '2014'
        WHEN '13' THEN '2016'
        WHEN '14' THEN '2017'
        WHEN '15' THEN '2019'
        ELSE '2019'
    END)

END


SELECT TOP 1 @resposta = Ds_Dados FROM @xml_versao_sql


SET @xml = @resposta COLLATE SQL_Latin1_General_CP1251_CS_AS

DECLARE
    @PosicaoInicialVersao INT,
    @PosicaoFinalVersao INT,
    @ExpressaoBuscar VARCHAR(100) = 'Microsoft SQL Server ' + @Versao_SQL_Build + ' Builds',
    @RetornoTabela VARCHAR(MAX),
    @dadosXML XML

SET @PosicaoInicialVersao = CHARINDEX(@ExpressaoBuscar, @xml) + LEN(@ExpressaoBuscar) + 6
SET @PosicaoFinalVersao = CHARINDEX('</table>', @xml, @PosicaoInicialVersao)
SET @RetornoTabela = SUBSTRING(@xml, @PosicaoInicialVersao, @PosicaoFinalVersao - @PosicaoInicialVersao + 8)


-- Corrigindo classes sem aspas duplas ("")
SET @RetornoTabela = REPLACE(@RetornoTabela, ' border=1 cellpadding=4 cellspacing=0 bordercolor="#CCCCCC" style="border-collapse:collapse"', '')
SET @RetornoTabela = REPLACE(@RetornoTabela, ' target=_blank rel=nofollow', ' target="_blank" rel="nofollow"')
SET @RetornoTabela = REPLACE(@RetornoTabela, ' class=h', '')
SET @RetornoTabela = REPLACE(@RetornoTabela, ' class=lsp', '')
SET @RetornoTabela = REPLACE(@RetornoTabela, ' class=cu', '')
SET @RetornoTabela = REPLACE(@RetornoTabela, ' class=sp', '')
SET @RetornoTabela = REPLACE(@RetornoTabela, ' class=rtm', '')
SET @RetornoTabela = REPLACE(@RetornoTabela, ' width=580', '')
SET @RetornoTabela = REPLACE(@RetornoTabela, ' width=125', '')
SET @RetornoTabela = REPLACE(@RetornoTabela, ' class=lcu', '')
SET @RetornoTabela = REPLACE(@RetornoTabela, ' class=cve', '')
SET @RetornoTabela = REPLACE(@RetornoTabela, ' class=lrtm', '')
SET @RetornoTabela = REPLACE(@RetornoTabela, ' class=beta', '')

-- Corrigindo elementos não fechados corretamente
SET @RetornoTabela = REPLACE(@RetornoTabela, '<th>', '</th><th>')
SET @RetornoTabela = REPLACE(@RetornoTabela, '<tr></th>', '<tr>')
SET @RetornoTabela = REPLACE(@RetornoTabela, '<th>Build<th ', '<th>Build</th><th ')
SET @RetornoTabela = REPLACE(@RetornoTabela, '<th>Release Date</tr>', '<th>Release Date</th></tr>')

SET @RetornoTabela = REPLACE(@RetornoTabela, '<td>', '</td><td>')
SET @RetornoTabela = REPLACE(@RetornoTabela, '<tr></td>', '<tr>')

SET @RetornoTabela = REPLACE(@RetornoTabela, '</tr>', '</td></tr>')
SET @RetornoTabela = REPLACE(@RetornoTabela, '</th></td>', '</th>')
SET @RetornoTabela = REPLACE(@RetornoTabela, '</td></td>', '</td>')

-- Removendo elementos de entidades HTML
SET @RetornoTabela = REPLACE(@RetornoTabela, '&nbsp;', ' ')
SET @RetornoTabela = REPLACE(@RetornoTabela, '&kbln', '&amp;kbln')
SET @RetornoTabela = REPLACE(@RetornoTabela, '<br>', '<br/>')

SET @dadosXML = CONVERT(XML, @RetornoTabela)


DECLARE @Atualizacoes_SQL_Server TABLE
(
    [Ultimo_Build] VARCHAR(100),
    [Ultimo_Build_SQLSERVR.EXE] VARCHAR(100),
    [Versao_Arquivo] VARCHAR(100),
    [Q] VARCHAR(100),
    [KB] VARCHAR(100),
    [Descricao_KB] VARCHAR(500),
    [Lancamento_KB] VARCHAR(100),
    [Download_Ultimo_Build] VARCHAR(100)
)


INSERT INTO @Atualizacoes_SQL_Server
SELECT
    @dadosXML.value('(//table/tr/td[1])[1]','varchar(100)') AS Ultimo_Build,
    @dadosXML.value('(//table/tr/td[2])[1]','varchar(100)') AS [Ultimo_Build_SQLSERVR.EXE],
    @dadosXML.value('(//table/tr/td[3])[1]','varchar(100)') AS Versao_Arquivo,
    @dadosXML.value('(//table/tr/td[4])[1]','varchar(100)') AS [Q],
    @dadosXML.value('(//table/tr/td[5])[1]','varchar(100)') AS KB,
    @dadosXML.value('(//table/tr/td[6]/a)[1]','varchar(500)') AS Descricao_KB,
    @dadosXML.value('(//table/tr/td[7])[1]','varchar(100)') AS Lancamento_KB,
    @dadosXML.value('(//table/tr/td[6]/a/@href)[1]','varchar(100)') AS Download_Ultimo_Build


DECLARE 
    @Url_Ultima_Versao_SQL VARCHAR(500) = (SELECT TOP(1) Download_Ultimo_Build FROM @Atualizacoes_SQL_Server),
    @Ultimo_Build VARCHAR(100) = (SELECT TOP(1) Ultimo_Build FROM @Atualizacoes_SQL_Server),
    @Descricao_KB VARCHAR(500) = (SELECT TOP(1) Descricao_KB FROM @Atualizacoes_SQL_Server)


IF (@Versao IS NOT NULL)
BEGIN

    SELECT * 
    FROM @Atualizacoes_SQL_Server

END
ELSE BEGIN

    IF (CONVERT(VARCHAR(100), SERVERPROPERTY('ProductVersion')) >= @Ultimo_Build)
        SELECT 'SQL Server ATUALIZADO!' AS SQL_Server_Atualizado
    ELSE BEGIN

        SELECT 'SQL Server DESATUALIZADO!!' AS SQL_Server_Desatualizado
        UNION ALL
        SELECT '----------------------------------------'
        UNION ALL
        SELECT 'Versão mais atual: ' + @Ultimo_Build + ' (' + @Descricao_KB + ')'
        UNION ALL
        SELECT 'Download da versão mais atual: '
        UNION ALL
        SELECT @Url_Ultima_Versao_SQL
        UNION ALL
        SELECT '----------------------------------------'
        UNION ALL 
        SELECT 'Sua versão: ' + CONVERT(VARCHAR(100), SERVERPROPERTY('ProductVersion')) + ' (' + CONVERT(VARCHAR(100), SERVERPROPERTY('ProductLevel')) + ')'

        SELECT * 
        FROM @Atualizacoes_SQL_Server

    END

END

