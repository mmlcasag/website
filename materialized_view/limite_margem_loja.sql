CREATE MATERIALIZED VIEW limite_margem_loja
REFRESH FAST ON DEMAND
AS
SELECT *
FROM   colombo.limite_margem_loja
WHERE  codfil = 400;
