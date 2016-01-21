CREATE MATERIALIZED VIEW ven_vend
REFRESH FAST ON DEMAND
AS
SELECT codfil, codvendr, codvendant, tpvendr, codfunc, nome, dtcadas, dtdesli, status, natjur, cgccpf, sexo
FROM   colombo.ven_vend
WHERE  codfil = 400
AND    NVL(status,0) = 0;

