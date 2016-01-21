create table pedido_nota_noivas as
select v.numero_da_lista, v.codfil, v.numdoc, v.serie, v.flg_doc
,      v.dtnota, v.coditprod, v.qtde, v.status, v.codvendr, v.usuario
from   colombo.pedido_nota_noivas@lnkproducao v
join   listas_de_noivas l on l.numero_da_lista = v.numero_da_lista
where  l.codfil = 400
and    trunc(l.data_cadastramento) >= '01/01/2015';

create index PEDIDO_NOTA_NOIVAS_IDX_FILDOC on PEDIDO_NOTA_NOIVAS (CODFIL, NUMDOC);

alter table PEDIDO_NOTA_NOIVAS add constraint PEDIDO_NOTA_NOIVAS_PK primary key (NUMERO_DA_LISTA, CODFIL, NUMDOC, SERIE, DTNOTA, CODITPROD);