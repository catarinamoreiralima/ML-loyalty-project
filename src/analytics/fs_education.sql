WITH tb_usuario_curso AS (

    SELECT 
        IdUsuario,
        descSlugCurso,
        count(descSlugCursoEpisodio) as qtdeEps


    FROM cursos_episodios_completos
    WHERE dtCriacao <= '2025-10-01'
    GROUP BY IdUsuario, descSlugCurso

), 
tb_cursos_total_eps AS (

    SELECT 
        descSlugCurso,
        COUNT(descEpisodio) as qtdeTotalEps

    FROM cursos_episodios
    GROUP BY descSlugCurso

),

tb_pct_curso AS (
 
    SELECT 
        t1.IdUsuario,
        t1.descSlugCurso,
        1. * t1.qtdeEps / t2.qtdeTotalEps as pctEpsCurso

    FROM tb_usuario_curso t1
    LEFT JOIN tb_cursos_total_eps t2
        ON t1.descSlugCurso = t2.descSlugCurso

),
tb_pct_curso_pivot AS (

    SELECT 
    idUsuario,

    SUM(CASE WHEN pctEpsCurso = 1 THEN 1 ELSE 0 END) AS cursosCompletos,
    SUM(CASE WHEN pctEpsCurso >0 AND pctEpsCurso < 1 THEN 1 ELSE 0 END) AS cursosIncompletos,



    SUM(CASE WHEN descSlugCurso = 'carreira' THEN pctEpsCurso ELSE 0 END) AS carreira,
    SUM(CASE WHEN descSlugCurso = 'coleta-dados-2024' THEN pctEpsCurso ELSE 0 END) AS coletaDados2024,
    SUM(CASE WHEN descSlugCurso = 'ds-databricks-2024' THEN pctEpsCurso ELSE 0 END) AS dsDatabricks2024,
    SUM(CASE WHEN descSlugCurso = 'ds-pontos-2024' THEN pctEpsCurso ELSE 0 END) AS dsPontos2024,
    SUM(CASE WHEN descSlugCurso = 'estatistica-2024' THEN pctEpsCurso ELSE 0 END) AS estatistica2024,
    SUM(CASE WHEN descSlugCurso = 'estatistica-2025' THEN pctEpsCurso ELSE 0 END) AS estatistica2025,
    SUM(CASE WHEN descSlugCurso = 'f1-lake' THEN pctEpsCurso ELSE 0 END) AS f1Lake,
    SUM(CASE WHEN descSlugCurso = 'github-2024' THEN pctEpsCurso ELSE 0 END) AS github2024,
    SUM(CASE WHEN descSlugCurso = 'github-2025' THEN pctEpsCurso ELSE 0 END) AS github2025,
    SUM(CASE WHEN descSlugCurso = 'go-2026' THEN pctEpsCurso ELSE 0 END) AS go2026,
    SUM(CASE WHEN descSlugCurso = 'ia-canal-2025' THEN pctEpsCurso ELSE 0 END) AS iaCanal2025,
    SUM(CASE WHEN descSlugCurso = 'lago-mago-2024' THEN pctEpsCurso ELSE 0 END) AS lagoMago2024,
    SUM(CASE WHEN descSlugCurso = 'loyalty-predict-2025' THEN pctEpsCurso ELSE 0 END) AS loyaltyPredict2025,
    SUM(CASE WHEN descSlugCurso = 'machine-learning-2025' THEN pctEpsCurso ELSE 0 END) AS machineLearning2025,
    SUM(CASE WHEN descSlugCurso = 'matchmaking-trampar-de-casa-2024' THEN pctEpsCurso ELSE 0 END) AS matchmakingTramparDeCasa2024,
    SUM(CASE WHEN descSlugCurso = 'ml-2024' THEN pctEpsCurso ELSE 0 END) AS ml2024,
    SUM(CASE WHEN descSlugCurso = 'mlflow-2025' THEN pctEpsCurso ELSE 0 END) AS mlflow2025,
    SUM(CASE WHEN descSlugCurso = 'nekt-2025' THEN pctEpsCurso ELSE 0 END) AS nekt2025,
    SUM(CASE WHEN descSlugCurso = 'pandas-2024' THEN pctEpsCurso ELSE 0 END) AS pandas2024,
    SUM(CASE WHEN descSlugCurso = 'pandas-2025' THEN pctEpsCurso ELSE 0 END) AS pandas2025,
    SUM(CASE WHEN descSlugCurso = 'plataforma-ml-2026' THEN pctEpsCurso ELSE 0 END) AS plataformaMl2026,
    SUM(CASE WHEN descSlugCurso = 'python-2024' THEN pctEpsCurso ELSE 0 END) AS python2024,
    SUM(CASE WHEN descSlugCurso = 'python-2025' THEN pctEpsCurso ELSE 0 END) AS python2025,
    SUM(CASE WHEN descSlugCurso = 'ragia' THEN pctEpsCurso ELSE 0 END) AS ragia,
    SUM(CASE WHEN descSlugCurso = 'speed-f1' THEN pctEpsCurso ELSE 0 END) AS speedF1,
    SUM(CASE WHEN descSlugCurso = 'sql-2020' THEN pctEpsCurso ELSE 0 END) AS sql2020,
    SUM(CASE WHEN descSlugCurso = 'sql-2025' THEN pctEpsCurso ELSE 0 END) AS sql2025,
    SUM(CASE WHEN descSlugCurso = 'streamlit-2025' THEN pctEpsCurso ELSE 0 END) AS streamlit2025,
    SUM(CASE WHEN descSlugCurso = 'trampar-lakehouse-2024' THEN pctEpsCurso ELSE 0 END) AS tramparLakehouse2024,
    SUM(CASE WHEN descSlugCurso = 'tse-analytics-2024 ' THEN pctEpsCurso ELSE 0 END) AS tseAnalytics2024
 
FROM tb_pct_curso
GROUP BY idUsuario

),

tb_atividades AS (

SELECT 
    idUsuario,
    MAX(dtRecompensa) AS dtCriacao

FROM recompensas_usuarios
WHERE dtRecompensa <= '2025-10-01' 
GROUP BY idUsuario

UNION ALL

SELECT 
    idUsuario,
    MAX(dtCriacao) AS dtCriacao

FROM cursos_episodios_completos
WHERE dtCriacao <= '2025-10-01' 
GROUP BY idUsuario

UNION ALL

SELECT 
    idUsuario,
    max(dtCriacao) AS dtCriacao

FROM habilidades_usuarios
WHERE dtCriacao <= '2025-10-01' 
GROUP BY idUsuario

),

tb_ultima_atividade AS (

SELECT 
    idUsuario,
    MIN(julianday('2025-10-01') - julianday(dtCriacao)) as qntDiasUltimaAtv


FROM tb_atividades
GROUP BY idUsuario

),
tb_join AS (

    SELECT
        t3.idTMWCliente AS idCliente,
        t1.cursosCompletos,
        t1.cursosIncompletos,
        t1.carreira,
        t1.coletaDados2024,
        t1.dsDatabricks2024,
        t1.dsPontos2024,
        t1.estatistica2024,
        t1.estatistica2025,
        t1.f1Lake,
        t1.github2024,
        t1.github2025,
        t1.go2026,
        t1.iaCanal2025,
        t1.lagoMago2024,
        t1.loyaltyPredict2025,
        t1.machineLearning2025,
        t1.matchmakingTramparDeCasa2024,
        t1.ml2024,
        t1.mlflow2025,
        t1.nekt2025,
        t1.pandas2024,
        t1.pandas2025,
        t1.plataformaMl2026,
        t1.python2024,
        t1.python2025,
        t1.ragia,
        t1.speedF1,
        t1.sql2020,
        t1.sql2025,
        t1.streamlit2025,
        t1.tramparLakehouse2024,
        t1.tseAnalytics2024,
        t2.qntDiasUltimaAtv

    FROM tb_pct_curso_pivot t1

    LEFT JOIN tb_ultima_atividade t2 
    ON t1.idUsuario = t2.idUsuario

    INNER JOIN  usuarios_tmw t3
    ON t1.idUsuario = t3.idUsuario

)

SELECT * FROM tb_join


