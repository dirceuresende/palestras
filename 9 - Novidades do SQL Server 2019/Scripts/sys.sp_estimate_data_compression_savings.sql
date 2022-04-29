
-- SQL SERVER 2017

USE [AdventureWorks]
GO

EXEC sys.sp_estimate_data_compression_savings
    @schema_name = 'Sales', -- sysname
    @object_name = 'SalesOrderHeader', -- sysname
    @data_compression = N'PAGE', -- nvarchar(60)
    @index_id = NULL,
    @partition_number = NULL



-- SQL SERVER 2019

USE [WideWorldImportersDW]
GO

EXEC sys.sp_estimate_data_compression_savings
    @schema_name = 'Fact', -- sysname
    @object_name = 'Sale', -- sysname
    @data_compression = N'COLUMNSTORE', -- nvarchar(60)
    @index_id = NULL,
    @partition_number = NULL
