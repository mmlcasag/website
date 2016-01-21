CREATE MATERIALIZED VIEW produto
REFRESH FAST ON DEMAND
AS
SELECT id_produto, codprod, fornecedor, codigo_no_fornecedor, descricao, detalhes, ean, linkp, linkm, linkg
,      largura, comprimento, altura, peso, preco, preco_custo, flg_atualizado, codigo_ncm, orientacoes_gerais
,      data_alteracao, categoria, cst, fl_disponivel, tipo_produto, fl_liberado_cadastro
FROM   sitefornecedor.produto;
