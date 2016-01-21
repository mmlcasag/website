CREATE MATERIALIZED VIEW cad_imptribut
REFRESH FAST ON DEMAND
AS
SELECT tpimp, codimp, estorig, estdest, codgrptpnota, aliquota, ctf
FROM   colombo.cad_imptribut;
