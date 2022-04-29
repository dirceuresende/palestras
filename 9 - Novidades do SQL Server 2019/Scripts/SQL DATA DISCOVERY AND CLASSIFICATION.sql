USE [WideWorldImportersDW]
GO

ALTER DATABASE WideWorldImportersDW SET COMPATIBILITY_LEVEL = 150
GO

ADD SENSITIVITY CLASSIFICATION TO Fact.Sale.[Description]
WITH (LABEL = 'Confidential', INFORMATION_TYPE = 'Name');
 
ADD SENSITIVITY CLASSIFICATION TO Fact.Sale.Quantity
WITH (LABEL = 'Highly Confidential', INFORMATION_TYPE = 'Financial');
 
ADD SENSITIVITY CLASSIFICATION TO Fact.Sale.Profit
WITH (LABEL = 'Highly Confidential- GDPR', INFORMATION_TYPE = 'Financial');


/*

Label
----------------------
Public
General
Confidential – GDPR
Confidential
Highly Confidential
Highly Confidential – GDPR


Information Type
----------------------
Banking
Contact Info
Credentials
Credit Card
Date of Birth
Financial
Health
Name
National ID
SSN
Other

*/


-- Colunas com classificações

SELECT 
    SCHEMA_NAME(objects.schema_id) AS schema_name, 
    objects.NAME                   AS table_name, 
    columns.NAME                   AS column_name, 
    ISNULL(EP.information_type_name,'') AS  information_type_name,
    ISNULL(EP.sensitivity_label_name,'') AS  sensitivity_label_name
FROM (
    SELECT 
        ISNULL(EC1.major_id,EC2.major_id) AS major_id, 
        ISNULL(EC1.minor_id,EC2.minor_id) AS minor_id, 
        EC1.information_type_name, 
        EC2.sensitivity_label_name 
    FROM (
        SELECT 
            major_id, 
            minor_id,
            NULLIF(value,'') AS information_type_name
        FROM 
            sys.extended_properties 
        WHERE 
            NAME = 'sys_information_type_name'
    ) EC1
    FULL OUTER JOIN (
        SELECT 
            major_id, 
            minor_id, 
            NULLIF(value,'') AS sensitivity_label_name
        FROM 
            sys.extended_properties 
        WHERE
            NAME = 'sys_sensitivity_label_name'
    ) EC2 ON ( EC2.major_id = EC1.major_id AND EC2.minor_id = EC1.minor_id )
) EP 
    JOIN sys.objects objects ON EP.major_id = objects.object_id 
    JOIN sys.columns columns ON ( EP.major_id = columns.object_id AND EP.minor_id = columns.column_id )