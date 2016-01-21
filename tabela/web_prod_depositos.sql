-- 50000 registros, situação de estoque por produto e deposito

create table web_prod_depositos (
codigo number(10),
deposito number(10),
codprod number(10),
fldisponivel char(1),
constraint pk_web_prod_depositos primary key (codigo),
constraint fk_web_prod_depositos_depos foreign key (deposito) references web_depositos (codigo),
constraint fk_web_prod_depositos_prod foreign key (codprod) references web_prod (codprod),
constraint ck_web_prod_depositos_fld check (fldisponivel in ('S','N')));

create unique index idx_web_prod_depositos on web_prod_depositos (deposito,codprod);