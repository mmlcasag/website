CREATE MATERIALIZED VIEW transportadora_restricoes
REFRESH FAST ON DEMAND
AS
SELECT transportadora, linha, familia, grupo, produto
FROM   lvirtual.transportadora_restricoes;
