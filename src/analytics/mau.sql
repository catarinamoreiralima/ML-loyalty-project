WITH tb_daily AS (

    SELECT  date(substr(DtCriacao, 0, 11)) AS DtDia, 
            IdCliente
    FROM transacoes
    ORDER BY DtDia
    ), 

tb_distinct_daily AS (
    SELECT DISTINCT DtDia as DtRef
    FROM tb_daily
    ORDER BY DtRef
    )

SELECT  t1.dtRef,
    COUNT(DISTINCT IdCliente) AS MAU

FROM tb_distinct_daily t1 

LEFT JOIN tb_daily t2
ON t2.DtDia <= t1.DtRef 
AND julianday(t1.DtRef) - julianday(t2.DtDia) < 28

GROUP BY t1.DtRef
ORDER BY t1.DtRef ASC



  
