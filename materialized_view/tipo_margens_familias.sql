CREATE MATERIALIZED VIEW tipo_margens_familias
REFRESH FAST ON DEMAND
AS
SELECT codigo, sequencia, codlinha, codfam, dat_criacao, dat_alteracao, tax_margem_menor, tax_margem_maior, tax_margem_max
,      perc_desconto, preco_minimo, desc_min_novo, desc_inter_novo, desc_max_vendedor, lim_min_novo, lim_inter_novo
FROM   colombo.tipo_margens_familias;
