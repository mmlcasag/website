create table web_vd_nao_finalizada_brinde (

  codigo   integer not null,

  codigo_venda  integer not null,

  coditprod integer not null,

  codbrinde integer not null,

  quantidade integer not null,

  constraint pk_vd_nao_finalizada_brinde primary key (codigo),

  constraint fk_brinde_vd_nao_finalizada foreign key (codigo_venda) references web_venda_nao_finalizada (codigo)

);

--Aquiles B. da Silva 19/04/2013
alter table web_vd_nao_finalizada_brinde add (preco number(6,2) null);
