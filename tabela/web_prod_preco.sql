/*create table web_prod_preco(
codigo number(10),
codprod number(10),
dt_inicio date not null,
dt_fim date not null,
promocao number(10) default null,
preco number(10,2) not null,
preco_antigo number(10,2),
dt_alteracao timestamp not null,
constraint pk_itprod_preco_codigo primary key (codigo),
constraint fk_itprod_preco_webprod foreign key (codprod) references web_prod(codprod),
constraint fk_itprod_preco_campanha foreign key (promocao) references web_campanhas_preco(cpr_id))

create unique index idx_web_prod_preco on web_prod_preco (codprod, promocao, dt_inicio, dt_fim);

create sequence seq_web_prod_preco;

alter table web_prod_preco add(
codfil number(3) default 400,
constraint fk_web_prod_preco_codfil foreign key (codfil) references cad_filial (codfil));

drop index idx_web_prod_preco;
create unique index idx_web_prod_preco on web_prod_preco (codfil, codprod, promocao, dt_inicio, dt_fim, cpd_flativo);


alter table web_prod_preco add (
cpd_flativo char(1),
constraint ck_flativo_preco check  (cpd_flativo in ('S','N')));
*/
--Aquiles CWI 07/11/2013 limite de preços
alter table web_prod_preco add cpd_qtd_limite_compra number(3);