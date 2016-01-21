-- Create table
create table SITEF_LOTES
(
  idelotesitef              NUMBER(10) not null,
  codfilial                 NUMBER(10) not null,
  dathoracriacao            DATE not null,
  desarquivo                VARCHAR2(50) not null,
  estadolote                NUMBER(10) not null,
  nroregerroarquivo         NUMBER(10) not null,
  nroregerroultproc         NUMBER(10) not null,
  nroregokarquivo           NUMBER(10) not null,
  nroregokultproc           NUMBER(10) not null,
  nroregpendentesarquivo    NUMBER(10) not null,
  nroregprocessadoultproc   NUMBER(10) not null,
  nroregsemcomunarquivo     NUMBER(10) not null,
  nroregsemcomunultproc     NUMBER(10) not null,
  nrosequenciaprocessamento NUMBER(10) not null
)
tablespace SITE_DAT
  pctfree 10
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 40K
    next 19176K
    minextents 1
    maxextents 505
    pctincrease 50
  );
-- Create/Recreate primary, unique and foreign key constraints 
alter table SITEF_LOTES
  add primary key (IDELOTESITEF)
  using index 
  tablespace SITE_DAT
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 40K
    next 5680K
    minextents 1
    maxextents 505
    pctincrease 50
  );
alter table SITEF_LOTES
  add unique (DESARQUIVO)
  using index 
  tablespace SITE_DAT
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 40K
    next 8520K
    minextents 1
    maxextents 505
    pctincrease 50
  );
-- Grant/Revoke object privileges 
grant select on SITEF_LOTES to COLOMBO;
grant select, insert, update, delete, references on SITEF_LOTES to LVIRTUAL;
grant select on SITEF_LOTES to MONITORAIT;
grant select on SITEF_LOTES to WEBSITE;
