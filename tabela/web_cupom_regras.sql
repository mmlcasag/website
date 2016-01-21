create table web_cupom_regras
( id_regra     number(15) not null
, id_regra_pai number(15)
, id_cupom     number(10) not null
, tipo_regra   number(05) not null
, clausula_1   varchar2(100)
, clausula_2   varchar2(100)
, clausula_3   varchar2(100)
, clausula_4   varchar2(100)
, constraint pk_web_cupom_regras  primary key (id_regra)
, constraint fk1_web_cupom_regras foreign key (id_regra_pai) references web_cupom_regras (id_regra)
, constraint fk2_web_cupom_regras foreign key (id_cupom)     references web_cupom        (id)
) ;

grant select, insert, update, delete on web_cupom_regras to lvirtual;
grant select, insert, update, delete on web_cupom_regras to apcol;
grant select, insert, update, delete on web_cupom_regras to autocomweb;
grant select, insert, update, delete on web_cupom_regras to colombo;

create public synonym web_cupom_regras for website.web_cupom_regras;

grant select on web_cupom_regras to lvirtual;
grant select on web_cupom_regras to apcol;
grant select on web_cupom_regras to autocomweb;
grant select on web_cupom_regras to colombo;
grant select on web_cupom_regras to inf_8;