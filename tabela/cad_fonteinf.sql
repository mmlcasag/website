-- Create table
create table CAD_FONTEINF
(
  codfonte  VARCHAR2(4) not null,
  descricao VARCHAR2(15),
  status    NUMBER(1),
  flreplica CHAR(1),
  flint     CHAR(1),
  codmidia  VARCHAR2(40)
) ;

-- Add comments to the table 
comment on table CAD_FONTEINF is 'snapshot table for snapshot WEBSITE.CAD_FONTEINF';

-- Create/Recreate primary, unique and foreign key constraints 
alter table CAD_FONTEINF add constraint CAD_FONTEINF_PK primary key (CODFONTE);
