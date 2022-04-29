

EXEC dbo.stpConsulta_CEP_OLE @Nr_CEP = '29200260'



EXEC dbo.stpInformacoes_Serie 
	@Nome_Serie = N'game of thrones' -- nvarchar(max)



EXEC dbo.stpInformacoes_Serie 
	@Nome_Serie = N'the walking dead' -- nvarchar(max)
    
    

EXEC dbo.stpEnvia_Mensagem_Whatsapp
    @Destinatario = '55988543306', -- varchar(30)
    @Mensagem = 'Testando a API' -- varchar(max)

