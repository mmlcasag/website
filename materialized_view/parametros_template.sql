drop synonym parametros_template;

CREATE MATERIALIZED VIEW parametros_template
REFRESH FAST ON DEMAND
AS
SELECT owner, nome, descricao, valor
FROM   admias.parametros_template;
