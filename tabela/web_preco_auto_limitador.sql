-- Create table
create table WEB_PRECO_AUTO_LIMITADOR
(
  codigo           NUMBER(10) not null,
  tp_limitador     NUMBER(10) not null,
  valor            NUMBER(10,2) not null,
  preco_automatico NUMBER(10) not null,
  dt_alteracao     DATE not null
) ;
