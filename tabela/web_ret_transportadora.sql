CREATE TABLE web_ret_transportadora (
codigo number(4) not NULL,
descricao varchar2(255) not NULL,
desc_cliente varchar2(255),
fl_ativo varchar2(255) not NULL default 'N',
CONSTRAINT pk_web_ret_codigo PRIMARY KEY (codigo),
CONSTRAINT ck_web_ret_flag CHECK(fl_ativo in ('S','N')));