/*
create table web_cupom
( id             number(10)             not null
, descricao      varchar2(100)          not null
, codigo         varchar2(20)
, status         number(1)    default 0 not null
, limite_total   number(15,2) default 0 not null
, limite_cliente number(15,2) default 0 not null
, constraint pk_web_cupom primary key (id)
) ;

grant select, insert, update, delete on web_cupom to lvirtual;
grant select, insert, update, delete on web_cupom to apcol;
grant select, insert, update, delete on web_cupom to autocomweb;
grant select, insert, update, delete on web_cupom to colombo;

create public synonym web_cupom for website.web_cupom;

grant select on web_cupom to lvirtual;
grant select on web_cupom to apcol;
grant select on web_cupom to autocomweb;
grant select on web_cupom to colombo;
grant select on web_cupom to inf_8;
*/

alter table web_cupom add dtvalini date;
alter table web_cupom add dtvalfim date;