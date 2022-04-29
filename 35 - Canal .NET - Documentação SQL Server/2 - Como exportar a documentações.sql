-- Como exportar as documentações
SELECT
    'EXEC sys.sp_addextendedproperty @name = ''' + REPLACE(CAST(A.name AS NVARCHAR(300)), '''', '''''') + ''' ,@value = ''' + REPLACE(CAST(A.value AS NVARCHAR(4000)), '''', '''''') + ''''
FROM
    sys.extended_properties A
WHERE
    class_desc = N'DATABASE';


SELECT
    'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + B.name + '] ,@name = ''' + REPLACE(CAST(A.name AS NVARCHAR(300)), '''', '''''') + ''' ,@value = ''' + REPLACE(CAST(A.value AS NVARCHAR(4000)), '''', '''''') + ''''
FROM
    sys.extended_properties A
    INNER JOIN sys.schemas B ON A.major_id = B.schema_id
WHERE
    A.class_desc = N'SCHEMA';


SELECT
    'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + B.name + '], @level1type = ''TABLE'', @level1name = [' + A.name + '] ,@name = ''' + REPLACE(CAST(C.name AS NVARCHAR(300)), '''', '''''') + ''' ,@value = ''' + REPLACE(CAST(C.value AS NVARCHAR(4000)), '''', '''''') + ''''
FROM
    sys.tables A
    INNER JOIN sys.schemas B ON A.schema_id = B.schema_id
    INNER JOIN sys.extended_properties C ON A.object_id = C.major_id
WHERE
    C.class = 1
    AND C.minor_id = 0
    AND
    (
        C.value <> '1'
        AND C.value <> 1
    );


SELECT
    'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + D.name + '], @level1type = ''TABLE'', @level1name = [' + C.name + '] , @level2type = ''COLUMN'', @level2name = [' + B.name + '] ,@name = ''' + REPLACE(CAST(A.name AS NVARCHAR(300)), '''', '''''') + ''' ,@value = ''' + REPLACE(CAST(A.value AS NVARCHAR(4000)), '''', '''''') + ''''
FROM
    sys.extended_properties A
    INNER JOIN sys.columns B ON A.major_id = B.object_id AND A.minor_id = B.column_id
    INNER JOIN sys.tables C ON A.major_id = C.object_id
    INNER JOIN sys.schemas D ON C.schema_id = D.schema_id
WHERE
    A.class = 1
    AND
    (
        A.value <> '1'
        AND A.value <> 1
    );


SELECT
    'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + B.name + '], @level1type = ''TABLE'', @level1name = [' + A.name + '] , @level2type = ''CONSTRAINT'', @level2name = [' + D.name + '] ,@name = ''' + REPLACE(CAST(C.name AS NVARCHAR(300)), '''', '''''') + ''' ,@value = ''' + REPLACE(CAST(C.value AS NVARCHAR(4000)), '''', '''''') + ''''
FROM
    sys.tables A
    INNER JOIN sys.schemas B ON A.schema_id = B.schema_id
    INNER JOIN sys.extended_properties C
    INNER JOIN sys.key_constraints D ON C.major_id = D.object_id ON A.object_id = D.parent_object_id
WHERE
    D.type_desc = N'PRIMARY_KEY_CONSTRAINT';


SELECT
    'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + B.name + '], @level1type = ''TABLE'', @level1name = [' + A.name + '] , @level2type = ''CONSTRAINT'', @level2name = [' + D.name + '] ,@name = ''' + REPLACE(CAST(C.name AS NVARCHAR(300)), '''', '''''') + ''' ,@value = ''' + REPLACE(CAST(C.value AS NVARCHAR(4000)), '''', '''''') + ''''
FROM
    sys.tables A
    INNER JOIN sys.schemas B ON A.schema_id = B.schema_id
    INNER JOIN sys.extended_properties C
    INNER JOIN sys.key_constraints D ON C.major_id = D.object_id ON A.object_id = D.parent_object_id
WHERE
    D.type_desc = N'UNIQUE_CONSTRAINT'
    AND
    (
        C.value <> '1'
        AND C.value <> 1
    );


SELECT
    'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + C.name + '], @level1type = ''TABLE'', @level1name = [' + D.name + '] , @level2type = ''CONSTRAINT'', @level2name = [' + B.name + '] ,@name = ''' + REPLACE(CAST(A.name AS NVARCHAR(300)), '''', '''''') + ''' ,@value = ''' + REPLACE(CAST(A.value AS NVARCHAR(4000)), '''', '''''') + ''''
FROM
    sys.extended_properties A
    INNER JOIN sys.check_constraints B ON A.major_id = B.object_id
    INNER JOIN sys.schemas C
    INNER JOIN sys.tables D ON C.schema_id = D.schema_id ON B.parent_object_id = D.object_id;


SELECT
    'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + D.name + '], @level1type = ''TABLE'', @level1name = [' + C.name + '] , @level2type = ''INDEX'', @level2name = [' + A.name + '] ,@name = ''' + REPLACE(CAST(B.name AS NVARCHAR(300)), '''', '''''') + ''' ,@value = ''' + REPLACE(CAST(B.value AS NVARCHAR(4000)), '''', '''''') + ''''
FROM
    sys.indexes A
    INNER JOIN sys.extended_properties B ON A.object_id = B.major_id AND A.index_id = B.minor_id
    INNER JOIN sys.tables C
    INNER JOIN sys.schemas D ON C.schema_id = D.schema_id ON A.object_id = C.object_id
WHERE
    B.class_desc = N'INDEX'
    AND A.is_primary_key = 0;


SELECT
    'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + D.name + '], @level1type = ''TABLE'', @level1name = [' + C.name + '] , @level2type = ''CONSTRAINT'', @level2name = [' + B.name + '] ,@name = ''' + REPLACE(CAST(A.name AS NVARCHAR(300)), '''', '''''') + ''' ,@value = ''' + REPLACE(CAST(A.value AS NVARCHAR(4000)), '''', '''''') + ''''
FROM
    sys.extended_properties A
    INNER JOIN sys.foreign_keys B ON A.major_id = B.object_id
    INNER JOIN sys.tables C ON B.parent_object_id = C.object_id
    INNER JOIN sys.schemas D ON C.schema_id = D.schema_id;


SELECT
    'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + B.name + '], @level1type = ''TABLE'', @level1name = [' + C.name + '] , @level2type = ''CONSTRAINT'', @level2name = [' + A.name + '] ,@name = ''' + REPLACE(CAST(D.name AS NVARCHAR(300)), '''', '''''') + ''' ,@value = ''' + REPLACE(CAST(D.value AS NVARCHAR(4000)), '''', '''''') + ''''
FROM
    sys.default_constraints A
    INNER JOIN sys.schemas B
    INNER JOIN sys.tables C ON B.schema_id = C.schema_id ON A.parent_object_id = C.object_id
    INNER JOIN sys.extended_properties D ON A.object_id = D.major_id;


SELECT
    'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + C.name + '], @level1type = ''VIEW'', @level1name = [' + B.name + '] ,@name = ''' + REPLACE(CAST(A.name AS NVARCHAR(300)), '''', '''''') + ''' ,@value = ''' + REPLACE(CAST(A.value AS NVARCHAR(4000)), '''', '''''') + ''''
FROM
    sys.extended_properties A
    INNER JOIN sys.views B ON A.major_id = B.object_id
    INNER JOIN sys.schemas C ON B.schema_id = C.schema_id
WHERE
    A.minor_id = 0;


SELECT
    'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + D.name + '], @level1type = ''VIEW'', @level1name = [' + C.name + '] , @level2type = ''COLUMN'', @level2name = [' + B.name + '] ,@name = ''' + REPLACE(CAST(A.name AS NVARCHAR(300)), '''', '''''') + ''' ,@value = ''' + REPLACE(CAST(A.value AS NVARCHAR(4000)), '''', '''''') + ''''
FROM
    sys.extended_properties A
    INNER JOIN sys.columns B ON A.major_id = B.object_id AND A.minor_id = B.column_id
    INNER JOIN sys.views C ON A.major_id = C.object_id
    INNER JOIN sys.schemas D ON C.schema_id = D.schema_id
WHERE
    A.class = 1
    AND
    (
        A.value <> '1'
        AND A.value <> 1
    );


SELECT
    'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + D.name + '], @level1type = ''VIEW'', @level1name = [' + C.name + '] , @level2type = ''INDEX'', @level2name = [' + A.name + '] ,@name = ''' + REPLACE(CAST(B.name AS NVARCHAR(300)), '''', '''''') + ''' ,@value = ''' + REPLACE(CAST(B.value AS NVARCHAR(4000)), '''', '''''') + ''''
FROM
    sys.indexes A
    INNER JOIN sys.extended_properties B ON A.object_id = B.major_id AND A.index_id = B.minor_id
    INNER JOIN sys.views C
    INNER JOIN sys.schemas D ON C.schema_id = D.schema_id ON A.object_id = C.object_id
WHERE
    B.class_desc = N'INDEX';


SELECT
    'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + C.name + '], @level1type = ''FUNCTION'', @level1name = [' + B.name + '] ,@name = ''' + REPLACE(CAST(A.name AS NVARCHAR(300)), '''', '''''') + ''' ,@value = ''' + REPLACE(CAST(A.value AS NVARCHAR(4000)), '''', '''''') + ''''
FROM
    sys.extended_properties A
    INNER JOIN sys.objects B ON A.major_id = B.object_id
    INNER JOIN sys.schemas C ON B.schema_id = C.schema_id
WHERE
    B.type_desc LIKE N'%FUNCTION%'
    AND A.minor_id = 0;


SELECT
    'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + C.name + '], @level1type = ''PROCEDURE'', @level1name = [' + B.name + '] ,@name = ''' + REPLACE(CAST(A.name AS NVARCHAR(300)), '''', '''''') + ''' ,@value = ''' + REPLACE(CAST(A.value AS NVARCHAR(4000)), '''', '''''') + ''''
FROM
    sys.extended_properties A
    INNER JOIN sys.procedures B ON A.major_id = B.object_id
    INNER JOIN sys.schemas C ON B.schema_id = C.schema_id
WHERE
    A.minor_id = 0;


SELECT
    'EXEC sys.sp_addextendedproperty @level0type = N''TRIGGER'', @level0name = [' + B.name + '] ,@name = ''' + REPLACE(CAST(A.name AS NVARCHAR(300)), '''', '''''') + ''' ,@value = ''' + REPLACE(CAST(A.value AS NVARCHAR(4000)), '''', '''''') + ''''
FROM
    sys.extended_properties A
    INNER JOIN sys.triggers B ON A.major_id = B.object_id
WHERE
    B.parent_class_desc = N'DATABASE';


SELECT
    'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + D.name + '], @level1type = ''TABLE'', @level1name = [' + A.name + '] , @level2type = ''TRIGGER'', @level2name = [' + B.name + '] ,@name = ''' + REPLACE(CAST(C.name AS NVARCHAR(300)), '''', '''''') + ''' ,@value = ''' + REPLACE(CAST(C.value AS NVARCHAR(4000)), '''', '''''') + ''''
FROM
    sys.tables A
    INNER JOIN sys.triggers B ON A.object_id = B.parent_id
    INNER JOIN sys.extended_properties C ON B.object_id = C.major_id
    INNER JOIN sys.schemas D ON A.schema_id = D.schema_id;


SELECT
    'EXEC sys.sp_addextendedproperty @level0type = N''SCHEMA'', @level0name = [' + D.name + '], @level1type = ''VIEW'', @level1name = [' + A.name + '] , @level2type = ''TRIGGER'', @level2name = [' + B.name + '] ,@name = ''' + REPLACE(CAST(C.name AS NVARCHAR(300)), '''', '''''') + ''' ,@value = ''' + REPLACE(CAST(C.value AS NVARCHAR(4000)), '''', '''''') + ''''
FROM
    sys.views A
    INNER JOIN sys.triggers B ON A.object_id = B.parent_id
    INNER JOIN sys.extended_properties C ON B.object_id = C.major_id
    INNER JOIN sys.schemas D ON A.schema_id = D.schema_id;


SELECT
    'EXEC sys.sp_addextendedproperty @level0type = N''PARTITION FUNCTION'', @level0name = [' + B.name + '] ,@name = ''' + REPLACE(CAST(A.name AS NVARCHAR(300)), '''', '''''') + ''' ,@value = ''' + REPLACE(CAST(A.value AS NVARCHAR(4000)), '''', '''''') + ''''
FROM
    sys.extended_properties A
    INNER JOIN sys.partition_functions B ON A.major_id = B.function_id;


SELECT
    'EXEC sys.sp_addextendedproperty @level0type = N''PARTITION SCHEME'', @level0name = [' + B.name + '] ,@name = ''' + REPLACE(CAST(A.name AS NVARCHAR(300)), '''', '''''') + ''' ,@value = ''' + REPLACE(CAST(A.value AS NVARCHAR(4000)), '''', '''''') + ''''
FROM
    sys.extended_properties A
    INNER JOIN sys.partition_schemes B ON A.major_id = B.function_id;


SELECT
    'EXEC sys.sp_addextendedproperty @level0type = N''FILEGROUP'', @level0name = [' + B.name + '] ,@name = ''' + REPLACE(CAST(A.name AS NVARCHAR(300)), '''', '''''') + ''' ,@value = ''' + REPLACE(CAST(A.value AS NVARCHAR(4000)), '''', '''''') + ''''
FROM
    sys.extended_properties A
    INNER JOIN sys.data_spaces B ON A.major_id = B.data_space_id
WHERE
    B.type_desc = 'ROWS_FILEGROUP';


SELECT
    'EXEC sys.sp_addextendedproperty @level0type = N''FILEGROUP'', @level0name = [' + C.name + '], @level1type = ''LOGICAL FILE NAME'', @level1name = ' + B.name + ' ,@name = ''' + REPLACE(CAST(A.name AS NVARCHAR(300)), '''', '''''') + ''' ,@value = ''' + REPLACE(CAST(A.value AS NVARCHAR(4000)), '''', '''''') + ''''
FROM
    sys.extended_properties A
    INNER JOIN sys.database_files B ON A.major_id = B.file_id
    INNER JOIN sys.data_spaces C ON B.data_space_id = C.data_space_id
WHERE
    A.class_desc = N'DATABASE_FILE';
	
	
	