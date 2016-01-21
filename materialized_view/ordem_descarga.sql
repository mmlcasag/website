/*
CREATE MATERIALIZED VIEW ordem_descarga
REFRESH COMPLETE ON DEMAND
AS
SELECT DISTINCT ord.*
FROM   colombo.ordem_descarga      ord
JOIN   colombo.ordem_descarga_item ite on ite.ordem_descarga = ord.ordem_descarga
WHERE  ord.dt_descarga   >= trunc(sysdate)
AND    ord.status         = 0
AND    ite.qtdagendada    > 0
AND    ite.oc_cancelada  is null;
*/

alter table ORDEM_DESCARGA add constraint pk_ordem_descarga primary key (ORDEM_DESCARGA);