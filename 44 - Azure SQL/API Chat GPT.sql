

-- Cria as credenciais
IF EXISTS(SELECT * FROM sys.database_scoped_credentials WHERE [name] = 'https://api.openai.com/v1/completions')
BEGIN
    DROP DATABASE SCOPED CREDENTIAL [https://api.openai.com/v1/completions]
END;


-- URL para criar o token: https://platform.openai.com/account/api-keys
DECLARE 
    @token VARCHAR(MAX) = CONVERT(VARCHAR(MAX), your_token_here),
    @Query VARCHAR(MAX)


SET @Query = 'CREATE DATABASE SCOPED CREDENTIAL [https://api.openai.com/v1/completions] WITH IDENTITY = ''HTTPEndpointHeaders'', SECRET = ''{"Authorization": "Bearer ' + CONVERT(VARCHAR(MAX), @token)  + '"}'''
EXEC(@Query)


-- Executa a API
DECLARE
    @ret INT,
    @response NVARCHAR(MAX),
    @payload VARCHAR(MAX) = '{
    "model": "text-davinci-003",
    "prompt": "Teste de Robô",
    "max_tokens": 4000,
    "temperature": 0.9
}'

EXEC @ret = sys.sp_invoke_external_rest_endpoint 
	@method = 'POST',
	@url = N'https://api.openai.com/v1/completions',
	@payload = @payload,
	@credential = [https://api.openai.com/v1/completions],
	@response = @response OUTPUT;

SELECT @response

SELECT * 
FROM 
    OPENJSON(@response, '$.result.results[0].tables[0].rows') 
    WITH
    (
        "DimSalesTerritory[SalesTerritoryCountry]" NVARCHAR(100),
        "[IsGrandTotalRowTotal]" BIT,
        "[SumSalesAmount]" NUMERIC(18,9)
    )
    
    
