CREATE MATERIALIZED VIEW cad_pracacep
REFRESH FAST ON DEMAND
AS
SELECT cepinic, cepfim, praca
FROM   colombo.cad_pracacep
