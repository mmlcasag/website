CREATE MATERIALIZED VIEW web_prom_lojas
REFRESH FAST ON DEMAND
AS
SELECT codfil, seq_promocao, ano, cidade, estado, codregiao
FROM   colombo.web_prom_lojas;