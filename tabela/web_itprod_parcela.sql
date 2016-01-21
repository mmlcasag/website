-- Create table
create table WEB_ITPROD_PARCELA
(
  codfil          NUMBER(3) not null,
  coditprod       NUMBER(6) not null,
  tppgto          NUMBER(3) not null,
  parcela         NUMBER(3) not null,
  preconormal     NUMBER(10,2) not null,
  margemnormal    NUMBER(6,4),
  rebate          NUMBER(6,4) not null,
  preco           NUMBER(10,2) not null,
  margem          NUMBER(6,4),
  flmaiorcondicao CHAR(1),
  codperfil       NUMBER(3),
  id              NUMBER(20) not null,
  coddesconto     NUMBER(15),
  cpr_id          NUMBER(10),
  juros           NUMBER(5,2)
)
tablespace SITE_DAT
  pctfree 10
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 40M
    next 15M
    minextents 1
    maxextents 505
    pctincrease 0
  );
-- Create/Recreate indexes 
create index WEB_ITPROD_PARCELA_IDX_1 on WEB_ITPROD_PARCELA (CODFIL, CODPERFIL, CODITPROD, PARCELA, PRECONORMAL, REBATE)
  tablespace SITE_IDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 3M
    next 2080K
    minextents 1
    maxextents 505
    pctincrease 0
  );
create index WEB_ITPROD_PARCELA_IDX_CODDESC on WEB_ITPROD_PARCELA (CODDESCONTO)
  tablespace SITE_IDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 3M
    next 2M
    minextents 1
    maxextents 505
    pctincrease 0
  );
create index WEB_ITPROD_PARCELA_IDX_CODPERF on WEB_ITPROD_PARCELA (CODPERFIL)
  tablespace SITE_IDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 3M
    next 2080K
    minextents 1
    maxextents 505
    pctincrease 0
  );
create index WEB_ITPROD_PARCELA_IDX_ITPPARC on WEB_ITPROD_PARCELA (CODITPROD, PARCELA)
  tablespace SITE_IDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 8M
    next 4120K
    minextents 1
    maxextents 505
    pctincrease 0
  );
create index WEB_ITPROD_PARCELA_IDX_PARCELA on WEB_ITPROD_PARCELA (PARCELA)
  tablespace SITE_IDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 8M
    next 3080K
    minextents 1
    maxextents 505
    pctincrease 0
  );
-- Create/Recreate primary, unique and foreign key constraints 
alter table WEB_ITPROD_PARCELA
  add constraint WEB_ITPROD_PARCELA_PK primary key (ID)
  using index 
  tablespace SITE_DAT
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 40K
    next 19176K
    minextents 1
    maxextents 505
    pctincrease 50
  );
alter table WEB_ITPROD_PARCELA
  add constraint WEB_ITPROD_PARCELA_UK unique (CODFIL, CODITPROD, TPPGTO, PARCELA, PRECONORMAL, REBATE, CODPERFIL, CODDESCONTO, JUROS)
  using index 
  tablespace SITE_DAT
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 40K
    next 19176K
    minextents 1
    maxextents 505
    pctincrease 50
  );
alter table WEB_ITPROD_PARCELA
  add constraint FK_ITPROD_PARC_CODPERFIL_PRD foreign key (CODPERFIL)
  references WEB_PERFIL (CODIGO);
alter table WEB_ITPROD_PARCELA
  add constraint WEB_ITPROD_PARCELA_DESC_FK foreign key (CODDESCONTO)
  references WEB_DESCONTOS (CODDESCONTO);
-- Grant/Revoke object privileges 
grant select, insert, update, delete on WEB_ITPROD_PARCELA to BATCH;
grant select, references on WEB_ITPROD_PARCELA to COLOMBO;
grant select, alter on WEB_ITPROD_PARCELA to DBVREP;
grant select, insert, update, delete, references on WEB_ITPROD_PARCELA to LVIRTUAL;
