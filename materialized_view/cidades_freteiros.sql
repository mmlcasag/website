CREATE MATERIALIZED VIEW cidades_freteiros
REFRESH FAST ON DEMAND
AS
SELECT codfil, cod_local, consiste_cep, km_ida_volta, consiste_km, preco_km, praca, status
FROM   apcol.cidades_freteiros;
