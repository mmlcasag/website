/*
-- Create table
create table WEB_MAIS_VENDIDOS
(
  CODPROD     NUMBER not null,
  CODLINHA    NUMBER not null,
  DATA_COMPRA DATE not null,
  QUANTIDADE  NUMBER default 0 not null,
  CODIGO      NUMBER(10) not null
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
-- Create/Recreate primary, unique and foreign key constraints 
alter table WEB_MAIS_VENDIDOS
  add constraint WEB_MAIS_VENDIDOS_PK primary key (CODIGO)
  using index 
  tablespace SITE_DAT
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 40K
    next 40K
    minextents 1
    maxextents 505
    pctincrease 50
  );
  
  
  -- Mandelli (projeto brindes) 04/12
ALTER TABLE web_mais_vendidos
add codbrinde number(10) default 0;
*/

alter table website.web_mais_vendidos add source varchar2(30);