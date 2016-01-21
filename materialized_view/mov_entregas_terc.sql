CREATE MATERIALIZED VIEW mov_entregas_terc
REFRESH FAST ON DEMAND
AS
SELECT numpedven, reg_expedicao, tipo, dt_criacao, usuario, tpinc, entregaok
FROM   colombo.mov_entregas_terc
