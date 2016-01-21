CREATE MATERIALIZED VIEW tipo_margens_lojas
REFRESH FAST ON DEMAND
AS
SELECT codigo, codfil, dat_alteracao
FROM   colombo.tipo_margens_lojas
WHERE  codfil = 400;
