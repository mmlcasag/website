CREATE MATERIALIZED VIEW transportadora_uf
REFRESH FAST ON DEMAND
AS
SELECT uf, transportadora, ativo, frete_gratis
FROM   lvirtual.transportadora_uf;
