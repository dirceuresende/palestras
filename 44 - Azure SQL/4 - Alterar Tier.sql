
-- Manualmente
ALTER DATABASE [dirceu] MODIFY(SERVICE_OBJECTIVE = 'S3')


-- Usando uma Stored Procedure
CREATE OR ALTER PROCEDURE dbo.stpAltera_Tier_DB (
    @ServiceLevelObjective VARCHAR(50),
    @TimeoutEmSegundos INT = 60
)
AS
BEGIN

    SET NOCOUNT ON
 
    DECLARE
        @Query NVARCHAR(MAX),
        @DataHoraLimite DATETIME2 = DATEADD(SECOND, @TimeoutEmSegundos, GETDATE()),
        @ServiceLevelObjectiveAtual VARCHAR(20) = CONVERT(VARCHAR(100), DATABASEPROPERTYEX( DB_NAME(), 'ServiceObjective' ))

    IF (@ServiceLevelObjectiveAtual <> @ServiceLevelObjective)
    BEGIN
        
        SET @Query = N'ALTER DATABASE [' + DB_NAME() + '] MODIFY (SERVICE_OBJECTIVE = ''' + @ServiceLevelObjective + ''');'
        EXEC sp_executesql @Query;
 
        WHILE ((DATABASEPROPERTYEX( DB_NAME(), 'ServiceObjective' ) <> @ServiceLevelObjective) AND GETDATE() <= @DataHoraLimite)
        BEGIN
            WAITFOR DELAY '00:00:00.500';
        END
    END

END



-- Versão simplificada
ALTER DATABASE [dirceu] MODIFY(SERVICE_OBJECTIVE = 'S0')

IF (CONVERT(VARCHAR(100), DATABASEPROPERTYEX( DB_NAME(), 'ServiceObjective' )) <> 'S0')
    WAITFOR DELAY '00:10:00';


ALTER DATABASE [dirceu] MODIFY(SERVICE_OBJECTIVE = 'Basic')
    
    
IF (CONVERT(VARCHAR(100), DATABASEPROPERTYEX( DB_NAME(), 'ServiceObjective' )) <> 'Basic')
    WAITFOR DELAY '00:10:00';
