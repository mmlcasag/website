create table web_integr_portal_acesso_url (
codigo number(10) not null,
cod_integr_portal number (10) not null,
url varchar2(400) not null,
data_acesso date not null,
qtde number(6),
custo_acesso number(10,2),
constraint pk_integr_portal_url primary key (codigo),
constraint fk_integr_portal_url foreign key  (cod_integr_portal) references web_integr_portal (cod));

create unique index idx_integr_portal_url on web_integr_portal_acesso_url (cod_integr_portal, url, data_acesso);