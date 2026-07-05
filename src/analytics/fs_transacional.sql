WITH tb_transacao AS (
    SELECT *,
        date(substr(DtCriacao, 1, 10)) as dtDia,
        CAST(substr(DtCriacao, 12, 2) AS INT) as dtHora

    FROM transacoes
    
    WHERE DtCriacao < '{date}'
),

tb_agg_transacao AS (

    SELECT 
        IdCliente,

        MAX(julianday(date('{date}', '-1 day')) - julianday(DtCriacao)) AS idadeDias,

        COUNT(DISTINCT dtDia) as qntAtivacaoVida,
        COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-7 day') THEN dtDia END) AS qntAtivacaoD7,
        COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-14 day') THEN dtDia END) AS qntAtivacaoD14,
        COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-28 day') THEN dtDia END) AS qntAtivacaoD28,
        COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-56 day') THEN dtDia END) AS qntAtivacaoD56,

        COUNT(DISTINCT IdTransacao) as qntTransacaoVida,
        COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-7 day') THEN IdTransacao END) AS qntTransacaoD7,
        COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-14 day') THEN IdTransacao END) AS qntTransacaoD14,
        COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-28 day') THEN IdTransacao END) AS qntTransacaoD28,
        COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-56 day') THEN IdTransacao END) AS qntTransacaoD56,

        SUM(qtdePontos) as qntPontosVida,
        SUM(CASE WHEN dtDia >= date('{date}', '-7 day') THEN qtdePontos ELSE 0 END) AS qntPontosD7,
        SUM(CASE WHEN dtDia >= date('{date}', '-14 day') THEN qtdePontos ELSE 0 END) AS qntPontosD14,
        SUM(CASE WHEN dtDia >= date('{date}', '-28 day') THEN qtdePontos ELSE 0 END) AS qntPontosD28,
        SUM(CASE WHEN dtDia >= date('{date}', '-56 day') THEN qtdePontos ELSE 0 END) AS qntPontosD56,

        SUM(CASE WHEN qtdePontos > 0 THEN qtdePontos ELSE 0 END) as qntPontosPosVida,
        SUM(CASE WHEN (dtDia >= date('{date}', '-7 day') AND qtdePontos > 0) THEN qtdePontos ELSE 0 END) AS qntPontosPosD7,
        SUM(CASE WHEN (dtDia >= date('{date}', '-14 day') AND qtdePontos > 0) THEN qtdePontos ELSE 0 END) AS qntPontosPosD14,
        SUM(CASE WHEN (dtDia >= date('{date}', '-28 day') AND qtdePontos > 0) THEN qtdePontos ELSE 0 END) AS qntPontosPosD28,
        SUM(CASE WHEN (dtDia >= date('{date}', '-56 day') AND qtdePontos > 0) THEN qtdePontos ELSE 0 END) AS qntPontosPosD56,

        SUM(CASE WHEN qtdePontos < 0 THEN qtdePontos ELSE 0 END) as qntPontosNegVida,
        SUM(CASE WHEN (dtDia >= date('{date}', '-7 day') AND qtdePontos < 0) THEN qtdePontos ELSE 0 END) AS qntPontosNegD7,
        SUM(CASE WHEN (dtDia >= date('{date}', '-14 day') AND qtdePontos < 0) THEN qtdePontos ELSE 0 END) AS qntPontosNegD14,
        SUM(CASE WHEN (dtDia >= date('{date}', '-28 day') AND qtdePontos < 0) THEN qtdePontos ELSE 0 END) AS qntPontosNegD28,
        SUM(CASE WHEN (dtDia >= date('{date}', '-56 day') AND qtdePontos < 0) THEN qtdePontos ELSE 0 END) AS qntPontosNegD56,

        1. * COUNT(CASE WHEN dtHora BETWEEN 10 and 14 THEN IdTransacao END) / COUNT(IdTransacao) AS pctTransacaoManhaVida,
        1. * COUNT(CASE WHEN dtHora BETWEEN 15 and 21 THEN IdTransacao END) / COUNT(IdTransacao) AS pctTransacaoTardeVida,
        1. * COUNT(CASE WHEN dtHora > 21 OR dtHora < 10 THEN IdTransacao END) / COUNT(IdTransacao) AS pctTransacaoNoiteVida

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
        SUM(CASE WHEN dtDia >= date('{date}', '-7 day') THEN duracao ELSE 0 END) AS qntHorasD7,
        SUM(CASE WHEN dtDia >= date('{date}', '-14 day') THEN duracao ELSE 0 END) AS qntHorasD14,
        SUM(CASE WHEN dtDia >= date('{date}', '-28 day') THEN duracao ELSE 0 END) AS qntHorasD28,
        SUM(CASE WHEN dtDia >= date('{date}', '-56 day') THEN duracao ELSE 0 END) AS qntHorasD56

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
        AVG(CASE WHEN (dtDia > date('{date}', '-28 day ')) THEN julianday(dtDia) - julianday(lagDia) END) AS avgDiffDayD28

    FROM tb_lag_dia
    GROUP BY IdCliente
),

tb_share_procutos AS (
    SELECT --t1.*,
--     t2. IdProduto,
    IdCliente,
    1. *  COUNT(CASE WHEN DescNomeProduto = 'ChatMessage' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS pctChatMessage,
    1. * COUNT(CASE WHEN DescNomeProduto = 'Airflow Lover' THEN t1.IdTransacao END)  / COUNT(t1.IdTransacao) AS pctAirflowLover,
    1. * COUNT(CASE WHEN DescNomeProduto = 'R lover' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS pctRLover,
    1. * COUNT(CASE WHEN DescNomeProduto = 'Resgatar Ponei' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS pctResgatarPonei,
    1. * COUNT(CASE WHEN DescNomeProduto = 'Lista de presença' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS pctListaDePresenca,
    1. * COUNT(CASE WHEN DescNomeProduto = 'Presença Streak' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS pctPresencaStreak,
    1. * COUNT(CASE WHEN DescNomeProduto = 'Troca de Pontos StreamElements' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS pctTrocaStreamElements,
    1. * COUNT(CASE WHEN DescNomeProduto = 'Reembolso: Troca de Pontos StreamElements' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS pctReembolsoStreamElements, 
    1. * COUNT(CASE WHEN descCategoriaProduto = 'rpg' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS pctRpg,
    1. * COUNT(CASE WHEN descCategoriaProduto  = 'churn_model' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS pctChurnModel

    FROM tb_transacao t1

    LEFT JOIN transacao_produto t2
    ON t1.IdTransacao = t2.IdTransacao

    LEFT JOIN  produtos t3
    ON t2.IdProduto = t3.IdProduto

    GROUP BY IdCliente
),

tb_join AS (

SELECT t1.*,
    t2.qntHorasVida,
    t2.qntHorasD7,
    t2.qntHorasD14,
    t2.qntHorasD28,
    t2.qntHorasD56,
    t3.avgDiffDayVida,
    t3.avgDiffDayD28,
    t4.pctChatMessage,
    t4.pctAirflowLover,
    t4.pctRLover,
    t4.pctResgatarPonei,
    t4.pctListaDePresenca,
    t4.pctPresencaStreak,
    t4.pctTrocaStreamElements,
    t4.pctReembolsoStreamElements, 
    t4.pctRpg,
    t4.pctChurnModel



FROM tb_agg_calculado t1

LEFT JOIN tb_hora_cliente t2
ON t1.IdCliente = t2.IdCliente

LEFT JOIN tb_intervalo_dias t3
ON t1.IdCliente = t3.IdCliente

LEFT JOIN tb_share_procutos t4
ON t1.IdCliente = t4.IdCliente

)  


SELECT 
    date('{date}', '-1 day') as dtRef,
    *
     FROM tb_join

 