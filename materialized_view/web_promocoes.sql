CREATE MATERIALIZED VIEW web_promocoes
REFRESH FAST ON DEMAND
AS
SELECT seq_promocao, ano, cod_promocao, tipo, descricao, dat_inicial, dat_final, flg_item, flg_plano
,      per_desconto, flg_preco_lista, codlinha, codfam, codgrupo, codforne, codsitprod, flg_score
,      dsc_destino, texto, dat_criacao, dat_alteracao, dat_transmissao, usuario, status, dat_cancelamento
,      flg_calcula_taxa, flg_conceito_ate, flg_base, flg_celular, flg_merc_flexivel, flg_bonif_parcela
,      vlr_bonif_parcela, flg_cartao_colombo, obs, tipo_garantia, tipo_saida, plano_automatico
FROM   colombo.web_promocoes;
