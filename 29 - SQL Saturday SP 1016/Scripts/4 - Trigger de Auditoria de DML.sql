/*

Gerando histórico através de trigger no banco de dados:

- Uma vez desenvolvida, a implantação do recurso envolve apenas a criação de uma tabela e uma trigger no 
banco de dados

- Não importa qual rotina ou usuário esteja manipulando a tabela, todas as alterações sempre serão gravadas

- UPDATE, INSERT e DELETE feitos manualmente no banco de dados serão logados e auditados pela trigger, e será 
gerado histórico para isso

- Tanto o DBA quanto o Desenvolvedor tem visibilidade sobre a existência da rotina e seu código-fonte

- Se for necessário desativar a trigger temporariamente para alguma operação, isso pode ser feito em poucos 
segundos pelo DBA

- O gerenciamento da rotina de auditoria fica nas mãos do DBA

- Caso a tabela sofra uma grande alteração de dados manual, seja via INSERT, DELETE ou UPDATE, todas as 
alterações serão gravadas na tabela de histórico, o que pode gerar um volume de gravações na tabela de histórico 
muito grande e causar lentidão no ambiente. Isso pode ser contornado desativando a trigger enquanto essas 
alterações em massa são realizadas e ativando novamente ao término

- Caso a alteração seja realizada pelo sistema, e o sistema utilize um usuário fixo, a trigger irá gravar o 
usuário do sistema, e não o usuário da pessoa que realizou a alteração



Gerando histórico através do sistema:

- A implementação envolve realizar alterações no código-fonte de todos os trechos de código da aplicação e 
telas que manipulam dados na tabela envolvida (além de arquivos dependentes), onde geralmente existem janelas 
rígidas para qualquer modificação em sistema

- Apenas as telas que foram alteradas para gravar histórico efetivamente o farão

- UPDATE, INSERT e DELETE feitos manualmente no banco de dados NÃO serão logados e não haverá histórico para 
essas alterações

- Apenas o desenvolvedor sabe que esse recurso existe e como ele funciona. O DBA geralmente não tem acesso a 
esse tipo de informação e muito menos, o código-fonte para entender como esse histórico está sendo gerado

- Se for necessário desativar esse recurso temporariamente, o desenvolvedor terá que alterar no código-fonte 
da aplicação e fazer o deploy em produção, consumindo bastante tempo de duas equipes e com possibilidade de 
desconectar sessões ativas no servidor de aplicação

- O gerenciamento da rotina de auditoria fica nas mãos do Desenvolvedor

- Caso a tabela sofra uma grande alteração de dados manual, seja via INSERT, DELETE ou UPDATE, o ambiente não 
será afetado, pois alterações manuais no banco não serão gravadas

- Caso a alteração seja realizada pelo sistema, é possível identificar o usuário logado na aplicação e gravar 
o login ou até mesmo realizar queries no banco e retornar um Id_Usuario da tabela Usuarios, por exemplo, para 
gravar na tabela de histórico

- Como vocês observaram nos itens citados acima, existem vantagens e desvantagens em cada uma das abordagens. 
Sendo assim, você deverá decidir qual se encaixa melhor ao seu negócio e à sua infraestrutura.

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
    ('João', '1981-05-14', 4521),
    ('Marcos', '1975-01-07', 1478.58),
    ('André', '1962-11-11', 7151.45),
    ('Simão', '1991-12-18', 2584.97),
    ('Pedro', '1986-11-20', 987.52),
    ('Paulo', '1974-08-04', 6259.14),
    ('José', '1979-09-01', 5272.13)
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

CREATE TRIGGER trgHistorico_Cliente ON dirceuresende.dbo.Cliente -- Tabela que a trigger será associada
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



-- E agora vamos simular algumas alterações na base:
INSERT INTO dirceuresende.dbo.Cliente
VALUES ('Bartolomeu', '1975-05-28', 6158.74)

WAITFOR DELAY '00:00:00.123'

UPDATE dirceuresende.dbo.Cliente
SET Salario = Salario * 1.5
WHERE Nome = 'Bartolomeu'

WAITFOR DELAY '00:00:00.123'

DELETE FROM dirceuresende.dbo.Cliente
WHERE Nome = 'André'

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

