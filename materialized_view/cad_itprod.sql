CREATE MATERIALIZED VIEW cad_itprod
REFRESH FAST ON DEMAND
AS
SELECT coditprod, digitprod, codlinha, codfam, codgrupo, codsubgp, codcapac
,      codprod, codforne, codcor, especific, codproddf, coditforn, status
,      tsultalt, col_web_flcatalogo, col_web_flsite
FROM   colombo.cad_itprod;
