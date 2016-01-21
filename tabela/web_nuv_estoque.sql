create table web_nuv_estoque
( codfil     number           not null
, coditprod  number           not null
, reservado  number default 0 not null
, constraint pk_nuv_estoque primary key (codfil, coditprod)
) ;

insert into web_nuv_estoque select codfil, coditprod, 0 from cad_prodloc;
