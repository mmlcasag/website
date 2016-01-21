CREATE MATERIALIZED VIEW parametros_precos
REFRESH FAST ON DEMAND
AS
SELECT itpr_coditprod, estado, preco_reposicao
FROM   colombo.parametros_precos
