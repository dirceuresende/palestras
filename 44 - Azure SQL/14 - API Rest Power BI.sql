
-- https://github.com/Azure-Samples/azure-sql-db-invoke-external-rest-endpoints/blob/main/power-bi.ipynb

-- Dataset: https://app.powerbi.com/groups/b353b7a3-cb59-4aa3-93f9-5f90f0136bc5/datasets/fe99bf98-5d66-4b81-a1c9-462b845168cd/details
-- DatasetID = fe99bf98-5d66-4b81-a1c9-462b845168cd

-- Recupera o token ID do Power BI:
-- az account get-access-token --resource "https://analysis.windows.net/powerbi/api" --query "accessToken" -o tsv
-- Token: your_token_here

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


SET @Query = 'CREATE DATABASE SCOPED CREDENTIAL [' + @URLQuery + '] WITH IDENTITY = ''HTTPEndpointHeaders'', SECRET = ''{"Authorization": "Bearer your_token_here"}'''
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
