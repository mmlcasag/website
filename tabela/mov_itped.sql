create table mov_itped as
select codfil, tipoped, numpedven, coditprod, item, codcli, qtcomp
,      precounit, aliqicm, aliqicmsub, aliqicmred, local, tpdepos
,      filorig, qtreceb, cubagem, unembal, codembal, rua, bloco, apto
,      dpi, peso, status, tpnota, medger, dtpedido, numpedcomp
,      vlfrete, precounitliq, cmup, sitcarga, codsitprod
,      aliqicmsubuf, flvdantec, vldescitem, qtemb, qtvolume
,      precoorig, ctf, vltotitem, vljurosfin, fllibfat
,      situacao, unidade, condpgto, flvdantecant, qtestoque
from   colombo.mov_itped@lnkproducao
where  codfil = 400
and    tpnota = 52
and    dtpedido >= '01/01/2015';

create index MOV_ITPED_IDX_COL_DTPEDIDO on MOV_ITPED (DTPEDIDO);
create index MOV_ITPED_IDX_FILITCLISTTPN on MOV_ITPED (CODFIL, CODITPROD, CODCLI, STATUS, TPNOTA);
create index MOV_ITPED_IDX_FILORIGNUMPECOMP on MOV_ITPED (FILORIG, NUMPEDCOMP);
create index MOV_ITPED_IDX_FILORIGTPSTAFLV on MOV_ITPED (FILORIG, TPNOTA, STATUS, FLVDANTEC);
create index MOV_ITPED_IDX_FILSTAPEDFLV on MOV_ITPED (CODFIL, STATUS, NUMPEDCOMP, FLVDANTEC);
create index MOV_ITPED_IDX_FIL_ITPROD_DTPED on MOV_ITPED (CODFIL, CODITPROD, DTPEDIDO);
create index MOV_ITPED_IDX_ITPRODTPCLI on MOV_ITPED (CODITPROD, TPNOTA, NVL(STATUS,0), CODCLI);
create index MOV_ITPED_IDX_NUMPEDVEN on MOV_ITPED (NUMPEDVEN);
create index MOV_ITPED_IDX_ORIGITFLVSTA on MOV_ITPED (FILORIG, CODITPROD, FLVDANTEC, STATUS);

alter table MOV_ITPED add constraint MOV_ITPED_PK primary key (CODFIL, TIPOPED, NUMPEDVEN, CODITPROD);
alter table MOV_ITPED add constraint MOV_ITPED_FK_PEDIDO foreign key (CODFIL, TIPOPED, NUMPEDVEN) references MOV_PEDIDO (CODFIL, TIPOPED, NUMPEDVEN);

alter table MOV_ITPED add check ("CODFIL" IS NOT NULL);
alter table MOV_ITPED add check ("TIPOPED" IS NOT NULL);
alter table MOV_ITPED add check ("NUMPEDVEN" IS NOT NULL);
alter table MOV_ITPED add check ("CODITPROD" IS NOT NULL);