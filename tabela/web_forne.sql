-- Create table
create table WEB_FORNE
(
  codforne  NUMBER not null,
  descricao VARCHAR2(40),
  dtalter   DATE,
  useralter VARCHAR2(20),
  flativo   CHAR(1) default 'S' not null
)
tablespace SITE_DAT
  pctfree 10
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 600K
    next 216K
    minextents 1
    maxextents 505
    pctincrease 50
  );
-- Create/Recreate primary, unique and foreign key constraints 
alter table WEB_FORNE
  add constraint WEB_FORNE_PK primary key (CODFORNE)
  using index 
  tablespace SITE_IDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 200K
    next 96K
    minextents 1
    maxextents 505
    pctincrease 50
  );
-- Grant/Revoke object privileges 
grant select, insert, update, delete, references on WEB_FORNE to COLOMBO;
grant select, alter on WEB_FORNE to DBVREP;
grant select, insert, update, delete on WEB_FORNE to LVIRTUAL;
grant select on WEB_FORNE to WEBSITE;
