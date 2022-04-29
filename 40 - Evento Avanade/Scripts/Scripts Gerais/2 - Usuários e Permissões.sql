
-- Permissões a nível de banco
SELECT
    A.class_desc AS Ds_Tipo_Permissao, 
    A.[permission_name] AS Ds_Permissao,
    A.state_desc AS Ds_Operacao,
    B.[name] AS Ds_Usuario_Permissao,
    C.[name] AS Ds_Login_Permissao,
    D.[name] AS Ds_Objeto
FROM 
    sys.database_permissions A
    JOIN sys.database_principals B ON A.grantee_principal_id = B.principal_id
    LEFT JOIN sys.server_principals C ON B.[sid] = C.[sid]
    LEFT JOIN sys.objects D ON A.major_id = D.[object_id]
WHERE
    A.major_id >= 0
    
      
    
-- Usuários e database roles
SELECT
    C.[name] AS Ds_Usuario,
    B.[name] AS Ds_Database_Role
FROM 
    sys.database_role_members A
    JOIN sys.database_principals B ON A.role_principal_id = B.principal_id
    JOIN sys.database_principals C ON A.member_principal_id = C.principal_id
    
    
    
-- Logins e Server roles
SELECT 
    B.[name] AS Ds_Usuario,
    C.[name] AS Ds_Server_Role
FROM 
    sys.server_role_members A
    JOIN sys.server_principals B ON A.member_principal_id = B.principal_id
    JOIN sys.server_principals C ON A.role_principal_id = C.principal_id
    
    
    
-- Permissões a nível de instância
SELECT
    A.class_desc AS Ds_Tipo_Permissao,
    A.state_desc AS Ds_Tipo_Operacao,
    A.[permission_name] AS Ds_Permissao,
    B.[name] AS Ds_Login,
    B.[type_desc] AS Ds_Tipo_Login
FROM 
    sys.server_permissions A
    JOIN sys.server_principals B ON A.grantee_principal_id = B.principal_id
WHERE
    B.[name] NOT LIKE '##%'
ORDER BY
    B.[name],
    A.[permission_name]
    
    
    
-- Usuários órfãos
SELECT
    A.[name],
    A.[sid],
    (CASE 
        WHEN C.principal_id IS NULL THEN NULL -- Não tem o que fazer.. Login correspondente não existe
        ELSE 'ALTER USER [' + A.[name] + '] WITH LOGIN = [' + C.[name] + ']' -- Tenta corrigir o usuário órfão
    END) AS command
FROM
    sys.database_principals A WITH(NOLOCK)
    LEFT JOIN sys.sql_logins B WITH(NOLOCK) ON A.[sid] = B.[sid]
    LEFT JOIN sys.server_principals C WITH(NOLOCK) ON (A.[name] COLLATE SQL_Latin1_General_CP1_CI_AI = C.[name] COLLATE SQL_Latin1_General_CP1_CI_AI OR A.[sid] = C.[sid]) AND C.is_fixed_role = 0 AND C.[type_desc] = 'SQL_LOGIN'
WHERE
    A.principal_id > 4
    AND B.[sid] IS NULL
    AND A.is_fixed_role = 0
    AND A.[type_desc] = 'SQL_USER'
    AND A.authentication_type <> 0 -- NONE
ORDER BY
    A.[name]
    