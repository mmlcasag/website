/*
create table web_cupom_utilizacoes
( id      number(10)   not null
, codigo  varchar2(20) not null
, codcli  number(15)   not null
, constraint pk_web_cupom_utilizacoes primary key (id)
, constraint fk1_utilizacoes_cupons   foreign key (codcli) references cad_cliente (codcli)
) ;

grant select, insert, update, delete on web_cupom_utilizacoes to lvirtual;
grant select, insert, update, delete on web_cupom_utilizacoes to apcol;
grant select, insert, update, delete on web_cupom_utilizacoes to autocomweb;
grant select, insert, update, delete on web_cupom_utilizacoes to colombo;

create public synonym web_cupom_utilizacoes for website.web_cupom_utilizacoes;

grant select on web_cupom_utilizacoes to lvirtual;
grant select on web_cupom_utilizacoes to apcol;
grant select on web_cupom_utilizacoes to autocomweb;
grant select on web_cupom_utilizacoes to colombo;
grant select on web_cupom_utilizacoes to inf_8;
alter table web_cupom_utilizacoes rename column codcli to codclilv;

alter table web_cupom_utilizacoes drop constraint FK1_UTILIZACOES_CUPONS;
alter table web_cupom_utilizacoes add  constraint FK1_UTILIZACOES_CUPONS foreign key (codclilv) references web_usuarios (codclilv);
*/

delete from website.web_cupom_utilizacoes; -- Sim, é para deletar mesmo, só tem 1 registro e é teste
alter table website.web_cupom_utilizacoes add numpedven number(8) not null;