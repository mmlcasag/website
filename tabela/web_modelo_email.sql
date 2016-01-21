-- Create table
/*
create table WEB_MODELO_EMAIL
(
  codigo    NUMBER(2) not null,
  descricao VARCHAR2(50) not null,
  assunto   VARCHAR2(100),
  html      CLOB
)
tablespace SITE_DAT
  pctfree 10
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 40K
    next 40K
    minextents 1
    maxextents 505
    pctincrease 50
  );
-- Create/Recreate indexes 
create index WEB_MODELO_EMAIL_IDX_CODIGO on WEB_MODELO_EMAIL (CODIGO)
  tablespace SITE_IDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 40K
    next 24K
    minextents 1
    maxextents 505
    pctincrease 0
  );
-- Grant/Revoke object privileges 
grant select, references on WEB_MODELO_EMAIL to COLOMBO;
grant select on WEB_MODELO_EMAIL to INF_8;
grant select, insert, update, delete on WEB_MODELO_EMAIL to LVIRTUAL;
*/

/*
ALTER TABLE web_modelo_email NOLOGGING;
ALTER TABLE web_modelo_email MODIFY (html CLOB) LOB (html) STORE AS (NOCACHE NOLOGGING);
ALTER TABLE web_modelo_email MODIFY LOB (html) (CACHE);
ALTER TABLE web_modelo_email LOGGING;
*/

drop index web_modelo_email_idx_codigo;
alter table web_modelo_email add constraint pk_web_modelo_email primary key (codigo);