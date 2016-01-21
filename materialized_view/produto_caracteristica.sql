CREATE MATERIALIZED VIEW produto_caracteristica
REFRESH FAST ON DEMAND
AS
SELECT id_produto_caracteristica, id_produto, nome, descricao, data_alteracao
FROM   sitefornecedor.produto_caracteristica;
