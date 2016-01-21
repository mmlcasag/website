CREATE MATERIALIZED VIEW ven_prodfil_cd_ax
REFRESH FAST ON DEMAND
AS
SELECT codfil, codprod, dtcusto, cmup
FROM   apcol.ven_prodfil_cd_ax
WHERE  codfil IN (450,820)
