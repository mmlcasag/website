CREATE MATERIALIZED VIEW livro
REFRESH FAST ON DEMAND
AS
SELECT id_produto, isbn, autor, editora, edicao, numero_paginas, assuntos, flg_atualizado, situacao
FROM   sitefornecedor.livro;
