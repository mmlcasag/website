create table web_integr_portal_acesso (
  codigo integer not null,
  codprod number(6) not null,
  cod_integr_portal integer not null,
  data_acesso date not null,
  qtde integer,
  constraint pk_integr_portal_acesso primary key (codigo),
  constraint fk_integr_acesso_integr_portal foreign key (cod_integr_portal) references web_integr_portal (cod)
);

-- inclusão de controle para investimento
alter table web_integr_portal_acesso add (
custo_acesso number(10,2) );

-- Mandelli (projeto brindes) 04/12
ALTER TABLE web_integr_portal_acesso
add cod_brinde number(10);