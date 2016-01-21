create table web_itprod_brinde_ordenacao (
cod_brinde number(10) not null,
preco number(15,2) not null,
flestoque char(1) not null,
nro_vendas number(4) not null,
constraint pk_itprod_brinde_ordenacao primary key (cod_brinde),
constraint fk_itprod_brinde_ordenacao foreign key (cod_brinde) references web_itprod_brinde (cod_brinde),
constraint ck_itprod_brinde_ordenacao check (flestoque in ('S','N')));