create table web_prod_agregada_ordenacao (
pva_id number(11) not null,
preco number(15,2) not null,
flestoque char(1) not null,
nro_vendas number(4) not null,
constraint pk_prod_agregada_ordenacao primary key (pva_id),
constraint fk_prod_agregada_ordenacao foreign key (pva_id) references web_prod_venda_agregada (pva_id),
constraint ck_prod_agregada_ordenacao check (flestoque in ('S','N')));