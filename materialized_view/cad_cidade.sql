CREATE MATERIALIZED VIEW cad_cidade
REFRESH FAST ON DEMAND
AS
SELECT uf, local, cep, tipo, codlocal, codlocal_pai, vlr_min_frete_vda
,      col_mercurio_taxa, col_itapemirim_tipo, col_itapemirim_aereo, col_itapemirim_fluvial, col_itapemirim_pedagio
,      area_risco, praca_licitacao, flg_entrega_expressa
FROM   colombo.cad_cidade;
