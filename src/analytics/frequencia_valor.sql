
WITH tb_freq_valor AS (

    SELECT 
    IdCliente,
    COUNT(DISTINCT substr(DtCriacao, 0, 11)) as frequencia,
    SUM(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) as qntPontosPos 

    FROM transacoes

    WHERE DtCriacao < '2025-09-01'

    AND DtCriacao > date('2025-09-01', '-28 day')

    GROUP BY IdCliente
    ORDER BY frequencia DESC

),
tb_cluster AS (

    SELECT *,

    CASE 
        WHEN frequencia <= 10 AND qntPontosPos >= 1500 THEN '12 - Hypers'
        WHEN frequencia > 10 AND qntPontosPos >= 1500 THEN '22 - Eficientes'
        WHEN frequencia <= 10 AND qntPontosPos >= 750 THEN '11 - Indeciso'
        WHEN frequencia > 10 AND qntPontosPos >= 750 THEN '21 - Esforçados'
        WHEN frequencia < 5 THEN '00 - Lurkers'
        WHEN frequencia <= 10 THEN '01 - Preguiçosos'
        WHEN frequencia > 10 THEN '20 - Potencial'
    END AS cluster

    FROM tb_freq_valor
 
)

SELECT cluster,
    IdCliente,
    qntPontosPos,
    frequencia
FROM tb_cluster

