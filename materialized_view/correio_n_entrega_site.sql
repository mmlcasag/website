CREATE MATERIALIZED VIEW correio_n_entrega_site
REFRESH FAST ON DEMAND
AS
SELECT transportadora, linha, familia, grupo, produto
FROM   lvirtual.correio_n_entrega_site;
