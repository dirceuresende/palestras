USE [eventos]
GO
/****** Object:  StoredProcedure [dbo].[stpInformacoes_Serie]    Script Date: 07/12/2019 02:34:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[stpInformacoes_Serie] (
    @Nome_Serie NVARCHAR(MAX)
)
AS BEGIN

    DECLARE 
        @Url NVARCHAR(MAX),
        @Retorno1 NVARCHAR(MAX),
        @Retorno2 NVARCHAR(MAX),
        @Retorno3 NVARCHAR(MAX)

    SET @Url = 'http://api.tvmaze.com/search/shows?q=' + @Nome_Serie

    -- Faz uma consulta ao webservice para consultar as informações da série
    DECLARE @Ds_Retorno_OUTPUT NVARCHAR(MAX);
    
	EXEC CLR.dbo.stpWs_Requisicao
        @Ds_Url = @Url, -- nvarchar(max)
        @Ds_Metodo = N'GET', -- nvarchar(max)
        @Ds_Parametros = N'', -- nvarchar(max)
        @Ds_Codificacao = N'UTF-8', -- nvarchar(max)
        @Ds_Accept = N'', -- nvarchar(max)
        @Ds_ContentType = N'', -- nvarchar(max)
        @Fl_Autentica_Proxy = NULL, -- bit
        @Ds_Headers = N'', -- nvarchar(max)
        @Qt_Segundos_Timeout = 30, -- int
        @Ds_Retorno_OUTPUT = @Retorno1 OUTPUT -- nvarchar(max)
     

    -- Remove os caracteres [] do começo e fim da string
    SET @Retorno1 = SUBSTRING(@Retorno1, 2, LEN(@Retorno1) - 2)

    -- Recupera o ID da série
    DECLARE @Id_Serie INT = CAST(JSON_VALUE(@Retorno1,'$.show.id') AS INT)
    DECLARE @Serie NVARCHAR(100) = JSON_VALUE(@Retorno1,'$.show.name')

    -- Recupera informações do episódio anterior
    SET @Url = 'http://api.tvmaze.com/shows/' + CAST(@Id_Serie AS VARCHAR(5)) + '?embed=previousepisode'

    EXEC CLR.dbo.stpWs_Requisicao 
        @Ds_Url = @Url, -- nvarchar(max)
        @Ds_Metodo = N'GET', -- nvarchar(max)
        @Ds_Parametros = N'', -- nvarchar(max)
        @Ds_Codificacao = N'UTF-8', -- nvarchar(max)
        @Ds_Accept = N'', -- nvarchar(max)
        @Ds_ContentType = N'', -- nvarchar(max)
        @Fl_Autentica_Proxy = NULL, -- bit
        @Ds_Headers = N'', -- nvarchar(max)
        @Qt_Segundos_Timeout = 30, -- int
		@Ds_Retorno_OUTPUT = @Retorno2 OUTPUT -- nvarchar(max)


    -- Recupera informações do próximo episódio
    SET @Url = 'http://api.tvmaze.com/shows/' + CAST(@Id_Serie AS VARCHAR(5)) + '?embed=nextepisode'

    EXEC CLR.dbo.stpWs_Requisicao 
        @Ds_Url = @Url, -- nvarchar(max)
        @Ds_Metodo = N'GET', -- nvarchar(max)
        @Ds_Parametros = N'', -- nvarchar(max)
        @Ds_Codificacao = N'UTF-8', -- nvarchar(max)
        @Ds_Accept = N'', -- nvarchar(max)
        @Ds_ContentType = N'', -- nvarchar(max)
        @Fl_Autentica_Proxy = NULL, -- bit
        @Ds_Headers = N'', -- nvarchar(max)
        @Qt_Segundos_Timeout = 30, -- int
        @Ds_Retorno_OUTPUT = @Retorno3 OUTPUT -- nvarchar(max)


    -- Extrai as informações dos episódios com JSON_VALUE e guarda numa tabela
    IF (OBJECT_ID('tempdb..#Episodios') IS NOT NULL) DROP TABLE #Episodios
    CREATE TABLE #Episodios (
        Ds_Serie NVARCHAR(100),
        Ds_Tipo VARCHAR(50),
        Nr_Temporada INT,
        Ds_Episodio NVARCHAR(100),
        Nr_Episodio INT,
        Dt_Episodio DATE,
        Hr_Episodio NVARCHAR(5)
    )

    INSERT INTO #Episodios
    SELECT  
        @Serie AS Ds_Serie ,
        'Anterior' AS Ds_Tipo,
        JSON_VALUE(@Retorno2, '$._embedded.previousepisode.season') AS Nr_Temporada,
        JSON_VALUE(@Retorno2, '$._embedded.previousepisode.name') AS Ds_Episodio,
        JSON_VALUE(@Retorno2, '$._embedded.previousepisode.number') AS Nr_Episodio,
        JSON_VALUE(@Retorno2, '$._embedded.previousepisode.airdate') AS Dt_Episodio,
        JSON_VALUE(@Retorno2, '$._embedded.previousepisode.airtime') AS Hr_Episodio

    UNION ALL

    SELECT  
        @Serie AS Ds_Serie,
        'Próximo' AS Ds_Tipo,
        ISNULL(JSON_VALUE(@Retorno3, '$._embedded.nextepisode.season'), '') AS Nr_Temporada,
        ISNULL(JSON_VALUE(@Retorno3, '$._embedded.nextepisode.name'), '') AS Ds_Episodio,
        ISNULL(JSON_VALUE(@Retorno3, '$._embedded.nextepisode.number'), '') AS Nr_Episodio,
        ISNULL(JSON_VALUE(@Retorno3, '$._embedded.nextepisode.airdate'), '') AS Dt_Episodio,
        ISNULL(JSON_VALUE(@Retorno3, '$._embedded.nextepisode.airtime'), '') AS Hr_Episodio


    SELECT * FROM #Episodios


END

