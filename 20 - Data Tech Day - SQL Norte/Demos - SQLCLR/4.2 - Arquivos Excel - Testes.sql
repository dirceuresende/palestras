

EXEC xpcmdshell.stpArquivo_Ler 
	@Ds_Arquivo = 'C:\Temporario\Teste 2.txt' -- varchar(255)


---------------------------------------------------------------


SELECT * 
FROM OPENROWSET (
    'Microsoft.ACE.OLEDB.12.0', 
    'Excel 12.0;Database=C:\Temporario\Pasta1.xlsx;', 
    'SELECT * FROM [Planilha1$]'
)



EXEC excel.stpImporta_Excel
    @Caminho = 'C:\Temporario\Pasta1.xlsx', -- varchar(5000)
    @Aba = 'Planilha1', -- varchar(200)
    @Colunas = '*' -- varchar(5000)



IF (OBJECT_ID('tempdb..#Dados') IS NOT NULL) DROP TABLE #Dados
CREATE TABLE #Dados (
    [name]                NVARCHAR(255),
    [object_id]           FLOAT(8),
    [principal_id]        NVARCHAR(255),
    [schema_id]           FLOAT(8),
    [parent_object_id]    FLOAT(8),
    [type]                NVARCHAR(255),
    [type_desc]           NVARCHAR(255),
    [create_date]         NVARCHAR(255),
    [modify_date]         NVARCHAR(255),
    [is_ms_shipped]       FLOAT(8),
    [is_published]        FLOAT(8),
    [is_schema_published] FLOAT(8)
);

INSERT INTO #Dados
VALUES
( N'TESTE DIRCEU', 3, N'NULL', 4, 0, N'S ', N'SYSTEM_TABLE', N'2017-08-22 19:38:03.840', N'2017-08-22 19:38:03.847', 1, 0, 0 )

EXEC excel.stpInsere_em_Excel
    @Caminho = 'C:\Temporario\Pasta1.xlsx', -- varchar(max)
    @Aba = 'Planilha1', -- varchar(200)
    @Tabela = '#Dados', -- varchar(200)
    @Colunas = '*' -- varchar(max)
