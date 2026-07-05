
DROP TABLE IF EXISTS abt_fiel;
CREATE TABLE IF NOT EXISTS abt_fiel AS 

WITH tb_join AS (

SELECT 
    t1.dtRef,
    t1.IdCliente,
    t1.lifecycle as descLifeCycleAtual,
    t2.lifecycle as descLifeCycleD28,
    CASE WHEN t2.lifecycle = '02 - FIEL' THEN 1 ELSE 0 END AS flFiel,
    ROW_NUMBER() OVER (PARTITION BY t1.IdCliente ORDER BY random()) AS row_num


FROM life_cycle t1
LEFT JOIN life_cycle t2
    ON t1.IdCliente = t2.IdCliente
    AND  date(t1.dtRef, '+28 day') = date(t2.dtRef)

WHERE ((t1.dtRef >= '2024-03-01' AND t1.dtRef <= '2025-08-01') OR t1.dtRef = '2025-09-01')
AND t1.lifecycle <> '05 - ZUMBI'

), tb_cohort AS (

SELECT 
    t1.dtRef,
    t1.idCliente,
    t1.flFiel


FROM tb_join t1

WHERE row_num <= 2

ORDER BY IdCliente, dtRef

)

SELECT t1.*,
        t2.idadeDias,
        t2.qntAtivacaoVida,
        t2.qntAtivacaoD7,
        t2.qntAtivacaoD14,
        t2.qntAtivacaoD28,
        t2.qntAtivacaoD56,
        t2.qntTransacaoVida,
        t2.qntTransacaoD7,
        t2.qntTransacaoD14,
        t2.qntTransacaoD28,
        t2.qntTransacaoD56,
        t2.qntPontosVida,
        t2.qntPontosD7,
        t2.qntPontosD14,
        t2.qntPontosD28,
        t2.qntPontosD56,
        t2.qntPontosPosVida,
        t2.qntPontosPosD7,
        t2.qntPontosPosD14,
        t2.qntPontosPosD28,
        t2.qntPontosPosD56,
        t2.qntPontosNegVida,
        t2.qntPontosNegD7,
        t2.qntPontosNegD14,
        t2.qntPontosNegD28,
        t2.qntPontosNegD56,
        t2.pctTransacaoManhaVida,
        t2.pctTransacaoTardeVida,
        t2.pctTransacaoNoiteVida,
        t2.qntTransacaoDiaVida,
        t2.qntTransacaoDiaD7,
        t2.qntTransacaoDiaD14,
        t2.qntTransacaoDiaD28,
        t2.qntTransacaoDiaD56,
        t2.pctAtivacaoMAU,
        t2.qntHorasVida,
        t2.qntHorasD7,
        t2.qntHorasD14,
        t2.qntHorasD28,
        t2.qntHorasD56,
        t2.avgDiffDayVida,
        t2.avgDiffDayD28,
        t2.pctChatMessage,
        t2.pctAirflowLover,
        t2.pctRLover,
        t2.pctResgatarPonei,
        t2.pctListaDePresenca,
        t2.pctPresencaStreak,
        t2.pctTrocaStreamElements,
        t2.pctReembolsoStreamElements,
        t2.pctRpg,
        t2.pctChurnModel,
        t3.descLifeCycleAtual,
        t3.frequencia ,
        t3.descLifeCycleD28 ,
        t3.pctZumbi ,
        t3.pctFiel ,
        t3.pctTurista ,
        t3.pctReborn ,
        t3.pctDesencantado ,
        t3.pctCurioso ,
        t3.pctReconquistado ,
        t3.avgFrequenciaGrupo, 
        t3.razaoFrequenciaGrupo, 
        t4.cursosCompletos ,
        t4.cursosIncompletos ,
        t4.carreira ,
        t4.coletaDados2024,
        t4.dsDatabricks2024,
        t4.dsPontos2024,
        t4.estatistica2024 ,
        t4.estatistica2025 ,
        t4.f1Lake,
        t4.github2024 ,
        t4.github2025 ,
        t4.go2026 ,
        t4.iaCanal2025,
        t4.lagoMago2024,
        t4.loyaltyPredict2025,
        t4.machineLearning2025,
        t4.matchmakingTramparDeCasa2024,
        t4.ml2024 ,
        t4.mlflow2025 ,
        t4.nekt2025 ,
        t4.pandas2024 ,
        t4.pandas2025 ,
        t4.plataformaMl2026,
        t4.python2024 ,
        t4.python2025 ,
        t4.ragia ,
        t4.speedF1 ,
        t4.sql2020 ,
        t4.sql2025 ,
        t4.streamlit2025 ,
        t4.tramparLakehouse2024,
        t4.tseAnalytics2024 ,
        t4.qntDiasUltimaAtv

FROM tb_cohort t1

LEFT JOIN fs_transacional t2
    ON t1.IdCliente = t2.IdCliente
    AND date(t1.dtRef) = date(t2.dtRef)

LEFT JOIN fs_life_cycle t3
    ON t1.IdCliente = t3.IdCliente
    AND date(t1.dtRef) = date(t3.dtRef)

LEFT JOIN fs_education t4
    ON t1.IdCliente = t4.IdCliente
    AND date(t1.dtRef) = date(t4.dtRef)

WHERE t3.dtRef IS NOT NULL;
