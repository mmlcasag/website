CREATE MATERIALIZED VIEW web_prom_itens
REFRESH FAST ON DEMAND
AS
SELECT seq_promocao, seq_grupo, ano, coditprod, vlr_item, vlr_promocao, flg_score, qtd_meta_venda, qtd_estoque
,      vlr_marg_mercantil, seq_digita, qtd_limite, qtd_venda, qtd_devol, num_meses_garantia, seq_garantia
,      vlr_garantia, flg_logistica, vlr_entrada, vlr_parcela, taxa_am, taxa_aa, flg_atualiza, cod_bonificacao
,      id_promocao_item
FROM   colombo.web_prom_itens;
