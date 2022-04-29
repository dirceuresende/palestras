

SELECT ole.fncArquivo_Existe_FSO('C:\Temporario\Teste.txt')


---------------------------------------------------------------


DECLARE @Ds_Texto VARCHAR(MAX) = 'Esse é um teste de arquivo de texto 
com 
quebra 
de 

linha'

EXEC ole.stpEscreve_Arquivo_FSO
    @Ds_Arquivo = 'C:\Temporario\Teste.txt', -- varchar(255)
    @String = @Ds_Texto -- varchar(max)


---------------------------------------------------------------


EXEC ole.stpApaga_Arquivo_FSO 
	@strArquivo = 'C:\Temporario\Teste.txt' -- varchar(255)


---------------------------------------------------------------


EXEC ole.stpCopia_Arquivo_FSO
    @strOrigem = 'C:\Temporario\Teste.txt', -- varchar(max)
    @strDestino = 'C:\Temporario\Teste\', -- varchar(max)
    @sobrescrever = 1 -- int


---------------------------------------------------------------


EXEC ole.stpMove_Arquivo_FSO
    @strOrigem = 'C:\Temporario\Teste.txt', -- varchar(max)
    @strDestino = 'C:\Temporario\Teste\', -- varchar(max)
    @sobrescrever = 1 -- int


