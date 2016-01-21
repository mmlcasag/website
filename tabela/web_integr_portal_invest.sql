create table web_integr_portal_invest (
  codigo  integer not null,
  portal  integer not null,
  tipo    char(1) not null,
  codtipo number(6) not null,
  valor   number(10,4) not null,
  constraint pk_integr_portal_invest primary key (codigo),
  constraint uk_integr_portal_invest unique (portal,tipo,codtipo),
  constraint fk_integr_portal_invest_portal foreign key (portal) references web_portal (codigo)
);
-- correção de constraint
delete from web_integr_portal_invest;

alter table web_integr_portal_invest drop constraint FK_INTEGR_PORTAL_INVEST_PORTAL;

alter table web_integr_portal_invest add (
constraint FK_INTEGR_PORTAL_INVEST_PORTAL foreign key (portal) references web_integr_portal (cod));

-- adicionado controle sobre o roi
alter table web_integr_portal_invest add roi_esperado number(10,2);