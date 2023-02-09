
-- Cria a masterkey do banco
IF NOT EXISTS(SELECT * FROM sys.symmetric_keys WHERE [name] = '##MS_DatabaseMasterKey##') 
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'LONg_Pa$$_w0rd!'
END
GO


DECLARE
    @Query VARCHAR(MAX),
    @URLQuery NVARCHAR(4000)

SET @URLQuery = 'https://dirceu-cognitive-services.cognitiveservices.azure.com'



-- Cria as credenciais
IF EXISTS(SELECT * FROM sys.database_scoped_credentials WHERE [name] = @URLQuery)
BEGIN
    SET @Query = 'DROP DATABASE SCOPED CREDENTIAL [' + @URLQuery + ']';
    EXEC(@Query)
END;


SET @Query = 'CREATE DATABASE SCOPED CREDENTIAL [' + @URLQuery + '] WITH IDENTITY = ''HTTPEndpointHeaders'', SECRET = ''{"Ocp-Apim-Subscription-Key": "YOUR_KEY_HERE"}'''
EXEC(@Query)



-- Executa a Query DAX
DECLARE @payload NVARCHAR(MAX) = N'{
    "documents": [
        {
            "id": "1",
            "text": "Yesterday it was too sunny.",
            "language": "en"
        }
    ]
}'



DECLARE
    @ret INT,
    @response NVARCHAR(MAX);


EXEC @ret = sys.sp_invoke_external_rest_endpoint 
	@method = 'POST',
	@url = 'https://dirceu-cognitive-services.cognitiveservices.azure.com/text/analytics/v3.1/sentiment?optionMining=true',
	@payload = @payload,
	@credential = [https://dirceu-cognitive-services.cognitiveservices.azure.com],
	@response = @response OUTPUT;


--- SELECT @response

SELECT 
    arrayDocuments.id,
    arrayDocuments.sentiment,
    arrayDocuments.warnings,
    arrayConfidenceScores.positive,
    arrayConfidenceScores.neutral,
    arrayConfidenceScores.negative 
FROM 
    OPENJSON(@response, '$.result.documents[0]')
    WITH (
        [id] INT,
        [sentiment] VARCHAR(100),
        confidenceScores NVARCHAR(MAX) AS JSON,
        sentences NVARCHAR(MAX) AS JSON,
        warnings NVARCHAR(MAX) AS JSON
    ) AS [arrayDocuments]
    CROSS APPLY OPENJSON(arrayDocuments.confidenceScores) WITH (
        positive NUMERIC(10, 2),
        neutral NUMERIC(10, 2),
        negative NUMERIC(10, 2)
    ) AS arrayConfidenceScores

