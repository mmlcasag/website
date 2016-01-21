DROP VIEW web_sugestao_venda_cruzamento;

CREATE MATERIALIZED VIEW web_sugestao_venda_cruzamento
REFRESH FAST ON DEMAND
AS
SELECT id, codprod1, codprod2, relevancia
FROM   lvirtual.web_sugestao_venda_cruzamento;
