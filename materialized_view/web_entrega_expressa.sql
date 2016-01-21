CREATE MATERIALIZED VIEW web_entrega_expressa
REFRESH FAST ON DEMAND
AS
SELECT id, codtransp, uf, cepini, cepfim
FROM   lvirtual.web_entrega_expressa;
