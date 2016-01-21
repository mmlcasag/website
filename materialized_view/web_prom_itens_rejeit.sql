CREATE MATERIALIZED VIEW web_prom_itens_rejeit
REFRESH FAST ON DEMAND
AS
SELECT seq_promocao, seq_grupo, ano, coditprod, seq_digita, id_promocao_item
FROM   apcol.web_prom_itens_rejeit;
