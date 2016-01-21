-- Tabela de log dados cartão: Rodrigo Mandelli
-- Quantidade de registros: 100 mil. 

create table mov_pedido_web_ce
( codfil number(3)
, numpedven number(8)
, codcli number(15)
, data timestamp
, numCartaoCript varchar2(100)
, numcartao varchar(20)
, codsegcartao varchar2(10)
, admcartao number(3)
, proc varchar2(30)
, constraint mov_pedido_web_ce_pk primary key (numpedven)
) ;

grant select, insert, update, delete, references on mov_pedido_web_ce to lvirtual;

-- conn as lvirtual@oraprod:
insert into website.mov_pedido_web_ce 
  select * from lvirtual.mov_pedido_web_ce;

-- conn as system@oraprod:
drop public synonym mov_pedido_web_ce;

-- conn as website@oraprod:
create public synonym mov_pedido_web_ce for website.mov_pedido_web_ce;

-- conn as lvirtual@oraprod:
drop table lvirtual.mov_pedido_web_ce;
