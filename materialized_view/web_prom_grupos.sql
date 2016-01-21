CREATE MATERIALIZED VIEW web_prom_grupos
REFRESH FAST ON DEMAND
AS
SELECT seq_promocao, seq_grupo, ano, dsc_grupo, id_promocao_grupo
FROM   colombo.web_prom_grupos;
