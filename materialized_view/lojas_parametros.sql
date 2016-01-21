CREATE MATERIALIZED VIEW lojas_parametros
REFRESH FAST ON DEMAND
AS
SELECT id, cod_correio, cod_frota, cod_freteiro, min_frete, vlr_freteiro, vlr_frota, dist_max
,      dias_coleta, dias_adicionais_450, dias_adicionais_820, vlfrete_retira_loja, cod_esedex, opl_esedex
FROM   lvirtual.lojas_parametros;
