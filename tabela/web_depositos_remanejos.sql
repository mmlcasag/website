-- 100 registros; remanejos entre depósitos

create table web_depositos_remanejos (
codigo number(10),
deposito number(10),
deposito_remanejo number(10),
constraint pk_web_depositos_remanejos primary key (codigo),
constraint fk_web_depos_reman_depos foreign key (deposito) references web_depositos (codigo),
constraint fk_web_depos_reman_depos_reman foreign key (deposito_remanejo) references web_depositos (codigo));

create unique index idx_web_depositos_remanejos on web_depositos_remanejos (deposito, deposito_remanejo);