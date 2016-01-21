CREATE MATERIALIZED VIEW roteiro_carga
REFRESH FAST ON DEMAND
AS
SELECT dep, roteiro, descricao_rot, status, km_percurso, entrega, pont_sep_elet, tipo, retorna_no_dia, qtde_ajudantes
FROM   colombo.roteiro_carga;
