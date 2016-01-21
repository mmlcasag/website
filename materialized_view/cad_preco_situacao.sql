CREATE MATERIALIZED VIEW cad_preco_situacao
REFRESH FAST ON DEMAND
AS
SELECT coditprod, codsitprod, preco, preco_rs, preco_sc, preco_pr, preco_sp, preco_mg, dtultalt
FROM   colombo.cad_preco_situacao;
