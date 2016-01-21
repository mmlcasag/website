CREATE MATERIALIZED VIEW int_estoque_forne
REFRESH FAST ON DEMAND
AS
SELECT coditprod, qtd_estoque
FROM   colombo.int_estoque_forne;
