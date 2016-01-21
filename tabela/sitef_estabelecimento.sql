-- Create table
create table SITEF_ESTABELECIMENTO
(
  idefilialestabelecimento NUMBER(10) not null,
  codadministradora        NUMBER(10) not null,
  codestabelecimento       NUMBER(10) not null,
  codfilial                NUMBER(10) not null
);

-- Create/Recreate primary, unique and foreign key constraints 
alter table SITEF_ESTABELECIMENTO
  add primary key (IDEFILIALESTABELECIMENTO);
  
-- Grant/Revoke object privileges 
grant select on SITEF_ESTABELECIMENTO to COLOMBO;
