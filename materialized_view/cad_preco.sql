CREATE MATERIALIZED VIEW cad_preco
REFRESH FAST ON DEMAND
AS
SELECT codfil, coditprod, codembal, preco, precoant, codsitprod, tsultalt, fl_integra_catalogo
FROM   colombo.cad_preco
WHERE  codfil in (400,835);
