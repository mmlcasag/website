/*
alter table WEB_RELATORIO_HORA drop constraint FK_RELATORIO_HORA_COFIL;
alter table WEB_PROD_PRECO     drop constraint FK_WEB_PROD_PRECO_CODFIL;

drop table cad_filial;
*/

DROP MATERIALIZED VIEW cad_filial;

CREATE MATERIALIZED VIEW cad_filial
REFRESH FAST ON DEMAND
AS
SELECT codfil, fantasia, col_fantasia, col_tpfil, cgccpf, inscricao, codfilant, codregiao, praca, praca_retira, status, ddd, fone
,      endereco, numero, complemento, bairro, cidade, estado, cep, col_codcidade, col_veic_entrega, col_freteiro, flg_entrega_expressa, col_nvlpreco
,      codfildist, col_codfilprim, col_codfilsec, col_codfilterc, utiliza_estq_cd_sec, utiliza_estq_cd_terc, dtproc, nrdiasproposta, codfilcust
,      fl_retira_site, fl_retira_tele -- NOVAS COLUNAS
FROM   colombo.cad_filial
WHERE  NVL(status,0)    <> 9
AND    NVL(codregiao,0) <> 99
ORDER  BY codfil;
