WITH tb_life_cycle_atual AS (

    SELECT IdCliente,
        lifecycle as descLifeCycleAtual,
        frequencia
    FROM life_cycle
    WHERE dtRef = date('{date}', '-1 day')
),

tb_life_cycle_D28 AS (

SELECT IdCliente,
    lifecycle as descLifeCycleD28
FROM life_cycle
WHERE dtRef = date('{date}', '-29 day')
),


tb_share_ciclos AS (

SELECT idCliente,
1. * SUM(CASE WHEN lifecycle = '05 - ZUMBI' THEN   1 ELSE 0 END) / COUNT(*) AS pctZumbi,
1. * SUM(CASE WHEN lifecycle = '02 - FIEL' THEN   1 ELSE 0 END) / COUNT(*) AS pctFiel,
1. * SUM(CASE WHEN lifecycle = '03 - TURISTA' THEN   1 ELSE 0 END) / COUNT(*) AS pctTurista,
1. * SUM(CASE WHEN lifecycle = '02 - REBORN' THEN   1 ELSE 0 END) / COUNT(*) AS pctReborn,
1. * SUM(CASE WHEN lifecycle = '04 - DESENCANTADO' THEN   1 ELSE 0 END) / COUNT(*) AS pctDesencantado,
1. * SUM(CASE WHEN lifecycle = '01 - CURIOSO' THEN   1 ELSE 0 END) / COUNT(*) AS pctCurioso,
1. * SUM(CASE WHEN lifecycle = '02 - RECONQUISTADO' THEN   1 ELSE 0 END) / COUNT(*) AS pctReconquistado
FROM life_cycle
WHERE dtRef < date('{date}', '-1 day') 
GROUP BY idCliente 

),

tb_avg_ciclo AS (


SELECT 
    descLifeCycleAtual,
    AVG(frequencia) as avgFrequenciaGrupo

FROM tb_life_cycle_atual
GROUP BY descLifeCycleAtual
),

tb_join AS (

SELECT t1.*,
        t2.descLifeCycleD28,
        t3.pctZumbi,
        t3.pctFiel,
        t3.pctTurista,
        t3.pctReborn,
        t3.pctDesencantado,
        t3.pctCurioso,
        t3.pctReconquistado,
        t4.avgFrequenciaGrupo,
        1. * t1.frequencia / t4.avgFrequenciaGrupo as razaoFrequenciaGrupo 

FROM tb_life_cycle_atual as t1

LEFT JOIN tb_life_cycle_D28 as t2
ON t1.IdCliente = t2.IdCliente

LEFT JOIN tb_share_ciclos as t3
ON t1.IdCliente = t3.IdCliente

LEFT JOIN tb_avg_ciclo as t4
ON t1.descLifeCycleAtual = t4.descLifeCycleAtual

)

SELECT date('{date}', '-1 day') AS dtRef,
       *
FROM tb_join





 
