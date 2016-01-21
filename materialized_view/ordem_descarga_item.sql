/*
CREATE MATERIALIZED VIEW ordem_descarga_item
REFRESH COMPLETE ON DEMAND
AS
SELECT ite.*
FROM   colombo.ordem_descarga      ord
JOIN   colombo.ordem_descarga_item ite on ite.ordem_descarga = ord.ordem_descarga
WHERE  ord.dt_descarga   >= trunc(sysdate)
AND    ord.status         = 0
AND    ite.qtdagendada    > 0
AND    ite.oc_cancelada  is null;
*/

alter table ORDEM_DESCARGA_ITEM add constraint pk_ordem_descarga_item primary key (ORDEM_DESCARGA, NUMPEDCOMP, CODITPROD);