CREATE MATERIALIZED VIEW cad_itvolume
REFRESH FAST ON DEMAND
AS
SELECT coditprodprinc, coditprodvolume, col_dtcriacao
FROM   colombo.cad_itvolume;
