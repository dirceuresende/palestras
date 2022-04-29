
-- Utilizando queryout, pode-se exportar o resultado de uma query
EXEC master.dbo.xp_cmdshell 'bcp "SELECT * FROM msdb.sys.tables" queryout "C:\Temporario\bcp_queryout.csv" -c -t; -T -Slocalhost\SQL2017'

-- Utilizando out, pode-se exportar um objeto
EXEC master.dbo.xp_cmdshell 'bcp msdb.sys.tables out "C:\Temporario\bcp_out.csv" -c -t, -T -Slocalhost\SQL2017'


------------------------------------------------------------------------------------


EXEC ole.stpEscreve_Arquivo_FSO
    @String = 'Teste de Exportação de arquivo de texto', -- varchar(max)
    @Ds_Arquivo = 'C:\Temporario\Teste.txt' -- varchar(1501)


------------------------------------------------------------------------------------


-- Exportando para CSV com OLE Automation
EXEC dbo.SaveDelimitedColumns
    @DBFetch='select * from sys.objects',
    @DBWhere='type = ^P^',
    @PCWrite='C:\Temporario\Teste.csv',
    @Header = 1




-------------------------------------------------------------------------------


SELECT *
FROM ole.fncLer_Arquivo_FSO('C:\Temporario\Teste.csv')


-------------------------------------------------------------------------------


IF (OBJECT_ID('dbo.bcp_in') IS NOT NULL) DROP TABLE dbo.bcp_in
CREATE TABLE dbo.bcp_in (
	Ds_Linha VARCHAR(MAX)
)

EXEC sys.xp_cmdshell 'bcp canalDotNet.dbo.bcp_in IN "C:\Temporario\Teste.csv" -T -Slocalhost\sql2017 -c'


-------------------------------------------------------------------------------


IF (OBJECT_ID('dbo.bulk_insert') IS NOT NULL) DROP TABLE dbo.bulk_insert
CREATE TABLE dbo.bulk_insert (
	Ds_Linha VARCHAR(MAX)
)

BULK INSERT bulk_insert
FROM 'C:\Temporario\Teste.csv'

SELECT * FROM bulk_insert


-------------------------------------------------------------------------------


SELECT * FROM OPENROWSET(BULK 'C:\Temporario\Teste.csv', SINGLE_CLOB) AS Arquivo(linhas)


-------------------------------------------------------------------------------


SELECT *
FROM OPENROWSET(
	'Microsoft.ACE.OLEDB.12.0', 
	'Text; Database=C:\Temporario\;HDR=NO,FORMAT=Delimited(;)',
	'SELECT * FROM [Teste.csv]'
) AS A


-------------------------------------------------------------------------------

EXEC dbo.stpImporta_CSV
    @Ds_Caminho_Arquivo = 'C:\Temporario\Teste.csv', -- varchar(max)
    @Ds_Separador = ',', -- varchar(10)
    @Fl_Primeira_Linha_Cabecalho = 1, -- bit
    @Ds_Tabela_Destino = NULL -- varchar(max)
