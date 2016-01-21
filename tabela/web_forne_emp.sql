-- Create table
create table WEB_FORNE_EMP
(
  codforne   NUMBER(6) not null,
  codempresa NUMBER(6) not null
)
tablespace SITE_DAT
  pctfree 10
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 80K
    next 40K
    minextents 1
    maxextents 505
    pctincrease 50
  );
-- Create/Recreate primary, unique and foreign key constraints 
alter table WEB_FORNE_EMP
  add constraint PK_WEB_FORNE_EMP primary key (CODFORNE, CODEMPRESA)
  using index 
  tablespace SITE_DAT
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 80K
    next 96K
    minextents 1
    maxextents 505
    pctincrease 50
  );
alter table WEB_FORNE_EMP
  add constraint FK_WEB_FORNE_EMP_CODEMPRESA foreign key (CODEMPRESA)
  references WEB_EMPRESA (CODEMPRESA);
alter table WEB_FORNE_EMP
  add constraint FK_WEB_FORNE_EMP_CODFORNE foreign key (CODFORNE)
  references WEB_FORNE (CODFORNE);
-- Grant/Revoke object privileges 
grant select, references on WEB_FORNE_EMP to COLOMBO;
grant select, alter on WEB_FORNE_EMP to DBVREP;
grant select, insert, update, delete, references on WEB_FORNE_EMP to LVIRTUAL;
