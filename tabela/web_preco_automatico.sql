-- Create table
create table WEB_PRECO_AUTOMATICO
(
  codigo              NUMBER(10) not null,
  descricao           VARCHAR2(60) not null,
  dt_inicio           DATE not null,
  dt_fim              DATE,
  tp_acao             VARCHAR2(1),
  campanha_preco      NUMBER(10),
  fl_ativo            VARCHAR2(1),
  dt_alteracao        DATE,
  produto             NUMBER(10),
  fornecedor          NUMBER(10),
  linha               NUMBER(10),
  familia             NUMBER(10),
  grupo               NUMBER(10),
  qnt_compra_max_prod NUMBER(10),
  qnt_venda_max_prod  NUMBER(10)
) ;
