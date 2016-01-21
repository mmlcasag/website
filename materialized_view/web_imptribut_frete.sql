CREATE MATERIALIZED VIEW web_imptribut_frete
REFRESH FAST ON DEMAND
AS
SELECT sequencia, estorig, estdest, aliquota, vlrlimite, dtinicial, dtfinal, dtalteracao
FROM   apcol.web_imptribut_frete;
