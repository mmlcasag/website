-- Create table
create table WEB_LOGS
(
  codigo            NUMBER(10) not null,
  tabela_referencia VARCHAR2(200),
  id_referencia     VARCHAR2(200),
  alteracao         VARCHAR2(4000),
  usuario           VARCHAR2(200),
  operacao          VARCHAR2(50),
  dt_alteracao      TIMESTAMP(6),
  ip                VARCHAR2(15)
)
tablespace SITE_DAT
  pctfree 10
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 50M
    next 20M
    minextents 1
    maxextents 505
    pctincrease 0
  );
-- Create/Recreate primary, unique and foreign key constraints 
alter table WEB_LOGS
  add constraint WEB_LOGS_PK primary key (CODIGO)
  using index 
  tablespace SITE_IDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 20M
    next 10M
    minextents 1
    maxextents 505
    pctincrease 0
  );
-- Grant/Revoke object privileges 
grant select, references on WEB_LOGS to COLOMBO;
grant select, alter on WEB_LOGS to DBVREP;
grant select, insert, update, delete, references on WEB_LOGS to LVIRTUAL;
