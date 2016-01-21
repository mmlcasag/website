create table produtos_da_lista as
select p.numero_da_lista, p.pgen_codigo, p.coditprod, p.qtde_sugerida
,      p.qtde_comprada, p.qtde_reservada, p.id_produto_da_lista 
from   noivas.produtos_da_lista@lnkproducao p
join   listas_de_noivas l on l.numero_da_lista = p.numero_da_lista
where  l.codfil = 400
and    trunc(l.data_cadastramento) >= '01/01/2015';

create index PRLI_ITPR_FK_I on PRODUTOS_DA_LISTA (CODITPROD);
create index PRODUTOS_DA_LISTA_IDX_NROIT on PRODUTOS_DA_LISTA (NUMERO_DA_LISTA, CODITPROD);

alter table PRODUTOS_DA_LISTA add constraint PRLI_PK primary key (NUMERO_DA_LISTA, PGEN_CODIGO, CODITPROD);
alter table PRODUTOS_DA_LISTA add constraint UK_ID_PRODUTO_DA_LISTA unique (ID_PRODUTO_DA_LISTA);