CREATE MATERIALIZED VIEW produto_composicao
REFRESH FAST ON DEMAND
AS
SELECT id_produto_composicao, id_produto, quantidade, data_alteracao, cod_prod_composicao, descricao
FROM   sitefornecedor.produto_composicao
