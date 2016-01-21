CREATE MATERIALIZED VIEW preco_garantias
REFRESH FAST ON DEMAND
AS
SELECT seq_garantia, cod_garantia, tipo_garantia, faixa_inicial, faixa_final, vlr_garantia, vlr_apagar
FROM   colombo.preco_garantias
