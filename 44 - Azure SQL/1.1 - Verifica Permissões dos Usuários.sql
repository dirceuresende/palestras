
-----------------------------------------------------
-- Permissões a nível de database
-----------------------------------------------------

DECLARE @query VARCHAR(MAX);
 

SET @query = '
SELECT DISTINCT
    ' + CHAR( 39 ) + DB_NAME(DB_ID()) + CHAR( 39 ) + ' [Database],
    C.name [Schema],
    COALESCE(B.name, E.name) [Object],
    COALESCE(B.type_desc, E.type_desc) AS [object_type],
    D.name username,
    A.type permissions_type,
    A.permission_name,
    A.state permission_state,
    A.state_desc,
    (CASE WHEN B.is_ms_shipped = 1 OR E.[object_id] IS NOT NULL OR B.name IN (''sysdiagrams'', ''sp_upgraddiagrams'', ''sp_helpdiagrams'', ''sp_helpdiagramdefinition'', ''sp_creatediagram'', ''sp_renamediagram'', ''sp_alterdiagram'', ''sp_dropdiagram'', ''fn_diagramobjects'') THEN 1 ELSE 0 END) AS [system_object],
    (CASE WHEN A.class = 1
        THEN ' + CHAR( 39 ) + 'REVOKE ' + CHAR( 39 ) + ' + A.permission_name + ' + CHAR( 39 ) + ' ON [' + CHAR( 39 ) + ' + C.name + ' + CHAR( 39 ) + '].[' + CHAR( 39 ) + ' + COALESCE(B.name, C.name) + ' + CHAR( 39 ) + '] FROM [' + CHAR( 39 ) + ' + D.name + ' + CHAR( 39 ) + '];' + CHAR( 39 ) + ' COLLATE LATIN1_General_CI_AS
        ELSE ' + +CHAR( 39 ) + 'REVOKE ' + CHAR( 39 ) + ' + A.permission_name + ' + CHAR( 39 ) + ' FROM [' + CHAR( 39 ) + ' + D.name + ' + CHAR( 39 ) + '];' + CHAR( 39 ) + ' COLLATE LATIN1_General_CI_AS
    END) AS remover,
    (CASE WHEN A.class = 1
        THEN A.state_desc + '' '' + A.permission_name + ' + CHAR( 39 ) + ' ON [' + CHAR( 39 ) + ' + C.name + ' + CHAR( 39 ) + '].[' + CHAR( 39 ) + ' + COALESCE(B.name, C.name) + ' + CHAR( 39 ) + '] TO [' + CHAR( 39 ) + ' + D.name + ' + CHAR( 39 ) + '];' + CHAR( 39 ) + ' COLLATE LATIN1_General_CI_AS 
        ELSE A.state_desc + '' '' + A.permission_name + ' + CHAR( 39 ) + ' TO [' + CHAR( 39 ) + ' + D.name + ' + CHAR( 39 ) + '];' + CHAR( 39 ) + ' COLLATE LATIN1_General_CI_AS
    END) AS conceder
FROM
    sys.database_permissions        A WITH(NOLOCK)
    LEFT JOIN sys.objects           B WITH(NOLOCK) ON A.major_id = B.object_id
    LEFT JOIN sys.schemas           C WITH(NOLOCK) ON B.schema_id = C.schema_id
    JOIN sys.database_principals    D WITH(NOLOCK) ON A.grantee_principal_id = D.principal_id
    LEFT JOIN sys.system_objects    E WITH(NOLOCK) ON A.major_id = E.object_id
WHERE
    (
        (COALESCE(B.name, E.name) IS NOT NULL AND A.class = 1)
        OR (A.class NOT IN (1, 6))
    )
ORDER BY
    1, 2, 3, 5';
 

 
 IF (OBJECT_ID('tempdb..#Object_Permissions') IS NOT NULL) DROP TABLE #Object_Permissions
CREATE TABLE #Object_Permissions (
    [database]         sysname,
    [schema]           sysname     NULL,
    [object]           sysname     NULL,
    [object_type]      sysname     NULL,
    [username]         sysname,
    [permission_type]  sysname,
    [permission_name]  sysname,
    [permission_state] sysname,
    [state_desc]       sysname,
    [system_object]    BIT,
    [remover]          VARCHAR(MAX),
    [conceder]         VARCHAR(MAX)
);
 
 
INSERT INTO #Object_Permissions 
EXEC(@query)
 
 
-- Roles
IF (OBJECT_ID('tempdb..#Role_Permissions') IS NOT NULL) DROP TABLE #Role_Permissions
CREATE TABLE #Role_Permissions (
    DBName            sysname,
    UserName          sysname,
    LoginType         sysname,
    DefaultUser       BIT,
    AssociatedRole    VARCHAR(MAX),
    create_date       DATETIME,
    modify_date       DATETIME,
    grant_permission  VARCHAR(MAX),
    revoke_permission VARCHAR(MAX)
);
 

SET @query = '
SELECT DISTINCT
    ' + CHAR( 39 ) + DB_NAME(DB_ID()) + CHAR( 39 ) + ' [Database],
    prin.name AS UserName,
    prin.type_desc AS LoginType,
    (CASE WHEN prin.principal_id < 5 THEN 1 ELSE 0 END) AS default_user,
    role.[name] AS AssociatedRole,
    prin.create_date,
    prin.modify_date,
    ''ALTER ROLE ['' + role.[name] + ''] ADD MEMBER ['' + prin.[name] + ''];'' AS grant_permission,
    ''ALTER ROLE ['' + role.[name] + ''] DROP MEMBER ['' + prin.[name] + ''];'' AS revoke_permission
FROM 
    sys.database_principals                 prin    WITH(NOLOCK)
    JOIN sys.database_role_members          mem     WITH(NOLOCK) ON prin.principal_id = mem.member_principal_id
    JOIN sys.database_principals            role  WITH(NOLOCK) ON mem.role_principal_id = role.principal_id
WHERE 
    prin.sid IS NOT NULL 
    AND prin.principal_id > 4
    AND prin.is_fixed_role <> 1
    AND prin.name NOT LIKE ''##%''';
 

INSERT #Role_Permissions
EXEC(@query)
    
    
 
IF (OBJECT_ID('tempdb..#Tabela_Final') IS NOT NULL) DROP TABLE #Tabela_Final
CREATE TABLE #Tabela_Final (
    [database]        NVARCHAR(128),
    [schema]          NVARCHAR(128),
    [object]          NVARCHAR(128),
    [permission_type] VARCHAR(19),
    [system_object]   BIT,
    [username]        NVARCHAR(128),
    [object_type]     NVARCHAR(128),
    [permission_name] NVARCHAR(MAX),
    [read_only]       BIT,
    [state_desc]      NVARCHAR(128),
    [remover]         VARCHAR(MAX),
    [conceder]        VARCHAR(MAX)
);
 
 
 
INSERT INTO #Tabela_Final
SELECT DISTINCT
    [database],
    [schema],
    [object],
    ( CASE WHEN object_type IS NULL THEN 'DATABASE_PERMISSION' ELSE 'DATABASE_OBJECT' END ) AS [permission_type],
    system_object,
    username,
    object_type,
    [permission_name],
    ( CASE
            WHEN object_type = 'SQL_SCALAR_FUNCTION'
                OR [permission_name] LIKE 'VIEW %'
                OR [permission_name] IN ( 'SELECT', 'CONNECT', 'REFERENCES', 'SHOWPLAN' ) THEN 1
            ELSE 0
        END
    )                                                                                       AS [read_only],
    state_desc,
    remover,
    conceder
FROM
    #Object_Permissions
WHERE
    [username] <> 'dbo'
    AND system_object = 0
            
UNION ALL
 
SELECT DISTINCT
    DBName                                                                                                          AS [database],
    NULL                                                                                                            AS [schema],
    NULL                                                                                                            AS [object],
    'DATABASE_ROLE'                                                                                                 AS [object_type],
    DefaultUser                                                                                                     AS system_object,
    UserName                                                                                                        AS username,
    LoginType                                                                                                       AS permission_type,
    ISNULL( NULLIF(AssociatedRole, ''), 'public' )                                                                  AS [permission_name],
    ( CASE WHEN AssociatedRole IN ( 'db_datareader', 'SQLAgentUserRole', 'SQLAgentReaderRole' ) THEN 1 ELSE 0 END ) AS [read_only],
    'GRANT'                                                                                                         AS [state_desc],
    revoke_permission                                                                                               AS remover,
    grant_permission                                                                                                AS conceder
FROM
    #Role_Permissions
WHERE
    [UserName] <> 'dbo'
    AND DefaultUser = 0

 
UNION ALL
 

SELECT DISTINCT
    NULL                                                                                 AS [DB_Name],
    NULL                                                                                 AS [schema],
    NULL                                                                                 AS [object],
    'SERVER_ROLE'                                                                        AS [permission_type],
    ( CASE WHEN A.principal_id < 10 THEN 1 ELSE 0 END )                                  AS system_object,
    A.[name]                                                                             AS UserName,
    A.[type_desc]                                                                        AS LoginType,
    C.[name] COLLATE SQL_Latin1_General_CP1_CI_AI                                        AS AssociatedRole,
    0                                                                                    AS [read_only],
    'GRANT'                                                                              AS [state_desc],
    'ALTER SERVER ROLE [' + C.[name] + '] DROP MEMBER [' + A.[name] + '];' AS revoke_permission,
    'ALTER SERVER ROLE [' + C.[name] + '] ADD MEMBER [' + A.[name] + '];'  AS grant_permission
FROM
    sys.server_principals        A WITH ( NOLOCK )
    JOIN sys.server_role_members B WITH ( NOLOCK ) ON A.principal_id = B.member_principal_id
    JOIN sys.server_principals   C WITH ( NOLOCK ) ON B.role_principal_id = C.principal_id
WHERE
    A.[sid] IS NOT NULL
    AND A.is_disabled = 0
    AND A.[type] <> 'C' -- CERTIFICATE_MAPPED_LOGIN
    AND A.[name] NOT LIKE 'NT SERVICE\%'
    AND A.[name] NOT LIKE 'NT AUTHORITY\%'
    AND A.[name] NOT LIKE 'BUILTIN\%'


SELECT * FROM #Tabela_Final
