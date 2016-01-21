CREATE MATERIALIZED VIEW promocoes_frete
REFRESH FAST ON DEMAND
AS
SELECT codpromocao, codlinha, codfamilia, codgrupo, codproduto, vlminimo, perccliente, estado, dtini, dtfim, dtcriacao
,      usuario, observacao, vlmaximo, vlfixo, tpcidade
FROM   apcol.promocoes_frete;
