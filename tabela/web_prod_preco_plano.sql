/*create table web_prod_preco_plano (
codigo number(10),
prod_preco number(10) not null,
codplano varchar(2) not null,
preco number(10,2) not null,
maior_parcela number(2) not null,
juros number(5,2) not null,
constraint pk_itprod_preco_plano_codigo primary key (codigo),
constraint fk_itprod_preco_plano_preco foreign key (prod_preco) references web_prod_preco(codigo),
constraint fk_itprod_preco_plano_plano foreign key (codplano) references web_plano (codplano) );

create unique index idx_web_prod_preco_plano on web_prod_preco_plano (prod_preco, codplano);

create sequence seq_web_prod_preco_plano;

-- 09/05/2012 - Aquiles - adicionar juros apartir de uma parcela especifica
ALTER TABLE web_prod_preco_plano ADD ("JUROS_PARCELA" NUMBER(2) DEFAULT 1 NOT NULL);
*/
-- 01/10/2012 - Mandelli - Valor calculado da maior parcela (GCS)
ALTER TABLE web_prod_preco_plano ADD vlr_maior_parcela NUMBER(10,2);
