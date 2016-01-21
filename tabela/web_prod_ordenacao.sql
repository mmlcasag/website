create table web_prod_ordenacao (
codprod number(10) not null,
preco number(15,2) not null,
flestoque char(1) not null,
nro_vendas number(4) not null,
constraint pk_prod_ordenacao primary key (codprod),
constraint fk_prod_ordenacao foreign key (codprod) references web_prod (codprod),
constraint ck_pro_ordenacao check (flestoque in ('S','N')));