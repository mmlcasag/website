-- Create table
create table WEB_VD_NAO_FINLZD_BRINDE_ITEM
(
  codigo        NUMBER(38) not null,
  vd_brinde_cod NUMBER(38) not null,
  coditprod     NUMBER(38) not null,
  quantidade    NUMBER(38) not null
)
tablespace SITE_DAT
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
