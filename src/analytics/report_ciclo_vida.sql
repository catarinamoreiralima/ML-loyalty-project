SELECT dtRef,
    lifecycle,
    cluster,
    count(*) as qntClientes

FROM lifecycle
WHERE lifecycle <> '05 - ZUMBI'

GROUP BY dtRef, lifecycle, cluster
ORDER BY dtRef, lifecycle, cluster