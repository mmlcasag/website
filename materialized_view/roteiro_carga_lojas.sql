CREATE MATERIALIZED VIEW roteiro_carga_lojas
REFRESH FAST ON DEMAND
AS
SELECT dep, roteiro, dia_carga, loja, praca, ordem_carregamento, hr_prev_saida, ordem_agrupamento, status
,      repos_estoque_autom, pont_sep_elet, nivel_repos_autom, corte_encom, codveic, nivel_corte_autom
,      loja_descarga, dia_descarga_loja, dias_adic_entrega
FROM   colombo.roteiro_carga_lojas;
