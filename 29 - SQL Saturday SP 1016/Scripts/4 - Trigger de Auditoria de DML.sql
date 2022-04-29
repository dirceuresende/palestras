/*

Gerando hist�rico atrav�s de trigger no banco de dados:

- Uma vez desenvolvida, a implanta��o do recurso envolve apenas a cria��o de uma tabela e uma trigger no 
banco de dados

- N�o importa qual rotina ou usu�rio esteja manipulando a tabela, todas as altera��es sempre ser�o gravadas

- UPDATE, INSERT e DELETE feitos manualmente no banco de dados ser�o logados e auditados pela trigger, e ser� 
gerado hist�rico para isso

- Tanto o DBA quanto o Desenvolvedor tem visibilidade sobre a exist�ncia da rotina e seu c�digo-fonte

- Se for necess�rio desativar a trigger temporariamente para alguma opera��o, isso pode ser feito em poucos 
segundos pelo DBA

- O gerenciamento da rotina de auditoria fica nas m�os do DBA

- Caso a tabela sofra uma grande altera��o de dados manual, seja via INSERT, DELETE ou UPDATE, todas as 
altera��es ser�o gravadas na tabela de hist�rico, o que pode gerar um volume de grava��es na tabela de hist�rico 
muito grande e causar lentid�o no ambiente. Isso pode ser contornado desativando a trigger enquanto essas 
altera��es em massa s�o realizadas e ativando novamente ao t�rmino

- Caso a altera��o seja realizada pelo sistema, e o sistema utilize um usu�rio fixo, a trigger ir� gravar o 
usu�rio do sistema, e n�o o usu�rio da pessoa que realizou a altera��o



Gerando hist�rico atrav�s do sistema:

- A implementa��o envolve realizar altera��es no c�digo-fonte de todos os trechos de c�digo da aplica��o e 
telas que manipulam dados na tabela envolvida (al�m de arquivos dependentes), onde geralmente existem janelas 
r�gidas para qualquer modifica��o em sistema

- Apenas as telas que foram alteradas para gravar hist�rico efetivamente o far�o

- UPDATE, INSERT e DELETE feitos manualmente no banco de dados N�O ser�o logados e n�o haver� hist�rico para 
essas altera��es

- Apenas o desenvolvedor sabe que esse recurso existe e como ele funciona. O DBA geralmente n�o tem acesso a 
esse tipo de informa��o e muito menos, o c�digo-fonte para entender como esse hist�rico est� sendo gerado

- Se for necess�rio desativar esse recurso temporariamente, o desenvolvedor ter� que alterar no c�digo-fonte 
da aplica��o e fazer o deploy em produ��o, consumindo bastante tempo de duas equipes e com possibilidade de 
desconectar sess�es ativas no servidor de aplica��o

- O gerenciamento da rotina de auditoria fica nas m�os do Desenvolvedor

- Caso a tabela sofra uma grande altera��o de dados manual, seja via INSERT, DELETE ou UPDATE, o ambiente n�o 
ser� afetado, pois altera��es manuais no banco n�o ser�o gravadas

- Caso a altera��o seja realizada pelo sistema, � poss�vel identificar o usu�rio logado na aplica��o e gravar 
o login ou at� mesmo realizar queries no banco e retornar um Id_Usuario da tabela Usuarios, por exemplo, para 
gravar na tabela de hist�rico

- Como voc�s observaram nos itens citados acima, existem vantagens e desvantagens em cada uma das abordagens. 
Sendo assim, voc� dever� decidir qual se encaixa melhor ao seu neg�cio e � sua infraestrutura.

*/


IF (OBJECT_ID('dirceuresende.dbo.Cliente') IS NOT NULL) DROP TABLE dirceuresende.dbo.Cliente
CREATE TABLE dirceuresende.dbo.Cliente (
    Id_Cliente INT IDENTITY(1, 1),
    Nome VARCHAR(100),
    Data_Nascimento DATETIME,
    Salario FLOAT
)
GO

INSERT INTO dirceuresende.dbo.Cliente
VALUES 
    ('Jo�o', '1981-05-14', 4521),
    ('Marcos', '1975-01-07', 1478.58),
    ('Andr�', '1962-11-11', 7151.45),
    ('Sim�o', '1991-12-18', 2584.97),
    ('Pedro', '1986-11-20', 987.52),
    ('Paulo', '1974-08-04', 6259.14),
    ('Jos�', '1979-09-01', 5272.13)
GO



-- Criando a tabela com a mesma estrutura da original, mas adicionando colunas de controle
IF (OBJECT_ID('dirceuresende.dbo.Cliente_Log') IS NOT NULL) DROP TABLE dirceuresende.dbo.Cliente_Log
CREATE TABLE dirceuresende.dbo.Cliente_Log (
    Id INT IDENTITY(1, 1),
    Dt_Atualizacao DATETIME DEFAULT GETDATE(),
    [Login] VARCHAR(100),
    Hostname VARCHAR(100),
    Operacao VARCHAR(20),

    -- Dados da tabela original
    Id_Cliente INT,
    Nome VARCHAR(100),
    Data_Nascimento DATETIME,
    Salario FLOAT
)
GO


USE [dirceuresende]
GO

-- Criando o processo de auditoria
IF ((SELECT COUNT(*) FROM sys.triggers WHERE name = 'trgHistorico_Cliente' AND parent_id = OBJECT_ID('dirceuresende.dbo.Cliente')) > 0)
    DROP TRIGGER trgHistorico_Cliente
GO

CREATE TRIGGER trgHistorico_Cliente ON dirceuresende.dbo.Cliente -- Tabela que a trigger ser� associada
AFTER INSERT, UPDATE, DELETE 
AS
BEGIN
    
    SET NOCOUNT ON

    DECLARE 
        @Login VARCHAR(100) = ORIGINAL_LOGIN(), 
        @HostName VARCHAR(100) = HOST_NAME(),
        @Data DATETIME = GETDATE()
        

    IF (EXISTS(SELECT * FROM Inserted) AND EXISTS (SELECT * FROM Deleted))
    BEGIN
        
        INSERT INTO dirceuresende.dbo.Cliente_Log
        SELECT @Data, @Login, @HostName, 'UPDATE', *
        FROM Inserted

    END
    ELSE BEGIN

        IF (EXISTS(SELECT * FROM Inserted))
        BEGIN

            INSERT INTO dirceuresende.dbo.Cliente_Log
            SELECT @Data, @Login, @HostName, 'INSERT', *
            FROM Inserted

        END
        ELSE BEGIN

            INSERT INTO dirceuresende.dbo.Cliente_Log
            SELECT @Data, @Login, @HostName, 'DELETE', *
            FROM Deleted

        END

    END

END
GO



-- E agora vamos simular algumas altera��es na base:
INSERT INTO dirceuresende.dbo.Cliente
VALUES ('Bartolomeu', '1975-05-28', 6158.74)

WAITFOR DELAY '00:00:00.123'

UPDATE dirceuresende.dbo.Cliente
SET Salario = Salario * 1.5
WHERE Nome = 'Bartolomeu'

WAITFOR DELAY '00:00:00.123'

DELETE FROM dirceuresende.dbo.Cliente
WHERE Nome = 'Andr�'

WAITFOR DELAY '00:00:00.123'

UPDATE dirceuresende.dbo.Cliente
SET Salario = Salario * 1.1
WHERE Id_Cliente = 2

WAITFOR DELAY '00:00:00.123'

UPDATE dirceuresende.dbo.Cliente
SET Salario = 10, Nome = 'Judas Iscariodes', Data_Nascimento = '06/06/2066'
WHERE Id_Cliente = 1

WAITFOR DELAY '00:00:00.123'


-- SELECT * FROM dirceuresende.dbo.Cliente
-- SELECT * FROM dirceuresende.dbo.Cliente_Log

