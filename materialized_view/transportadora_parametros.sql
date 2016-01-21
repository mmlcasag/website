CREATE MATERIALIZED VIEW transportadora_parametros
REFRESH FAST ON DEMAND
AS
SELECT id, vlfrete_comloja, vlfrete_semloja, percentual_lucro
FROM   lvirtual.transportadora_parametros;
