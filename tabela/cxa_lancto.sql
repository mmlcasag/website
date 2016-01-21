/*
create table cxa_lancto as
select codfil, datent, datref, codeve, vallan, condpgto
,      filori, codcli, numtit, destit, numnot, numprc
,      vltotal, dtpagto, tpnota, tipoped, filped, serie
,      forma, numdoc, numped, integracrc, numlan, numprccob
,      status, taxadm, datdep, dtvcto, floperautom, codfilcxa
,      flgeraer, codcon, numcartao, codsegcartao, validcartao
,      obslan, numcartaocript
from   colombo.cxa_lancto@lnkproducao
where  codfil = 400
and    datent >= '01/01/2015';

create index CXA_LANCTO_IDX_CODFILNUMPED on CXA_LANCTO (CODFIL, NUMPED, CODCLI);
create index CXA_LANCTO_IDX_CODFILPEDPARC on CXA_LANCTO (CODFIL, NUMPED, CODCLI, NUMPRC);
create index CXA_LANCTO_IDX_CURNOTA on CXA_LANCTO (CODFIL, NUMPED, DATREF, TIPOPED, TPNOTA, NUMPRC, NUMLAN);
create index CXA_LANCTO_IDX_FIL_DATENT on CXA_LANCTO (CODFIL, DATENT);

alter table CXA_LANCTO add check ("CODFIL" IS NOT NULL);
alter table CXA_LANCTO add check ("NUMPED" IS NOT NULL);
alter table CXA_LANCTO add check ("CODEVE" IS NOT NULL);
*/

alter table cxa_lancto add constraint pk_cxa_lancto primary key (numped, numprc);