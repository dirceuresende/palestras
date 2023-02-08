
-- Verifica se está permitindo autenticação SQL Local
SELECT SERVERPROPERTY('IsExternalAuthenticationOnly') 


-----------------------------------------------------
-- Adicionar login local
-----------------------------------------------------

IF (EXISTS(SELECT TOP(1) NULL FROM sys.sql_logins WHERE [name] = 'teste'))
BEGIN
    DROP LOGIN [teste]
END

IF (EXISTS(SELECT TOP(1) NULL FROM sys.database_principals WHERE [name] = 'teste'))
BEGIN
    DROP USER [teste]
END


CREATE LOGIN [teste] WITH PASSWORD = 'q$@TXckP2xj@nO8x$gLw#DB4%!%AoEsKWJIaAuz9zmx^qdD*vs' 
GO

CREATE USER [teste] FOR LOGIN [teste]
GO


-- Torna "sysadmin"
ALTER ROLE [dbmanager] ADD MEMBER [teste]
GO

ALTER ROLE [loginmanager] ADD MEMBER [teste]
GO

-- Conecta com novo usuário


-----------------------------------------------------
-- Adicionar usuário local
-----------------------------------------------------

IF (EXISTS(SELECT TOP(1) NULL FROM sys.database_principals WHERE [name] = 'teste_db'))
BEGIN
    DROP USER [teste_db]
END

CREATE USER [teste_db] WITH PASSWORD = 'q$@TXckP2xj@nO8x$gLw#DB4%!%AoEsKWJIaAuz9zmx^qdD*vs' 
GO

SELECT * FROM sys.databases


-- Adicionar usuário do Azure Active Directory
CREATE USER [adf-teste-dirceu] FROM EXTERNAL PROVIDER
GO

ALTER ROLE [db_datareader] ADD MEMBER [adf-teste-dirceu]
GO



-----------------------------------------------------
-- Lista os usuários e seu tipo de autenticação
-----------------------------------------------------

SELECT 
    [name],
    principal_id,
    [type_desc],
    default_schema_name,
    create_date,
    modify_date,
    authentication_type_desc
FROM
    sys.database_principals
WHERE
    [type_desc] IN ('SQL_USER', 'EXTERNAL_USER')
    AND is_fixed_role = 0
    AND principal_id > 4 -- system users

