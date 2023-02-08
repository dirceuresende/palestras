
-- https://github.com/Azure-Samples/azure-sql-db-invoke-external-rest-endpoints/blob/main/power-bi.ipynb

-- Dataset: https://app.powerbi.com/groups/b353b7a3-cb59-4aa3-93f9-5f90f0136bc5/datasets/fe99bf98-5d66-4b81-a1c9-462b845168cd/details
-- DatasetID = fe99bf98-5d66-4b81-a1c9-462b845168cd

-- Recupera o token ID do Power BI:
-- az account get-access-token --resource "https://analysis.windows.net/powerbi/api" --query "accessToken" -o tsv
-- Token: eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyIsImtpZCI6Ii1LSTNROW5OUjdiUm9_XPTO

/*

Lista de domínios permitidos: 
Azure Service	                Domain
Azure Functions	                *.azurewebsites.net
Azure Apps Service	            *.azurewebsites.net
Azure App Service Environment	*.appserviceenvironment.net
Azure Static Web Apps	        *.azurestaticapps.net
Azure Logic Apps	            *.logic.azure.com
Azure Event Hubs	            *.servicebus.windows.net
Azure Event Grid	            *.eventgrid.azure.net
Azure Cognitive Services	    *.cognitiveservices.azure.com
PowerApps / Dataverse	        *.api.crm.dynamics.com
Azure Container Instances	    *.azurecontainer.io
Power BI	                    api.powerbi.com
Microsoft Graph	                graph.microsoft.com
Analysis Services	            *.asazure.windows.net
IoT Central	                    *.azureiotcentral.com
API Management	                *.azure-api.net

Referência: https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-invoke-external-rest-endpoint-transact-sql

*/

-- Cria a masterkey do banco
IF NOT EXISTS(SELECT * FROM sys.symmetric_keys WHERE [name] = '##MS_DatabaseMasterKey##') 
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'LONg_Pa$$_w0rd!'
END
GO


DECLARE
    @Query VARCHAR(MAX),
    @URLQuery NVARCHAR(4000)

SET @URLQuery = 'https://api.powerbi.com/v1.0/myorg/datasets/fe99bf98-5d66-4b81-a1c9-462b845168cd/executeQueries'


-- Cria as credenciais
IF EXISTS(SELECT * FROM sys.database_scoped_credentials WHERE [name] = @URLQuery)
BEGIN
    SET @Query = 'DROP DATABASE SCOPED CREDENTIAL [' + @URLQuery + ']';
    EXEC(@Query)
END;


SET @Query = 'CREATE DATABASE SCOPED CREDENTIAL [' + @URLQuery + '] WITH IDENTITY = ''HTTPEndpointHeaders'', SECRET = ''{"Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyIsImtpZCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyJ9.eyJhdWQiOiJodHRwczovL2FuYWx5c2lzLndpbmRvd3MubmV0L3Bvd2VyYmkvYXBpIiwiaXNzIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvNzY4YzU1YzAtZWI2OS00OGJkLTg4NjItZDY4NjBmNTg1ZWQ2LyIsImlhdCI6MTY3NTQ5NDczMCwibmJmIjoxNjc1NDk0NzMwLCJleHAiOjE2NzU0OTkzNTAsImFjY3QiOjAsImFjciI6IjEiLCJhaW8iOiJBVlFBcS84VEFBQUFTY2JRNmlPMWk4SXpuMi9Cc1ZrZ0RMeXZ6NVord2JJZ29QOWNUZ1JGcUgyS3gvbE5MWEFZK0poQU5zQW5nTWV2TExyaG55R3ROcmQ0TzJLQ0VyRWowbG9DOUk3T3QzMkR1Rml6MXFRUWtOZz0iLCJhbXIiOlsicHdkIiwibWZhIl0sImFwcGlkIjoiYjY3N2MyOTAtY2Y0Yi00YThlLWE2MGUtOTFiYTY1MGE0YWJlIiwiYXBwaWRhY3IiOiIyIiwiZmFtaWx5X25hbWUiOiJSZXNlbmRlIiwiZ2l2ZW5fbmFtZSI6IkRpcmNldSIsImlwYWRkciI6IjEzOC45OS4zNS4wIiwibmFtZSI6IkRpcmNldSBSZXNlbmRlIiwib2lkIjoiZWRhZWI2ZWMtYTAwZS00NmVmLWEzN2EtMWVhYTZjMTMxZDgxIiwicHVpZCI6IjEwMDMyMDAwNDc1RjQ4QUMiLCJyaCI6IjAuQVE4QXdGV01kbW5ydlVpSVl0YUdEMWhlMWdrQUFBQUFBQUFBd0FBQUFBQUFBQUFQQUJrLiIsInNjcCI6InVzZXJfaW1wZXJzb25hdGlvbiIsInN1YiI6IktaOTlhRnhianJqRFVzam1QaWpBaW9MM0dycDJDLU1EamdNcFRhNnJFUmsiLCJ0aWQiOiI3NjhjNTVjMC1lYjY5LTQ4YmQtODg2Mi1kNjg2MGY1ODVlZDYiLCJ1bmlxdWVfbmFtZSI6ImRpcmNldS5yZXNlbmRlQHBvd2VydHVuaW5nLmNvbS5iciIsInVwbiI6ImRpcmNldS5yZXNlbmRlQHBvd2VydHVuaW5nLmNvbS5iciIsInV0aSI6InJMRUVBeTBjbmtld1JVbHlSNE10QVEiLCJ2ZXIiOiIxLjAiLCJ3aWRzIjpbImI3OWZiZjRkLTNlZjktNDY4OS04MTQzLTc2YjE5NGU4NTUwOSJdfQ.qPQ5BPzioaKWJI2-B1HAyfvaZTr94JZUlu4RInuSveQ_MVdsWvSlPYJsc_p0BIrynd_pyOCBUOm7h7NoGb7dgLEj6Ol_LxUmjPA1KUkgPrbh0WONEmqNxDKTMlVhqTBvRP1dZrQpUy2OUoy0-gdQVlnwh9Czh_3NtXYPXG0oHC1Oj0yT9Px5RFocRu2JCR_ASYTmABU7GDFAC4-EbC83qhlIRlG4Ykia4zMtNitLhQeatQzny90orYXBkIXCFnj3DM7DRM9DHlheXoovTr1ldCYZdFSV359fY-Ni_HEBTnc-n7mBOu91RtqYW2pG9iVAuDetvFQMMwbH86QIiPYUKQ"}'''
EXEC(@Query)



-- Executa a Query DAX
DECLARE @payload NVARCHAR(MAX) = N'{
  "queries": [
    {
      "query": "' + STRING_ESCAPE('
EVALUATE
SUMMARIZECOLUMNS ( 
    DimSalesTerritory[SalesTerritoryCountry], 
    "SalesAmount", SUM ( FactInternetSales[SalesAmount] ) 
) 
ORDER BY 
    DimSalesTerritory[SalesTerritoryCountry] ASC', 'json') + '"
    }
  ],
  "serializerSettings": {
    "includeNulls": true
  }
}'



DECLARE
    @ret INT,
    @response NVARCHAR(MAX);


EXEC @ret = sys.sp_invoke_external_rest_endpoint 
	@method = 'POST',
	@url = 'https://api.powerbi.com/v1.0/myorg/datasets/fe99bf98-5d66-4b81-a1c9-462b845168cd/executeQueries',
	@payload = @payload,
	@credential = [https://api.powerbi.com/v1.0/myorg/datasets/fe99bf98-5d66-4b81-a1c9-462b845168cd/executeQueries],
	@response = @response OUTPUT;


-- SELECT @response

SELECT * 
FROM 
    OPENJSON(@response, '$.result.results[0].tables[0].rows') 
    WITH
    (
        "DimSalesTerritory[SalesTerritoryCountry]" NVARCHAR(100),
        "[SalesAmount]" NUMERIC(18,9)
    )