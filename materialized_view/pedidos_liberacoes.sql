CREATE MATERIALIZED VIEW pedidos_liberacoes
REFRESH FAST ON DEMAND
AS
SELECT pli_id, pls_id, ple_id, usl_id, pli_dt_cadastro, pli_dt_alteracao, pli_txt_observacao, pli_fla_cartaoonline
,      pli_enviar_clearsale, score_clearsale, transaction_id_clearsale, status_clearsale
FROM   lvirtual.pedidos_liberacoes;
