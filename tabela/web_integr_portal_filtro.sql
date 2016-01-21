-- JoaoP 02/04/2013

drop table WEB_INTEGR_PORTAL_FILTRO;
CREATE TABLE WEB_INTEGR_PORTAL_FILTRO (
  CODIGO  number(10)  not null primary key,
  "COD_INTEGR_PORTAL" number(10) not null,
  "FILTRO"  varchar2(15) not null,
  "DATA_CADASTRO" DATE not null,
  constraint "fk_web_integr_portal_filtro" foreign key (COD_INTEGR_PORTAL) references web_integr_portal (cod)
);

