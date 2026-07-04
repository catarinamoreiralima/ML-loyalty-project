WITH tb_transacao AS (
    SELECT *,
        date(substr(DtCriacao, 1, 10)) as dtDia
    FROM transacoes
    
    WHERE DtCriacao < '2025-10-01'
),

tb_agg_transacao AS (

    SELECT 
        IdCliente,
        COUNT(DISTINCT dtDia) as qntAtivacaoVida,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-7 day') THEN dtDia END) AS qntAtivacaoD7,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-14 day') THEN dtDia END) AS qntAtivacaoD14,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-28 day') THEN dtDia END) AS qntAtivacaoD28,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-56 day') THEN dtDia END) AS qntAtivacaoD56,

        COUNT(DISTINCT IdTransacao) as qntTransacaoVida,
        COUNT(DISTINCT CASE WHEN IdTransacao >= date('2025-10-01', '-7 day') THEN IdTransacao END) AS qntTransacaoD7,
        COUNT(DISTINCT CASE WHEN IdTransacao >= date('2025-10-01', '-14 day') THEN IdTransacao END) AS qntTransacaoD14,
        COUNT(DISTINCT CASE WHEN IdTransacao >= date('2025-10-01', '-28 day') THEN IdTransacao END) AS qntTransacaoD28,
        COUNT(DISTINCT CASE WHEN IdTransacao >= date('2025-10-01', '-56 day') THEN IdTransacao END) AS qntTransacaoD56,

        SUM(qtdePontos) as qntPontosVida,
        SUM(CASE WHEN dtDia >= date('2025-10-01', '-7 day') THEN qtdePontos ELSE 0 END) AS qntPontosD7,
        SUM(CASE WHEN dtDia >= date('2025-10-01', '-14 day') THEN qtdePontos ELSE 0 END) AS qntPontosD14,
        SUM(CASE WHEN dtDia >= date('2025-10-01', '-28 day') THEN qtdePontos ELSE 0 END) AS qntPontosD28,
        SUM(CASE WHEN dtDia >= date('2025-10-01', '-56 day') THEN qtdePontos ELSE 0 END) AS qntPontosD56,

        SUM(CASE WHEN qtdePontos > 0 THEN qtdePontos ELSE 0 END) as qntPontosPosVida,
        SUM(CASE WHEN (dtDia >= date('2025-10-01', '-7 day') AND qtdePontos > 0) THEN qtdePontos ELSE 0 END) AS qntPontosPosD7,
        SUM(CASE WHEN (dtDia >= date('2025-10-01', '-14 day') AND qtdePontos > 0) THEN qtdePontos ELSE 0 END) AS qntPontosPosD14,
        SUM(CASE WHEN (dtDia >= date('2025-10-01', '-28 day') AND qtdePontos > 0) THEN qtdePontos ELSE 0 END) AS qntPontosPosD28,
        SUM(CASE WHEN (dtDia >= date('2025-10-01', '-56 day') AND qtdePontos > 0) THEN qtdePontos ELSE 0 END) AS qntPontosPosD56,

        SUM(CASE WHEN qtdePontos < 0 THEN qtdePontos ELSE 0 END) as qntPontosNegVida,
        SUM(CASE WHEN (dtDia >= date('2025-10-01', '-7 day') AND qtdePontos < 0) THEN qtdePontos ELSE 0 END) AS qntPontosNegD7,
        SUM(CASE WHEN (dtDia >= date('2025-10-01', '-14 day') AND qtdePontos < 0) THEN qtdePontos ELSE 0 END) AS qntPontosNegD14,
        SUM(CASE WHEN (dtDia >= date('2025-10-01', '-28 day') AND qtdePontos < 0) THEN qtdePontos ELSE 0 END) AS qntPontosNegD28,
        SUM(CASE WHEN (dtDia >= date('2025-10-01', '-56 day') AND qtdePontos < 0) THEN qtdePontos ELSE 0 END) AS qntPontosNegD56

    FROM tb_transacao
    GROUP BY IdCliente


),

tb_agg_calculado AS (

    SELECT 
        *,
        COALESCE(1. * qntTransacaoVida / qntAtivacaoVida, 0) as qntTransacaoDiaVida,
        COALESCE(1. * qntTransacaoD7 / qntAtivacaoD7, 0) as qntTransacaoDiaD7,
        COALESCE(1. * qntTransacaoD14 / qntAtivacaoD14, 0) as qntTransacaoDiaD14,
        COALESCE(1. * qntTransacaoD28 / qntAtivacaoD28, 0) as qntTransacaoDiaD28,
        COALESCE(1. * qntTransacaoD56 / qntAtivacaoD56, 0) as qntTransacaoDiaD56,

        COALESCE(1. * qntAtivacaoD28 / 28, 0) AS pctAtivacaoMAU

    FROM tb_agg_transacao),

tb_horas_dia AS (

    SELECT 

        IdCliente,
        dtDia,
        24  * (max(julianday(DtCriacao)) - min(julianday(DtCriacao))) AS duracao


    FROM tb_transacao
    GROUP BY IdCliente, dtDia 
),

tb_hora_cliente AS (

    SELECT 
        IdCliente,
        SUM(duracao) as qntHorasVida,
        SUM(CASE WHEN dtDia >= date('2025-10-01', '-7 day') THEN duracao ELSE 0 END) AS qntHorasD7,
        SUM(CASE WHEN dtDia >= date('2025-10-01', '-14 day') THEN duracao ELSE 0 END) AS qntHorasD14,
        SUM(CASE WHEN dtDia >= date('2025-10-01', '-28 day') THEN duracao ELSE 0 END) AS qntHorasD28,
        SUM(CASE WHEN dtDia >= date('2025-10-01', '-56 day') THEN duracao ELSE 0 END) AS qntHorasD56

    FROM tb_horas_dia 
    GROUP BY IdCliente
),

tb_lag_dia AS (

    SELECT 
        IdCliente,
        dtDia,
        LAG(dtDia) OVER (PARTITION BY IdCliente ORDER BY dtDia) AS lagDia 

    FROM tb_horas_dia
),

tb_intervalo_dias AS (

SELECT IdCliente, 
    AVG(julianday(dtDia) - julianday(lagDia)) AS avgDiffDayVida,
    AVG(CASE WHEN (dtDia > date('2025-10-01', '-28 day ')) THEN julianday(dtDia) - julianday(lagDia) END) AS avgDiffDayD28

FROM tb_lag_dia
GROUP BY IdCliente
)

SELECT t1.*,
    t2.qntHorasVida,
    t2.qntHorasD7,
    t2.qntHorasD14,
    t2.qntHorasD28,
    t2.qntHorasD56,
    t3.avgDiffDayVida,
    t3.avgDiffDayD28 


FROM tb_agg_calculado t1
LEFT JOIN tb_hora_cliente t2
ON t1.IdCliente = t2.IdCliente
LEFT JOIN tb_intervalo_dias t3
ON t1.IdCliente = t3.IdCliente