CREATE TABLE MOV_ITPED_WEB
( CODFIL      NUMBER(3,0) NOT NULL
, TIPOPED     NUMBER(1,0) NOT NULL
, NUMPEDVEN   NUMBER(8,0) NOT NULL
, CODITPROD   NUMBER(6,0) NOT NULL
, CODDESCONTO NUMBER(15,0)
, CONSTRAINT WEB_ITPED_PK PRIMARY KEY (CODFIL, TIPOPED, NUMPEDVEN, CODITPROD)
) ;

alter table mov_itped_web
add campanha_preco number(10);

alter table mov_itped_web
add constraint fk_campanha_preco
    foreign key (campanha_preco)
    references website.web_campanhas_preco(cpr_id);
    
create index IDX_PESQUISA_CAMPANHA_ITPED on MOV_ITPED_WEB (CAMPANHA_PRECO);

alter table mov_itped_web add 
( cod_brinde number(10) default null
, constraint fk_web_itprod_brinde foreign key (cod_brinde) references web_itprod_brinde (cod_brinde)
) ;

insert into website.mov_itped_web 
select * from lvirtual.mov_itped_web;

drop public synonym mov_itped_web;

create public synonym mov_itped_web for website.mov_itped_web;

drop table lvirtual.mov_itped_web;
