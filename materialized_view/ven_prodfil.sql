CREATE MATERIALIZED VIEW ven_prodfil
REFRESH FAST ON DEMAND
AS
SELECT codfil, codprod, cue, cuei, cmup, indcue, indmedger, indcustger, tpcusto
FROM   colombo.ven_prodfil
WHERE  codfil in (400,835)
