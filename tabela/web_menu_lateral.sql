/*
create table web_menu_lateral (
  codigo integer not null,
  descricao varchar2(150) not null,
  link varchar2(150) not null,
  icone varchar2(150),
  ativo char(1) default 'S' not null,
  data_inicial date not null,
  data_final date not null,
  constraint pk_web_menu_lateral primary key (codigo)
);
*/

drop table web_menu_lateral;