
-----------------------------------------------
-- Horário hora atual utilizando o fuso local
-----------------------------------------------

SELECT GETDATE()


-----------------------------------------------
-- Voltando 3h para ficar igual ao Brasil
-----------------------------------------------

SELECT DATEADD(HOUR, -3, GETDATE())


-----------------------------------------------
-- Conhecendo as funções de hora
-----------------------------------------------

SELECT
    SYSDATETIMEOFFSET() AT TIME ZONE 'E. South America Standard Time',
    TODATETIMEOFFSET(GETDATE(), -90), -- Alterando o fuso para -90 minutos de diferença
    TODATETIMEOFFSET(GETDATE(), '-08:00') -- Alterando o fuso para -3 horas de diferença


SELECT
    GETUTCDATE() AT TIME ZONE 'E. South America Standard Time', -- Retorna DATETIME no timezone UTC/GMT.
    SYSUTCDATETIME() AT TIME ZONE 'E. South America Standard Time' -- Retorna DATETIME2 no timezone UTC/GMT


SELECT
    GETDATE() AT TIME ZONE 'E. South America Standard Time', -- Retorna DATETIME no timezone do servidor (no Azure SQL, é sempre UTC).
    SYSDATETIME() AT TIME ZONE 'E. South America Standard Time' -- Retorna DATETIME2 no timezone do servidor (no Azure SQL, é sempre UTC).


-----------------------------------------------
-- Listar os timezones
-----------------------------------------------

SELECT * FROM sys.time_zone_info


-----------------------------------------------
-- Quer facilitar um pouco?
-----------------------------------------------

GO
CREATE OR ALTER FUNCTION dbo.getdateBrasil()
RETURNS DATETIME
WITH SCHEMABINDING
BEGIN
    RETURN CONVERT(DATETIME, SYSDATETIMEOFFSET() AT TIME ZONE 'E. South America Standard Time');
END;
GO

SELECT dbo.getdateBrasil()


-----------------------------------------------
-- Alterando uma data já existente
-----------------------------------------------

DECLARE @DataTeste DATETIME = '2023-02-07 10:26:22' -- Não pode ser DATETIME ou DATETIME2

SELECT
    @DataTeste AT TIME ZONE 'E. South America Standard Time' AS DataConvertidaComFuso,
    CONVERT(DATETIME, @DataTeste AT TIME ZONE 'E. South America Standard Time') DataConvertidaSemFuso


DECLARE @DataTeste DATETIMEOFFSET = '2023-02-07 10:26:22' -- Com DATETIMEOFFSET funciona :)

SELECT
    @DataTeste AT TIME ZONE 'E. South America Standard Time' AS DataConvertidaComFuso,
    CONVERT(DATETIME, @DataTeste AT TIME ZONE 'E. South America Standard Time') DataConvertidaSemFuso



-----------------------------------------------
-- Convertendo as horas para tirar o formato de fuso horário
-----------------------------------------------

SELECT
    CONVERT(DATETIME, SYSDATETIMEOFFSET() AT TIME ZONE 'E. South America Standard Time'),
    CONVERT(DATETIME2, SYSDATETIMEOFFSET() AT TIME ZONE 'E. South America Standard Time')


-- Convertendo para outro fuso
DECLARE @DataHora1 DATETIMEOFFSET = SYSDATETIMEOFFSET() AT TIME ZONE 'E. South America Standard Time'

SELECT
    @DataHora1,
    CONVERT(DATETIME, DATEADD(MINUTE, DATEPART(TZOFFSET, @DataHora1), @DataHora1))


DECLARE @DataHora2 DATETIME = '2023-02-07 10:26:22'

SELECT
    @DataHora2 AS [Data/Hora Original],

    -- Alterando usando timezone fixo
    CONVERT(DATETIME, DATEADD(MINUTE, DATEPART(TZOFFSET, @DataHora2 AT TIME ZONE 'E. South America Standard Time'), @DataHora2)) AS [E. South America Standard Time],
    CONVERT(DATETIME, DATEADD(MINUTE, DATEPART(TZOFFSET, @DataHora2 AT TIME ZONE 'Pacific Standard Time'), @DataHora2)) AS [Pacific Standard Time],

    -- Alterando utilizando variação fixa em horas ou minutos
    CONVERT(DATETIME, DATEADD(MINUTE, DATEPART(TZOFFSET, TODATETIMEOFFSET(@DataHora2, '+08:00')), @DataHora2)) AS [+08:00],
    CONVERT(DATETIME, DATEADD(MINUTE, DATEPART(TZOFFSET, TODATETIMEOFFSET(@DataHora2, '-03:30')), @DataHora2)) AS [-03:30],
    CONVERT(DATETIME, DATEADD(MINUTE, DATEPART(TZOFFSET, TODATETIMEOFFSET(@DataHora2, -90)), @DataHora2)) AS [-90 minutos],
    CONVERT(DATETIME, DATEADD(MINUTE, DATEPART(TZOFFSET, TODATETIMEOFFSET(@DataHora2, 90)), @DataHora2)) AS [+90 minutos]


