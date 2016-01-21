CREATE MATERIALIZED VIEW cad_prodloc
REFRESH FAST ON DEMAND
AS
SELECT codfil, tpdepos, coditprod, rua, bloco, apto, fisico, resfis, col_resvenda_lv
FROM   colombo.cad_prodloc
WHERE  codfil in (450,820)
