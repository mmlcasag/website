CREATE MATERIALIZED VIEW fretes_nao_entrega
REFRESH FAST ON DEMAND
AS
SELECT transportadora, uf, local, cep
FROM   lvirtual.fretes_nao_entrega;