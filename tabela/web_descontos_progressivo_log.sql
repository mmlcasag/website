/*
create table web_descontos_progressivo_log (
  id number(10,0) not null,
  descricao varchar2(150) not null,
  data_inicio date not null,
  data_fim date not null,
  qtd_minima_produtos integer not null,
  qtd_maxima_produtos integer not null,
  codlinha integer not null,
  fl_ativo char(1) not null,
  info_itens varchar2(2500),
  data_log date not null,
  usuario varchar2(100),
  acao char(1) not null
);
*/

alter table WEB_DESCONTOS_PROGRESSIVO_LOG add constraint pk_WEB_DESC_PROG_LOG primary key (id, data_log);