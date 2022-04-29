DECLARE @Saida BIT;

EXEC xpcmdshell.stpArquivo_Existe
    @Ds_Arquivo = 'C:\Temporario\Teste.txt', -- varchar(255)
    @Saida = @Saida OUTPUT -- bit

SELECT @Saida


---------------------------------------------------------------


EXEC xpcmdshell.stpCria_Diretorio 
	@Ds_Diretorio = 'C:\Temporario\TesteMkdir' -- varchar(255)


---------------------------------------------------------------


DECLARE @Ds_Texto VARCHAR(MAX) = 'Esse é um teste de arquivo de texto com quebra de linha'

EXEC xpcmdshell.stpEscreve_Arquivo
    @Ds_Arquivo = 'C:\Temporario\Teste.txt', -- varchar(255)
    @Ds_Texto = @Ds_Texto, -- varchar(max)
    @Fl_Sobrescrever = 1 -- bit


---------------------------------------------------------------


EXEC xpcmdshell.stpApaga_Arquivo 
	@Ds_Arquivo = 'C:\Temporario\Teste.txt' -- varchar(255)


---------------------------------------------------------------


EXEC xpcmdshell.stpCria_Diretorio 
	@Ds_Diretorio = 'C:\Temporario\Teste\' -- varchar(255)


EXEC xpcmdshell.stpCopia_Arquivo
    @Ds_Arquivo = 'C:\Temporario\Teste.txt', -- varchar(255)
    @Ds_Diretorio = 'C:\Temporario\Teste\', -- varchar(255)
    @Fl_Sobrescrever = 1 -- bit


---------------------------------------------------------------


EXEC xpcmdshell.stpMove_Arquivo
    @Ds_Arquivo = 'C:\Temporario\Teste.txt', -- varchar(255)
    @Ds_Diretorio = 'C:\Temporario\Teste\', -- varchar(255)
    @Fl_Sobrescrever = 1 -- bit
    
    
---------------------------------------------------------------
    
    
EXEC xpcmdshell.stpApaga_Diretorio
    @Ds_Diretorio = 'C:\Temporario\Teste', -- varchar(255)
    @Fl_Recursivo = 1 -- bit
    
    
    
---------------------------------------------------------------
    
    

EXEC xpcmdshell.stpArquivo_Listar 
	@Ds_Diretorio = 'C:\Temporario' -- varchar(255)


