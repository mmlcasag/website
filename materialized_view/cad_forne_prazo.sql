CREATE MATERIALIZED VIEW cad_forne_prazo
REFRESH FAST ON DEMAND
AS
SELECT coddef, codforne, codlinha, codfam, codgrupo
,      codprod, coditprod, dias, inclusao, usuario
FROM   lvirtual.cad_forne_prazo
ORDER  BY coddef;
