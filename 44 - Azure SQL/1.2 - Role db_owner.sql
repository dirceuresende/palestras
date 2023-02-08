
-----------------------------------------------------
-- Role db_owner
-----------------------------------------------------

-- Usuário de teste
IF (EXISTS(SELECT TOP(1) NULL FROM sys.database_principals WHERE [name] = 'teste-impersonate'))
BEGIN
    DROP USER [teste-impersonate]
END

CREATE USER [teste-impersonate] WITH PASSWORD = 'q$@TXckP2xj@nO8x$gLw#DB4%!%AoEsKWJIaAuz9zmx^qdD*vs' 
GO

ALTER ROLE [db_owner] ADD MEMBER [teste-impersonate]
GO


SELECT USER, USER_NAME(), CURRENT_USER, SESSION_USER, ORIGINAL_LOGIN()

EXEC AS USER = 'teste_db'
GO

SELECT USER, USER_NAME(), CURRENT_USER, SESSION_USER, ORIGINAL_LOGIN()


CREATE TABLE dbo.Teste_Live ( Nome VARCHAR(10) )
DROP TABLE dbo.Teste_Live

REVERT


-- Problema de impersonate aqui
SELECT * FROM dbo.Alteracao_Objetos


-- Vamos testar de novo
ALTER ROLE [db_owner] DROP MEMBER [teste-impersonate]
GO

ALTER ROLE [db_datareader] ADD MEMBER [teste-impersonate]
GO

ALTER ROLE [db_datawriter] ADD MEMBER [teste-impersonate]
GO

ALTER ROLE [db_ddladmin] ADD MEMBER [teste-impersonate]
GO

GRANT EXECUTE TO [teste-impersonate]
GO



SELECT USER, USER_NAME(), CURRENT_USER, SESSION_USER, ORIGINAL_LOGIN()

-- ERRO: Cannot execute as the database principal because the principal "teste_db" does not exist, this type of principal cannot be impersonated, or you do not have permission.
EXEC AS USER = 'teste_db'
GO

SELECT USER, USER_NAME(), CURRENT_USER, SESSION_USER, ORIGINAL_LOGIN()

