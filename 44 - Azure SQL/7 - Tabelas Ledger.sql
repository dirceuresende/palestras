
---------------------------------------------------------------
-- TABELAS LEDGER QUE ACEITAM APENAS INSERT
---------------------------------------------------------------

IF (SCHEMA_ID('AccessControl') IS NULL)
    EXEC('CREATE SCHEMA [AccessControl]');
GO


DROP TABLE IF EXISTS [AccessControl].[KeyCardEvents]
GO

CREATE TABLE [AccessControl].[KeyCardEvents]
(
    [EmployeeID] INT NOT NULL,
    [AccessOperationDescription] NVARCHAR (1024) NOT NULL,
    [Timestamp] Datetime2 NOT NULL
)
WITH (LEDGER = ON (APPEND_ONLY = ON));


INSERT INTO [AccessControl].[KeyCardEvents]
VALUES ('43869', 'Building42', '2020-05-02T19:58:47.1234567');

INSERT INTO [AccessControl].[KeyCardEvents]
VALUES ('43870', 'Building2', GETDATE());


SELECT
    *,
    [ledger_start_transaction_id],
    [ledger_start_sequence_number]
FROM
    [AccessControl].[KeyCardEvents];


-- Curiosidade
SELECT * FROM [AccessControl].[KeyCardEvents]
SELECT *, [ledger_start_transaction_id], [ledger_start_sequence_number] FROM [AccessControl].[KeyCardEvents]


SELECT * 
FROM [AccessControl].[KeyCardEvents_Ledger]


SELECT
    t.[commit_time]                AS [CommitTime],
    t.[principal_name]             AS [UserName],
    l.[EmployeeID],
    l.[AccessOperationDescription],
    l.[Timestamp],
    l.[ledger_operation_type_desc] AS Operation
FROM
    [AccessControl].[KeyCardEvents_Ledger] AS l
    JOIN sys.database_ledger_transactions  AS t ON t.transaction_id = l.ledger_transaction_id
ORDER BY
    t.commit_time DESC;


-- ERRO: Updates are not allowed for the append only Ledger table 'AccessControl.KeyCardEvents'.
UPDATE [AccessControl].[KeyCardEvents] SET [EmployeeID] = 34184;


-- ERRO: Updates are not allowed for the append only Ledger table 'AccessControl.KeyCardEvents'.
DELETE FROM [AccessControl].[KeyCardEvents]
WHERE [EmployeeID] = 34184;


---------------------------------------------------------------
-- TABELAS LEDGER QUE ACEITAM UPDATES
---------------------------------------------------------------

IF (SCHEMA_ID('Account') IS NULL)
    EXEC('CREATE SCHEMA [Account]')
GO


DROP TABLE IF EXISTS [Account].[Balance]
GO

CREATE TABLE [Account].[Balance]
(
    [CustomerID] INT NOT NULL PRIMARY KEY CLUSTERED,
    [LastName] VARCHAR (50) NOT NULL,
    [FirstName] VARCHAR (50) NOT NULL,
    [Balance] DECIMAL (10,2) NOT NULL
)
WITH 
(
 SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Account].[BalanceHistory]),
 LEDGER = ON
);


SELECT
    ts.[name] + '.' + t.[name] AS [ledger_table_name],
    hs.[name] + '.' + h.[name] AS [history_table_name],
    vs.[name] + '.' + v.[name] AS [ledger_view_name]
FROM
    sys.tables       AS t
    JOIN sys.tables  AS h ON ( h.[object_id] = t.[history_table_id] )
    JOIN sys.views   AS v ON ( v.[object_id] = t.[ledger_view_id] )
    JOIN sys.schemas AS ts ON ( ts.[schema_id] = t.[schema_id] )
    JOIN sys.schemas AS hs ON ( hs.[schema_id] = h.[schema_id] )
    JOIN sys.schemas AS vs ON ( vs.[schema_id] = v.[schema_id] )
WHERE
    t.[name] = 'Balance';


INSERT INTO [Account].[Balance]
VALUES (1, 'Jones', 'Nick', 50);


INSERT INTO [Account].[Balance]
VALUES (2, 'Smith', 'John', 500),
(3, 'Smith', 'Joe', 30),
(4, 'Michaels', 'Mary', 200);


SELECT
    [CustomerID],
    [LastName],
    [FirstName],
    [Balance],
    [ledger_start_transaction_id],
    [ledger_end_transaction_id],
    [ledger_start_sequence_number],
    [ledger_end_sequence_number]
FROM
    [Account].[Balance];



UPDATE [Account].[Balance] SET [Balance] = 100
WHERE [CustomerID] = 1;



SELECT
    t.[commit_time]                AS [CommitTime],
    t.[principal_name]             AS [UserName],
    l.[CustomerID],
    l.[LastName],
    l.[FirstName],
    l.[Balance],
    l.[ledger_operation_type_desc] AS Operation
FROM
    [Account].[Balance_Ledger]            AS l
    JOIN sys.database_ledger_transactions AS t ON t.transaction_id = l.ledger_transaction_id
ORDER BY
    t.commit_time DESC;



-- Na tabela original tudo está OK
SELECT * FROM [Account].[Balance]


-- Na tabela Ledger, temos todo o histórico
SELECT * FROM [Account].[Balance_Ledger]


EXECUTE sp_generate_database_ledger_digest

/*

{
    "database_name": "dirceu",
    "block_id":0,
    "hash":"0x40ACE70F86E0FE2D8F11C23D8B6FD13A7B07E0F17ACAB895002C551917F52FEB",
    "last_transaction_commit_time":"2023-02-07T16:51:57.2133333",
    "digest_time":"2023-02-07T19:37:52.2959744"
}

*/


DECLARE @digest nvarchar(max) = N'{"database_name":"dirceu","block_id":1,"hash":"0xDA8085CA81B0453D25C2DC61483F58F847E8D99B295EC6CAE7C3181B48746D42","last_transaction_commit_time":"2023-02-07T19:57:26.9033333","digest_time":"2023-02-07T19:57:32.0054417"}'
EXECUTE sp_verify_database_ledger @digest

