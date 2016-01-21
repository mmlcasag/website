-- 270 registros, área de atuação dos depósitos do Site

create table web_depositos_uf (
codigo number(10),
deposito number(10),
uf char(2) not null,
constraint pk_web_depositos_uf primary key (codigo),
constraint fk_web_depositos_uf_deposito foreign key (deposito) references web_depositos (codigo));

create unique index idx_web_depositos_uf on web_depositos_uf (deposito,uf);