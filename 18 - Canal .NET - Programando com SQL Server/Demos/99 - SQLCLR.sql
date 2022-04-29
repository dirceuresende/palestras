
-- Serviços e Processos
EXEC CLR.dbo.stpServicos_Listar
    @Ds_Servidor = N'dirceu-vm', -- nvarchar(max)
    @Ds_Servico = N'SQL Server%' -- nvarchar(max)


EXEC CLR.dbo.stpProcessos_Listar 
	@Ds_Servidor = N'dirceu-vm' -- nvarchar(max)

SELECT * FROM CLR.dbo.fncServicos_Listar('dirceu-vm')

SELECT * FROM CLR.dbo.fncProcessos_Listar('dirceu-vm') WHERE Ds_Processo LIKE 'sql%'


SELECT * FROM CLR.dbo.fncProcessos_Listar('dirceu-vm') WHERE Ds_Processo = 'notepad.exe'

EXEC CLR.dbo.stpProcessos_Eliminar 
	@Nr_PID = 17136 -- int


-- SERVER INFO
SELECT * FROM CLR.dbo.fncDBA_Informacao_Disco('dirceu-vm')
SELECT * FROM CLR.dbo.fncDBA_Server_Info('dirceu-vm')
SELECT * FROM CLR.dbo.fncDBA_Server_Info_Instancias('dirceu-vm')
SELECT * FROM CLR.dbo.fncDBA_Server_Info_Minimal('dirceu-vm')

SELECT * FROM CLR.dbo.fncEvent_Viewer_Listar('dirceu-vm', 'Application', '2019-09-30 19:00', '2019-10-01')

EXEC CLR.dbo.stpEvent_Viewer_Gravar
    @Ds_Servidor = N'dirceu-vm', -- nvarchar(max)
    @Ds_Tipo_Log = N'Application', -- nvarchar(max)
    @Ds_Tipo_Evento = N'Information', -- nvarchar(max)
    @Ds_Fonte = N'SQLCLR', -- nvarchar(max)
    @Ds_Mensagem = N'Teste de mensagem do SQLCLR ', -- nvarchar(max)
    @Id_Evento = 1234 -- int


SELECT * 
FROM CLR.dbo.fncEvent_Viewer_Listar('dirceu-vm', 'Application', '2019-05-01', '2019-06-02')
WHERE Ds_Fonte = 'SQLCLR'



-- WEB
SELECT * FROM CLR.dbo.fncFeriados(2019, 'CE', 'Fortaleza')


EXEC CLR.dbo.stpEnvia_Torpedo_Pushbullet
    @Nr_Numero = N'+5527988543306', -- nvarchar(max)
    @Ds_Mensagem = N'Teste SQLCLR' -- nvarchar(max)


EXEC CLR.dbo.stpDownload_Arquivo_Remoto
    @URL = N'https://www.dirceuresende.com/wp-content/uploads/2016/09/Pushbullet-API-send-sms-to-smartphone-php-csharp-java-sql-server-clr-3.jpg', -- nvarchar(max)
    @strArquivoDestino = N'C:\Temporario\Minha imagem.jpg', -- nvarchar(max)
    @usuario = N'', -- nvarchar(max)
    @senha = N'' -- nvarchar(max)


EXEC CLR.dbo.stpCompacta_Arquivo
    @caminho = N'C:\Temporario\', -- nvarchar(max)
    @filtro = N'*.jpg', -- nvarchar(max)
    @arquivoCompactado = N'C:\Temporario\Meu Arquivo.zip', -- nvarchar(max)
    @nivelCompactacao = 5, -- int
    @senha = N'dirceu' -- nvarchar(max)


CREATE OR ALTER PROCEDURE dbo.stpProcedure_Criptografada
WITH encryption
AS
BEGIN
	SELECT 1
	PRINT 'Teste de procedure criptografada'
END

sp_helptext 'dbo.stpProcedure_Criptografada'

PRINT CLR.dbo.fncDescriptografa_Objeto('dirceu-vm\sql2017', 'canalDotNet', 'dbo', 'stpProcedure_Criptografada')



DECLARE @Ds_Retorno_OUTPUT NVARCHAR(MAX);

EXEC CLR.dbo.stpWs_Requisicao
    @Ds_Url = N'https://rastrojs.herokuapp.com/track/PU187010046BR/json', -- nvarchar(max)
    @Ds_Metodo = N'GET', -- nvarchar(max)
    @Ds_Parametros = N'', -- nvarchar(max)
    @Ds_Codificacao = N'utf-8', -- nvarchar(max)
    @Ds_Accept = N'', -- nvarchar(max)
    @Ds_ContentType = N'application/json', -- nvarchar(max)
    @Fl_Autentica_Proxy = 0, -- bit
    @Ds_Headers = N'', -- nvarchar(max)
    @Qt_Segundos_Timeout = 20, -- int
    @Ds_Retorno_OUTPUT = @Ds_Retorno_OUTPUT OUTPUT -- nvarchar(max)


SELECT 
	jsonImportado.code,
    jsonImportado.[message],
    arrData.isDelivered,
    arrData.postedAt,
    arrData.updatedAt,
    arrTrack.[status],
    arrTrack.observation,
    arrTrack.trackedAt,
    arrTrack.unit
FROM OPENJSON(@Ds_Retorno_OUTPUT, '$') WITH (
	[code] INT,
	[message] VARCHAR(100),
	[data] NVARCHAR(MAX) AS JSON
) AS jsonImportado
OUTER APPLY OPENJSON(jsonImportado.[data]) WITH (
	isDelivered VARCHAR(10),
	postedAt DATETIME,
	updatedAt DATETIME,
	[track] NVARCHAR(MAX) AS JSON
) AS arrData
OUTER APPLY OPENJSON(arrData.track) WITH (
	[status] VARCHAR(50),
	observation VARCHAR(500),
	trackedAt DATETIME,
	[unit] VARCHAR(100)
) AS arrTrack



-- ARQUIVOS
SELECT * FROM CLR.dbo.fncArquivo_Listar('C:\Temporario', '*', 0)
SELECT * FROM CLR.dbo.fncArquivo_Ler('C:\Temporario\Injection.txt')


EXEC CLR.dbo.stpExporta_Query_Txt
    @query = N'SELECT * FROM sys.objects', -- nvarchar(max)
    @separador = N'|', -- nvarchar(max)
    @caminho = N'C:\Temporario\objects.csv', -- nvarchar(max)
    @Fl_Coluna = 1 -- int
	

IF (OBJECT_ID('tempdb..##Teste') IS NOT NULL) DROP TABLE ##Teste
EXEC CLR.dbo.stpImporta_CSV2
    @Ds_Caminho_Arquivo = N'C:\Temporario\objects.csv', -- nvarchar(max)
    @Ds_Separador = N'|', -- nvarchar(max)
    @Fl_Primeira_Linha_Cabecalho = 1, -- bit
    @Nr_Linha_Inicio = 0, -- int
    @Nr_Linhas_Retirar_Final = 0, -- int
    @Ds_Tabela_Destino = '##Teste', -- nvarchar(max)
    @Ds_Codificacao = N'utf-8' -- nvarchar(max)

SELECT * FROM ##Teste


EXEC CLR.dbo.stpImporta_Excel2
    @Caminho = N'C:\Temporario\Pasta1.xlsx', -- nvarchar(max)
    @Aba = N'Planilha1', -- nvarchar(max)
    @Colunas = N'*' -- nvarchar(max)



EXEC CLR.dbo.stpRenomeia_Arquivo
    @Caminho_Origem = N'C:\Temporario\objects.csv', -- nvarchar(max)
    @Caminho_Destino = N'C:\Temporario\objetos.csv', -- nvarchar(max)
    @Fl_Sobrescrever = 1 -- bit


EXEC CLR.dbo.stpCopia_Arquivo
    @origem = N'C:\Temporario\objetos.csv', -- nvarchar(max)
    @destino = N'C:\Temporario\objetos2.csv', -- nvarchar(max)
    @sobrescrever = 1 -- bit


EXEC CLR.dbo.stpApaga_Arquivo 
	@caminho = N'C:\Temporario\objetos.csv' -- nvarchar(max)


SELECT 
	CLR.dbo.fncArquivo_Tamanho('C:\Temporario\objetos2.csv'),
	CLR.dbo.fncArquivo_Tamanho_Disco('C:\Temporario\objetos2.csv'),
	CLR.dbo.fncArquivo_Existe('C:\Temporario\objetos2.csv'),
	CLR.dbo.fncArquivo_Existe('C:\Temporario\objetos.csv'),
	CLR.dbo.fncArquivo_Data_Criacao('C:\Temporario\objetos.csv'), 
	CLR.dbo.fncArquivo_Data_Modificacao('C:\Temporario\objetos.csv')


SELECT * FROM CLR.dbo.fncArquivo_Ler('C:\Temporario\objetos2.csv')



SELECT CLR.dbo.fncCriptografa_String('Dirceu')

DECLARE 
	@Hostname VARCHAR(MAX) = CLR.dbo.fncDescriptografa_String('!=!enC!=!MkqqZTSLC4/hy6PJe57rUfRFREco9ZLAnRP3kXOYBiZAHSU5keUDUumbz/IcxQu6eF68dnNRIEFjE/TIuvkf4w=='),
	@Login VARCHAR(MAX) = CLR.dbo.fncDescriptografa_String('!=!enC!=!bQB2ae4bjiBGSJTcCd8+NXKOrdogNuwo'),
	@Senha VARCHAR(MAX) = CLR.dbo.fncDescriptografa_String('!=!enC!=!DNmrvDwSyxMmSuNPAZVi4NIo+oydpONt3uZ+CqMZ/DSFURC9H8TRuE1h7m1BIPPF')

EXEC CLR.dbo.stpFTP_Arquivo_Listar
    @host = @Hostname, -- nvarchar(max)
    @pastaFtp = N'/public_html/wp-includes', -- nvarchar(max)
    @filtro = N'*', -- nvarchar(max)
    @login = @Login, -- nvarchar(max)
    @senha = @Senha -- nvarchar(max)




DECLARE 
	@Hostname VARCHAR(MAX) = CLR.dbo.fncDescriptografa_String('!=!enC!=!MkqqZTSLC4/hy6PJe57rUfRFREco9ZLAnRP3kXOYBiZAHSU5keUDUumbz/IcxQu6eF68dnNRIEFjE/TIuvkf4w=='),
	@Login VARCHAR(MAX) = CLR.dbo.fncDescriptografa_String('!=!enC!=!bQB2ae4bjiBGSJTcCd8+NXKOrdogNuwo'),
	@Senha VARCHAR(MAX) = CLR.dbo.fncDescriptografa_String('!=!enC!=!DNmrvDwSyxMmSuNPAZVi4NIo+oydpONt3uZ+CqMZ/DSFURC9H8TRuE1h7m1BIPPF')

EXEC CLR.dbo.stpFTP_Arquivo_Download
    @host = @Hostname, -- nvarchar(max)
    @pastaFtp = N'/public_html/', -- nvarchar(max)
    @filtro = N'index.php', -- nvarchar(max)
    @login = @Login, -- nvarchar(max)
    @senha = @Senha, -- nvarchar(max)
    @pastaLocal = N'C:\Temporario\', -- nvarchar(max)
    @apagarRemoto = 0 -- bit

	
EXEC CLR.dbo.stpPivot_Table
    @Ds_Query = N'SELECT * FROM sys.database_principals', -- nvarchar(max)
    @Ds_Tabela_Destino = N'' -- nvarchar(max)



EXEC CLR.dbo.stpImporta_Txt 
	@caminho = N'C:\Temporario\Tamanho Fixo.txt' -- nvarchar(max)


IF (OBJECT_ID('canalDotNet.dbo.Teste') IS NOT NULL) DROP TABLE canalDotNet.dbo.Teste
EXEC CLR.dbo.stpImporta_Txt_Tamanho_Fixo
    @caminho = N'C:\Temporario\Tamanho Fixo.txt', -- nvarchar(max)
    @Titulos = N'Nome,Site,Idade', -- nvarchar(max)
    @Tamanhos = N'18,23,3', -- nvarchar(max)
    @Ds_Encoding = N'iso-8859-1', -- nvarchar(max)
    @Ds_Tabela_Destino = N'canalDotNet.dbo.Teste', -- nvarchar(max)
    @Fl_Trim_Results = 1 -- bit


SELECT * FROM dbo.Teste


SELECT *
FROM CLR.dbo.fncRegEdit_Listar('dirceu-vm', 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL14.SQL2017\Setup')


SELECT * 
FROM CLR.dbo.fncWhoIsActive()
WHERE login_name LIKE '%dirceu%'

