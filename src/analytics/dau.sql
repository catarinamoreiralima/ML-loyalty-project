SELECT  substr(DtCriacao, 1, 10) AS DtDia, 
        COUNT (DISTINCT IdCliente) AS DAU
FROM transacoes
GROUP BY DtDia;