CREATE MATERIALIZED VIEW cad_familia
REFRESH FAST ON DEMAND
AS
SELECT codlinha, codfam, descricao, nvl(status,0) status, nvl(regra_cmv_margem,0) regra_cmv_margem
FROM   colombo.cad_familia
WHERE  NVL(status,0) <> 9
ORDER  BY codlinha, codfam
