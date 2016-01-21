CREATE MATERIALIZED VIEW web_venda_horas
REFRESH FAST ON DEMAND
AS
SELECT CODFIL, DTNOTA, HORA, num_vendas
FROM   colombo.web_venda_horas
WHERE  codfil = 400
AND    dtnota >= to_date('01/01/2011','dd/mm/yyyy');
