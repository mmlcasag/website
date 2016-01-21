-- Marcio Casagrande -- 30/05/2014
-- Projeto Recuperação de Vendas
-- Registros: média de 3 por pedido da web
/*
create table recven_logs
( id         number
, numpedven  number(8)
, username   varchar2(10)
, datetime   date
, descricao  varchar2(100)
, constraint pk_recven_log primary key (id)
) ;

create sequence seq_recven_logs;
create index idx1_recven_logs on recven_logs (numpedven);
create index idx2_recven_logs on recven_logs (username);

grant select on recven_logs to autocomweb;
grant select on recven_logs to apcol;
grant select on recven_logs to colombo;
grant select on recven_logs to inf_8;

alter table recven_logs modify descricao varchar2(150);
*/

alter table recven_logs modify descricao varchar2(500);