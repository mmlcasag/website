CREATE MATERIALIZED VIEW docsweb
REFRESH FAST ON DEMAND
AS
SELECT id, ident, nbanco, nagencia, numero, numpedven, codcli, status, obs, vlrparcela
,      nroparcela, dtvcto, codcta, vlrgarantia, ncodseg, nossonro, nomecartao, numdocs
FROM   lvirtual.docsweb
WHERE  dtvcto >= to_date('01/01/2011','dd/mm/yyyy');