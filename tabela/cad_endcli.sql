create table cad_endcli as
select e.codcli, e.codend, e.tpender, e.endereco, e.numero, e.refer, e.bairro
,      e.cidade, e.estado, e.cep, e.complemento, e.dddfone1, e.fone1, e.ramalfone1
,      e.dddfone2, e.fone2, e.ramalfone2, e.ddd, e.fone, e.e_mail, e.col_codcidade
from   colombo.cad_endcli@lnkproducao e
join   cad_cliente c on c.codcli = e.codcli
where  c.codfilcad = 400;

create index CAD_ENDCLI_IDX_CEP on CAD_ENDCLI (CEP);
create index CAD_ENDCLI_IDX_CIDADE on CAD_ENDCLI (CIDADE);
create index CAD_ENDCLI_IDX_CRM on CAD_ENDCLI (ENDERECO, FONE1, FONE2, FONE, CIDADE, ESTADO, CEP, BAIRRO);
create index CAD_ENDCLI_IDX_ESTADOEND on CAD_ENDCLI (ESTADO, ENDERECO);
create index CAD_ENDCLI_IDX_FONE1 on CAD_ENDCLI (FONE1);
create index CAD_ENDCLI_IDX_FONE2 on CAD_ENDCLI (FONE2);

alter table CAD_ENDCLI add constraint CAD_ENDCLI_PK primary key (CODCLI, CODEND);
alter table CAD_ENDCLI add constraint CAD_ENDCLI_FK_CLI foreign key (CODCLI) references CAD_CLIENTE (CODCLI);

alter table CAD_ENDCLI add check ("CODCLI" IS NOT NULL);
alter table CAD_ENDCLI add check ("CODEND" IS NOT NULL);
alter table CAD_ENDCLI add check ("ESTADO" IS NOT NULL);