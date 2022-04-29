
-- Como criar a documentação
CREATE PROCEDURE [dbo].[stpExtendedProperty_Tabela] (
    @Ds_Database sysname,
    @Ds_Tabela sysname,
    @Ds_Schema sysname = 'dbo',
    @Ds_Texto VARCHAR(MAX)
)
AS BEGIN
    

    IF (LEN(LTRIM(RTRIM(@Ds_Texto))) = 0)
    BEGIN
        PRINT 'Texto não informado para a tabela "' + @Ds_Tabela + '" no database "' + @Ds_Database + '"'
        RETURN
    END


    
    DECLARE @query VARCHAR(MAX)
        
    SET @query = '
        
    IF ((SELECT COUNT(*) FROM [' + @Ds_Database + '].sys.extended_properties A JOIN [' + @Ds_Database + '].sys.objects B ON A.major_id = B.object_id WHERE A.class = 1 AND A.name = ''MS_Description'' AND B.name = ''' + @Ds_Tabela + ''') = 0)
    BEGIN
        
        IF ((SELECT COUNT(*) FROM [' + @Ds_Database + '].INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @Ds_Tabela + ''') > 0)
        BEGIN
        
            EXEC [' + @Ds_Database + '].sys.sp_addextendedproperty 
                @name = N''MS_Description'', 
                @value = ''' + @Ds_Texto + ''', 
                @level0type = N''SCHEMA'',
                @level0name = ''' + @Ds_Schema + ''', 
                @level1type = N''TABLE'',
                @level1name = ''' + @Ds_Tabela + '''
                    
        END
        ELSE
            PRINT ''A Tabela "' + @Ds_Database + '.' + @Ds_Schema + '.' + @Ds_Tabela + '" não existe para adicionar ExtendedProperty.''
                
    END
    ELSE BEGIN
            
        EXEC [' + @Ds_Database + '].sys.sp_updateextendedproperty 
            @name = N''MS_Description'', 
            @value = ''' + @Ds_Texto + ''', 
            @level0type = N''SCHEMA'',
            @level0name = ''' + @Ds_Schema + ''', 
            @level1type = N''TABLE'',
            @level1name = ''' + @Ds_Tabela + '''
        
    END
    '
    
    BEGIN TRY
        
        EXEC(@query)
    
    END TRY
    
    BEGIN CATCH

        PRINT @query
 
        DECLARE @MsgErro VARCHAR(MAX) = 'Erro ao adicionar a ExtendedProperty: ' + ISNULL(ERROR_MESSAGE(), '')
        RAISERROR(@MsgErro, 10, 1) WITH NOWAIT
        RETURN

    END CATCH
    
END
GO



CREATE PROCEDURE [dbo].[stpExtendedProperty_Coluna] (
    @Ds_Database sysname,
    @Ds_Tabela sysname,
    @Ds_Schema sysname = 'dbo',
    @Ds_Coluna sysname,
    @Ds_Texto VARCHAR(MAX)
)
AS BEGIN
    

    IF (LEN(LTRIM(RTRIM(@Ds_Texto))) = 0)
    BEGIN
        PRINT 'Texto não informado para a coluna "' + @Ds_Coluna + '" da tabela "' + @Ds_Tabela + '" no database "' + @Ds_Database + '"'
        RETURN
    END


    DECLARE @query VARCHAR(MAX)
        
    SET @query = '
        
    IF ((SELECT COUNT(*) FROM [' + @Ds_Database + '].sys.extended_properties A JOIN [' + @Ds_Database + '].sys.objects B ON A.major_id = B.object_id JOIN [' + @Ds_Database + '].sys.columns C ON B.id = C.object_id AND A.minor_id = C.column_id WHERE A.class = 1 AND A.minor_id > 0 AND A.name = ''MS_Description'' AND B.name = ''' + @Ds_Tabela + ''' AND C.name = ''' + @Ds_Coluna + ''') = 0)
    BEGIN
        
        IF ((SELECT COUNT(*) FROM [' + @Ds_Database + '].INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ''' + @Ds_Tabela + ''' AND COLUMN_NAME = ''' + @Ds_Coluna + ''') > 0)
        BEGIN
        
            EXEC [' + @Ds_Database + '].sys.sp_addextendedproperty 
                @name = N''MS_Description'', 
                @value = ''' + @Ds_Texto + ''', 
                @level0type = N''SCHEMA'',
                @level0name = ''' + @Ds_Schema + ''', 
                @level1type = N''TABLE'',
                @level1name = ''' + @Ds_Tabela + ''',
                @level2type = N''COLUMN'',
                @level2name = ''' + @Ds_Coluna + '''
                    
        END
        ELSE
            PRINT ''A coluna "' + @Ds_Database + '.' + @Ds_Schema + '.' + @Ds_Tabela + '.' + @Ds_Coluna + '" não existe para adicionar ExtendedProperty.''
                
    END
    ELSE BEGIN
            
        EXEC [' + @Ds_Database + '].sys.sp_updateextendedproperty 
            @name = N''MS_Description'', 
            @value = ''' + @Ds_Texto + ''', 
            @level0type = N''SCHEMA'',
            @level0name = ''' + @Ds_Schema + ''', 
            @level1type = N''TABLE'',
            @level1name = ''' + @Ds_Tabela + ''',
            @level2type = N''COLUMN'',
            @level2name = ''' + @Ds_Coluna + '''
        
    END
    '

    
    BEGIN TRY
    
        EXEC(@query)
    
    END TRY
    
    BEGIN CATCH
        
        PRINT @query
 
        DECLARE @MsgErro VARCHAR(MAX) = 'Erro ao adicionar a ExtendedProperty: ' + ISNULL(ERROR_MESSAGE(), '')
        RAISERROR(@MsgErro, 10, 1) WITH NOWAIT
        RETURN

    END CATCH
    
END
GO


CREATE PROCEDURE [dbo].[stpExtendedProperty_View] (
    @Ds_Database sysname,
    @Ds_View sysname,
    @Ds_Schema sysname = 'dbo',
    @Ds_Texto VARCHAR(MAX)
)
AS BEGIN
    

    IF (LEN(LTRIM(RTRIM(@Ds_Texto))) = 0)
    BEGIN
        PRINT 'Texto não informado para a view "' + @Ds_View + '" no database "' + @Ds_Database + '"'
        RETURN
    END
        
        
    DECLARE @query VARCHAR(MAX)
        
    SET @query = '
        
    IF ((SELECT COUNT(*) FROM [' + @Ds_Database + '].sys.extended_properties A JOIN [' + @Ds_Database + '].sys.objects B ON A.major_id = B.object_id WHERE A.class = 1 AND A.name = ''MS_Description'' AND B.name = ''' + @Ds_View + ''') = 0)
    BEGIN
        
        IF ((SELECT COUNT(*) FROM [' + @Ds_Database + '].INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = ''' + @Ds_View + ''') > 0)
        BEGIN
        
            EXEC [' + @Ds_Database + '].sys.sp_addextendedproperty 
                @name = N''MS_Description'', 
                @value = ''' + @Ds_Texto + ''', 
                @level0type = N''SCHEMA'',
                @level0name = ''' + @Ds_Schema + ''', 
                @level1type = N''VIEW'',
                @level1name = ''' + @Ds_View + '''
                    
        END
        ELSE
            PRINT ''A View "' + @Ds_Database + '.' + @Ds_Schema + '.' + @Ds_View + '" não existe para adicionar ExtendedProperty.''
                
    END
    ELSE BEGIN
            
        EXEC [' + @Ds_Database + '].sys.sp_updateextendedproperty 
            @name = N''MS_Description'', 
            @value = ''' + @Ds_Texto + ''', 
            @level0type = N''SCHEMA'',
            @level0name = ''' + @Ds_Schema + ''', 
            @level1type = N''VIEW'',
            @level1name = ''' + @Ds_View + '''
        
    END
    '

    BEGIN TRY
    
        EXEC(@query)
        
    END TRY
    
    BEGIN CATCH
        
        PRINT @query

        DECLARE @MsgErro VARCHAR(MAX) = 'Erro ao adicionar a ExtendedProperty: ' + ISNULL(ERROR_MESSAGE(), '')
        RAISERROR(@MsgErro, 10, 1) WITH NOWAIT
        RETURN

    END CATCH
    
END
GO


CREATE PROCEDURE [dbo].[stpExtendedProperty_Trigger] (
    @Ds_Database sysname,
    @Ds_Tabela sysname,
    @Ds_Schema sysname = 'dbo',
    @Ds_Trigger sysname,
    @Ds_Texto VARCHAR(MAX)
)
AS BEGIN
    

    IF (LEN(LTRIM(RTRIM(@Ds_Texto))) = 0)
    BEGIN
        PRINT 'Texto não informado para a trigger "' + @Ds_Trigger + '" da tabela "' + @Ds_Tabela + '" no database "' + @Ds_Database + '"'
        RETURN
    END

    DECLARE @query VARCHAR(MAX)
        
    SET @query = '
        
    IF ((SELECT COUNT(*) FROM [' + @Ds_Database + '].sys.extended_properties A JOIN [' + @Ds_Database + '].sys.triggers B ON A.major_id = B.object_id JOIN [' + @Ds_Database + '].sys.objects C ON B.parent_id = C.object_id WHERE A.class = 1 AND A.name = ''MS_Description'' AND C.name = ''' + @Ds_Tabela + ''' AND B.name = ''' + @Ds_Trigger + ''') = 0)
    BEGIN
        
        IF ((SELECT COUNT(*) FROM [' + @Ds_Database + '].sys.triggers A JOIN [' + @Ds_Database + '].sys.objects B ON A.parent_id = B.object_id WHERE B.name = ''' + @Ds_Tabela + ''' AND A.name = ''' + @Ds_Trigger + ''') > 0)
        BEGIN
        
            EXEC [' + @Ds_Database + '].sys.sp_addextendedproperty 
                @name = N''MS_Description'', 
                @value = ''' + @Ds_Texto + ''', 
                @level0type = N''SCHEMA'',
                @level0name = ''' + @Ds_Schema + ''', 
                @level1type = N''TABLE'',
                @level1name = ''' + @Ds_Tabela + ''',
                @level2type = N''TRIGGER'',
                @level2name = ''' + @Ds_Trigger + '''
                    
        END
        ELSE
            PRINT ''A trigger "' + @Ds_Database + '.' + @Ds_Schema + '.' + @Ds_Tabela + '.' + @Ds_Trigger + '" não existe para adicionar ExtendedProperty.''
                
    END
    ELSE BEGIN
            
        EXEC [' + @Ds_Database + '].sys.sp_updateextendedproperty 
            @name = N''MS_Description'', 
            @value = ''' + @Ds_Texto + ''', 
            @level0type = N''SCHEMA'',
            @level0name = ''' + @Ds_Schema + ''', 
            @level1type = N''TABLE'',
            @level1name = ''' + @Ds_Tabela + ''',
            @level2type = N''TRIGGER'',
            @level2name = ''' + @Ds_Trigger + '''
        
    END
    '

    
    BEGIN TRY
    
        EXEC(@query)
    
    END TRY
    
    BEGIN CATCH
        
        PRINT @query
 
        DECLARE @MsgErro VARCHAR(MAX) = 'Erro ao adicionar a ExtendedProperty: ' + ISNULL(ERROR_MESSAGE(), '')
        RAISERROR(@MsgErro, 10, 1) WITH NOWAIT
        RETURN

    END CATCH
    
END
GO


CREATE PROCEDURE [dbo].[stpExtendedProperty_Procedure] (
    @Ds_Database sysname,
    @Ds_Procedure sysname,
    @Ds_Schema sysname = 'dbo',
    @Ds_Texto VARCHAR(MAX)
)
AS BEGIN
    

    IF (LEN(LTRIM(RTRIM(@Ds_Texto))) = 0)
    BEGIN
        PRINT 'Texto não informado para a Stored Procedure "' + @Ds_Procedure + '" no database "' + @Ds_Database + '"'
        RETURN
    END
        
        
    DECLARE @query VARCHAR(MAX)
        
    SET @query = '
        
    IF ((SELECT COUNT(*) FROM [' + @Ds_Database + '].sys.extended_properties A JOIN [' + @Ds_Database + '].sys.objects B ON A.major_id = B.object_id WHERE A.class = 1 AND A.name = ''MS_Description'' AND B.name = ''' + @Ds_Procedure + ''') = 0)
    BEGIN
        
        IF ((SELECT COUNT(*) FROM [' + @Ds_Database + '].INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = ''' + @Ds_Procedure + ''') > 0)
        BEGIN
        
            EXEC [' + @Ds_Database + '].sys.sp_addextendedproperty 
                @name = N''MS_Description'', 
                @value = ''' + @Ds_Texto + ''', 
                @level0type = N''SCHEMA'',
                @level0name = ''' + @Ds_Schema + ''', 
                @level1type = N''PROCEDURE'',
                @level1name = ''' + @Ds_Procedure + '''
                    
        END
        ELSE
            PRINT ''A Stored Procedure "' + @Ds_Database + '.' + @Ds_Schema + '.' + @Ds_Procedure + '" não existe para adicionar ExtendedProperty.''
                
    END
    ELSE BEGIN
            
        EXEC [' + @Ds_Database + '].sys.sp_updateextendedproperty 
            @name = N''MS_Description'', 
            @value = ''' + @Ds_Texto + ''', 
            @level0type = N''SCHEMA'',
            @level0name = ''' + @Ds_Schema + ''', 
            @level1type = N''PROCEDURE'',
            @level1name = ''' + @Ds_Procedure + '''
        
    END
    '

    BEGIN TRY
    
        EXEC(@query)
        
    END TRY
    
    BEGIN CATCH
        
        PRINT @query

        DECLARE @MsgErro VARCHAR(MAX) = 'Erro ao adicionar a ExtendedProperty: ' + ISNULL(ERROR_MESSAGE(), '')
        RAISERROR(@MsgErro, 10, 1) WITH NOWAIT
        RETURN

    END CATCH
    
END
GO



CREATE PROCEDURE [dbo].[stpExtendedProperty_Function] (
    @Ds_Database sysname,
    @Ds_Function sysname,
    @Ds_Schema sysname = 'dbo',
    @Ds_Texto VARCHAR(MAX)
)
AS BEGIN
    

    IF (LEN(LTRIM(RTRIM(@Ds_Texto))) = 0)
    BEGIN
        PRINT 'Texto não informado para a Function "' + @Ds_Function + '" no database "' + @Ds_Database + '"'
        RETURN
    END
        
        
    DECLARE @query VARCHAR(MAX)
        
    SET @query = '
        
    IF ((SELECT COUNT(*) FROM [' + @Ds_Database + '].sys.extended_properties A JOIN [' + @Ds_Database + '].sys.objects B ON A.major_id = B.object_id WHERE A.class = 1 AND A.name = ''MS_Description'' AND B.name = ''' + @Ds_Function + ''') = 0)
    BEGIN
        
        IF ((SELECT COUNT(*) FROM [' + @Ds_Database + '].INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = ''' + @Ds_Function + ''') > 0)
        BEGIN
        
            EXEC [' + @Ds_Database + '].sys.sp_addextendedproperty 
                @name = N''MS_Description'', 
                @value = ''' + @Ds_Texto + ''', 
                @level0type = N''SCHEMA'',
                @level0name = ''' + @Ds_Schema + ''', 
                @level1type = N''FUNCTION'',
                @level1name = ''' + @Ds_Function + '''
                    
        END
        ELSE
            PRINT ''A function "' + @Ds_Database + '.' + @Ds_Schema + '.' + @Ds_Function + '" não existe para adicionar ExtendedProperty.''
                
    END
    ELSE BEGIN
            
        EXEC [' + @Ds_Database + '].sys.sp_updateextendedproperty 
            @name = N''MS_Description'', 
            @value = ''' + @Ds_Texto + ''', 
            @level0type = N''SCHEMA'',
            @level0name = ''' + @Ds_Schema + ''', 
            @level1type = N''FUNCTION'',
            @level1name = ''' + @Ds_Function + '''
        
    END
    '

    BEGIN TRY
    
        EXEC(@query)
        
    END TRY
    
    BEGIN CATCH
        
        PRINT @query

        DECLARE @MsgErro VARCHAR(MAX) = 'Erro ao adicionar a ExtendedProperty: ' + ISNULL(ERROR_MESSAGE(), '')
        RAISERROR(@MsgErro, 10, 1) WITH NOWAIT
        RETURN

    END CATCH
    
END
GO


CREATE PROCEDURE [dbo].[stpExtendedProperty_Usuario] (
    @Ds_Database sysname = NULL,
    @Ds_Usuario sysname,
    @Ds_Texto VARCHAR(MAX)
)
AS BEGIN


    IF (LEN(LTRIM(RTRIM(@Ds_Texto))) = 0)
    BEGIN
        PRINT 'Texto não informado para o usuário "' + @Ds_Usuario + '" no database "' + @Ds_Database + '"'
        RETURN
    END



    DECLARE @query VARCHAR(MAX)
        
        
    IF (NULLIF(LTRIM(RTRIM(@Ds_Database)), '') IS NOT NULL)
    BEGIN
        
        SET @query = '
            
        IF ((SELECT COUNT(*) FROM [' + @Ds_Database + '].sys.extended_properties A JOIN [' + @Ds_Database + '].sys.database_principals B ON A.major_id = B.principal_id AND A.class = 4 WHERE A.name = ''MS_Description'' AND B.name = ''' + @Ds_Usuario + ''') = 0)
        BEGIN
            
            IF ((SELECT COUNT(*) FROM [' + @Ds_Database + '].sys.database_principals WHERE name = ''' + @Ds_Usuario + ''') > 0)
            BEGIN
            
                EXEC [' + @Ds_Database + '].sys.sp_addextendedproperty 
                    @name = N''MS_Description'', 
                    @value = ''' + @Ds_Texto + ''',
                    @level0type = N''USER'', 
                    @level0name = N''' + @Ds_Usuario + '''
                        
            END
            ELSE
                PRINT ''O usuário "' + @Ds_Usuario + ' não existe no database "' + @Ds_Database + '" para adicionar ExtendedProperty.''
                    
        END
        ELSE BEGIN
                
            EXEC [' + @Ds_Database + '].sys.sp_updateextendedproperty 
                @name = N''MS_Description'', 
                @value = ''' + @Ds_Texto + ''',
                @level0type = N''USER'', 
                @level0name = N''' + @Ds_Usuario + ''';
            
        END
        '
            
    END
    ELSE BEGIN
        
        SET @query = '
            
        IF ((SELECT COUNT(*) FROM [?].sys.extended_properties A JOIN [?].sys.database_principals B ON A.major_id = B.principal_id AND A.class = 4 WHERE A.name = ''MS_Description'' AND B.name = ''' + @Ds_Usuario + ''') = 0)
        BEGIN
            
            IF ((SELECT COUNT(*) FROM [?].sys.database_principals WHERE name = ''' + @Ds_Usuario + ''') > 0)
            BEGIN
            
                EXEC [?].sys.sp_addextendedproperty 
                    @name = N''MS_Description'', 
                    @value = ''' + @Ds_Texto + ''',
                    @level0type = N''USER'', 
                    @level0name = N''' + @Ds_Usuario + '''
                        
            END
                    
        END
        ELSE BEGIN
            
            IF ((SELECT COUNT(*) FROM [?].sys.database_principals WHERE name = ''' + @Ds_Usuario + ''') > 0)
            BEGIN
                
                EXEC [?].sys.sp_updateextendedproperty 
                    @name = N''MS_Description'', 
                    @value = ''' + @Ds_Texto + ''',
                    @level0type = N''USER'', 
                    @level0name = N''' + @Ds_Usuario + ''';
                        
            END
            
        END
        '
        
    END


    BEGIN TRY
    
        IF (NULLIF(LTRIM(RTRIM(@Ds_Database)), '') IS NOT NULL)
            EXEC(@query)    
        ELSE
            EXEC master.sys.sp_MSforeachdb @query
            
    END TRY
    
    BEGIN CATCH
        
        PRINT @query
 
        DECLARE @MsgErro VARCHAR(MAX) = 'Erro ao adicionar a ExtendedProperty: ' + ISNULL(ERROR_MESSAGE(), '')
        RAISERROR(@MsgErro, 10, 1) WITH NOWAIT
        RETURN

    END CATCH
    
END
GO


CREATE PROCEDURE [dbo].[stpExtendedProperty_Database] (
    @Ds_Database sysname,
    @Ds_Texto VARCHAR(MAX)
)
AS BEGIN


    IF (LEN(LTRIM(RTRIM(@Ds_Texto))) = 0)
    BEGIN
        PRINT 'Texto não informado para a o database "' + @Ds_Database + '"'
        RETURN
    END

    
    DECLARE @query VARCHAR(MAX)
        
    SET @query = '
        
    IF ((SELECT COUNT(*) FROM [' + @Ds_Database + '].sys.extended_properties A WHERE A.class = 0 AND A.name = ''MS_Description'') = 0)
    BEGIN
        
        IF ((SELECT COUNT(*) FROM [' + @Ds_Database + '].sys.databases WHERE name = ''' + @Ds_Database + ''') > 0)
        BEGIN
        
            EXEC [' + @Ds_Database + '].sys.sp_addextendedproperty 
                @name = N''MS_Description'', 
                @value = ''' + @Ds_Texto + '''
                    
        END
        ELSE
            PRINT ''O database "' + @Ds_Database + '" não existe para adicionar ExtendedProperty.''
                
    END
    ELSE BEGIN
            
        EXEC [' + @Ds_Database + '].sys.sp_updateextendedproperty 
            @name = N''MS_Description'', 
            @value = ''' + @Ds_Texto + '''
        
    END
    '

    
    BEGIN TRY
    
        EXEC(@query)
        
    END TRY
    
    BEGIN CATCH
        
        PRINT @query
 
        DECLARE @MsgErro VARCHAR(MAX) = 'Erro ao adicionar a ExtendedProperty: ' + ISNULL(ERROR_MESSAGE(), '')
        RAISERROR(@MsgErro, 10, 1) WITH NOWAIT
        RETURN

    END CATCH
    
END
GO
