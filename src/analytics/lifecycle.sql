/* curiosa -> idade < 7
 
fiel -> recencia < 7 penultima recencia < 15
 
turista  -> recencia <= 14
 
desencantado -> 14 < recencia <= 28
 
zumbi -> recencia > 28

reconquistado -> recencia < 7 e    14 <= penultima recencia <= 28

reconquistado -> recencia < 7 e     penultima recencia > 28
 */

WITH tb_daily AS ( -- seleciona clientes e datas unicas de transacoes

    SELECT 
        DISTINCT 
            idCliente,
            substr(DtCriacao, 1, 10) as dtDia
    FROM transacoes
    WHERE DtCriacao < '{date}'
),

tb_idade AS ( -- idade e ultima transacao

    SELECT 
        idCliente,
        -- min(dtDia) as dtPrimTransacao,
        cast(max(julianday('{date}') - julianday(dtDia)) as int)  as qntDiasPrimTransacao,
        cast(min(julianday('{date}') - julianday(dtDia)) as int)  as qntDiasUltTransacao


    FROM tb_daily
    GROUP BY idCliente 
),

tb_rn AS ( -- enumera as transacoes por cliente, ordenando pela data da transacao desc (mais recente primeiro)

    SELECT *,
            row_number() OVER (PARTITION BY idCliente ORDER BY dtDia DESC) AS rn

    FROM tb_daily

),

tb_penultima_ativacao AS ( -- seleciona a penultima transacao de cada cliente 2 mais recente

    SELECT *,
    CAST(julianday('{date}') - julianday(dtDia) as int) as qntDiasPenultimaTransacao 
    FROM tb_rn
    WHERE rn = 2

),

tb_lifecycle AS ( -- calcula

    SELECT  i.*,
            p.qntDiasPenultimaTransacao,
            CASE 
                WHEN i.qntDiasPrimTransacao <= 7  THEN '01 - CURIOSO'
                WHEN i.qntDiasUltTransacao <= 7 AND p.qntDiasPenultimaTransacao - i.qntDiasUltTransacao <= 14 THEN '02 - FIEL'
                WHEN i.qntDiasUltTransacao BETWEEN 8 AND 14   THEN '03 - TURISTA'
                WHEN i.qntDiasUltTransacao BETWEEN 15 AND 28  THEN '04 - DESENCANTADO'
                WHEN i.qntDiasUltTransacao > 28 THEN '05 - ZUMBI'
                WHEN i.qntDiasUltTransacao <= 7 AND p.qntDiasPenultimaTransacao - i.qntDiasUltTransacao BETWEEN 15 AND 28 THEN '02 - RECONQUISTADO'
                WHEN i.qntDiasUltTransacao <= 7 AND p.qntDiasPenultimaTransacao - i.qntDiasUltTransacao > 28 THEN '02 - REBORN'

            END AS lifecycle 
    FROM tb_idade i
    LEFT  JOIN tb_penultima_ativacao p
        ON p.idCliente = i.idCliente

)

SELECT *,
    date('{date}', '-1 day') AS dtRef 
FROM tb_lifecycle;
