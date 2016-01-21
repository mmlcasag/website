create table web_descontos_progressivo (
  id number(10,0) not null,
  descricao varchar2(150) not null,
  data_inicio date not null,
  data_fim date not null,
  qtd_minima_produtos integer not null,
  qtd_maxima_produtos integer not null,
  codlinha integer not null,
  fl_ativo char(1) not null,
  constraint pk_web_descontos_progres primary key (id)
);