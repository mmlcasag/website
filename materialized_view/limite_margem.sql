CREATE MATERIALIZED VIEW limite_margem
REFRESH FAST ON DEMAND
AS
SELECT codfam, codgrupo, coditprod, codsitprod, codforne, lim_menor, lim_maior, lim_max, seq_limite_margem, codproddf
,      dat_criacao, dat_alteracao, codlinha, codregional, codregiao, estados, filiais, perc_desconto, preco_minimo
,      desc_max_vendedor, usuario, sequencia, desc_inter_novo, desc_min_novo, lim_inter_novo, lim_min_novo
FROM   colombo.limite_margem;
