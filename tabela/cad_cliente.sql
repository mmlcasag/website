create table cad_cliente as
select codcli, digcli, codvendr, cgccpf, nomcli, dtnasc, codfilcad
,      dtcadast, numdoc, emissor, nomemae, nomepai, conjuge, empresa
,      codcargo, ramatv, codestcivil, codsitcred, natjur, cod_cli_auto
,      status, inscr, sexo, vlrendbruto, tpresid, temporesidmes, dtultmcomp
from   colombo.cad_cliente@lnkproducao
where  codfilcad = 400;

create index CAD_CLIENTE_IDX_CGCCOD on CAD_CLIENTE (CGCCPF, CODCLI);
create index CAD_CLIENTE_IDX_CGCCPF on CAD_CLIENTE (CGCCPF);
create index CAD_CLIENTE_IDX_CODCARGO on CAD_CLIENTE (CODCARGO, CGCCPF);
create index CAD_CLIENTE_IDX_CRM on CAD_CLIENTE (CODFILCAD, DTNASC, NATJUR, DTCADAST, CODFILCAD, CODESTCIVIL, CODCARGO, VLRENDBRUTO);
create index CAD_CLIENTE_IDX_DDMMDTNASC on CAD_CLIENTE (TO_CHAR(DTNASC,'dd/mm'));
create index CAD_CLIENTE_IDX_DTCAD on CAD_CLIENTE (DTCADAST, CODFILCAD);
create index CAD_CLIENTE_IDX_DTNAS on CAD_CLIENTE (CGCCPF, TO_CHAR(DTNASC,'dd/mm'));
create index CAD_CLIENTE_IDX_DTULTCOMP on CAD_CLIENTE (CODFILCAD, DTULTMCOMP, NATJUR);
create index CAD_CLIENTE_IDX_FILNOMCLI on CAD_CLIENTE (CODFILCAD, NOMCLI);
create index CAD_CLIENTE_IDX_INSCR on CAD_CLIENTE (INSCR);
create index CAD_CLIENTE_IDX_NOM on CAD_CLIENTE (NOMCLI);
create index CAD_CLIENTE_IDX_NUMDOC on CAD_CLIENTE (NUMDOC);
create index CAD_CLIENTE_IDX_VENDR_FILCAD on CAD_CLIENTE (CODVENDR, CODFILCAD);

alter table CAD_CLIENTE add constraint CAD_CLIENTE_PK primary key (CODCLI);
alter table CAD_CLIENTE add constraint UK_COD_CLI_AUTO unique (COD_CLI_AUTO);

alter table CAD_CLIENTE add check ("CODCLI" IS NOT NULL);