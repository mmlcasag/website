create table listas_de_noivas as
select numero_da_lista, nome_da_noiva, nome_do_noivo, data_casamento, voltagem, observacao
,      senha_internet, data_cadastramento, data_de_encerramento, status_da_lista, valor_bonus, codfil
,      codvendr, lipad_codigo, codfil_bonus, data_emissao_bonus, status_autorizacao_de_acesso
,      status_conferido, vlr_solicitado, vlr_comprado, vlr_comprado_loja, qtd_solicitada
,      qtd_comprada, mensagem, aviso_produto_comprado, cpf_noiva, cpf_noivo, cod_usuario_site
,      flg_modo_entrega, fl_enviado_responsys 
from   noivas.listas_de_noivas@lnkproducao
where  codfil = 400
and    trunc(data_cadastramento) >= '01/01/2015';

create index LINO_FIL_FK_I on LISTAS_DE_NOIVAS (CODFIL);
create index LINO_LIPAD_FK_I on LISTAS_DE_NOIVAS (LIPAD_CODIGO);
create index LINO_NOIVA on LISTAS_DE_NOIVAS (NOME_DA_NOIVA);
create index LINO_NOIVO on LISTAS_DE_NOIVAS (NOME_DO_NOIVO);
create index LINO_VEN_FK_I on LISTAS_DE_NOIVAS (CODFIL, CODVENDR);
create index LISTAS_DE_NOIVAS_IDX_DTAEM on LISTAS_DE_NOIVAS (DATA_EMISSAO_BONUS, NUMERO_DA_LISTA);
create index LISTAS_DE_NOIVAS_IDX_DTCADAST on LISTAS_DE_NOIVAS (DATA_CADASTRAMENTO);
create index LISTAS_DE_NOIVAS_IDX_DTCASAM on LISTAS_DE_NOIVAS (DATA_CASAMENTO);

alter table LISTAS_DE_NOIVAS add constraint LINO_PK primary key (NUMERO_DA_LISTA);

alter table LISTAS_DE_NOIVAS add constraint LINO_VOLTAGEM check (VOLTAGEM BETWEEN 220 AND 220 OR VOLTAGEM BETWEEN 110 AND 110);