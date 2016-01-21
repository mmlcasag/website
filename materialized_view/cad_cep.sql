CREATE MATERIALIZED VIEW cad_cep
REFRESH FAST ON DEMAND
AS
SELECT cep, logradouro, endereco, bairro, local, uf, praca, area_risco
FROM   colombo.cad_cep;
