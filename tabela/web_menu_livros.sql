create table web_menu_livros (
  codigo integer not null,
  descricao varchar2(150) not null,
  menu_pai integer not null,
  ativo char(1) not null,
  ordem integer not null,
  constraint pk_menu_livros primary key (codigo)
);