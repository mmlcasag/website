-- Create table
create table SITEF_CONFIG
(
  ideconfiguracao            NUMBER(10) not null,
  desfiliais                 VARCHAR2(100) not null,
  despasswordlotewin         VARCHAR2(50),
  despathlotewin             VARCHAR2(50),
  desurldestino              VARCHAR2(150) not null,
  desusuariolotewin          VARCHAR2(50),
  indexecutarlotewin         NUMBER(1) not null,
  indtiposaida               NUMBER(10) not null,
  indutilizacoletaautomatica NUMBER(1) not null,
  indziplotes                NUMBER(1) not null,
  nrodiascoleta              NUMBER(10) not null,
  nrominutosintervalocoleta  NUMBER(10) not null
) ;

-- Create/Recreate primary, unique and foreign key constraints 
alter table SITEF_CONFIG add primary key (IDECONFIGURACAO);

-- Grant/Revoke object privileges 
grant select on SITEF_CONFIG to COLOMBO;
grant select on SITEF_CONFIG to LVIRTUAL;
