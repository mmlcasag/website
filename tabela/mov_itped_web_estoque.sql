-- Create table
/*
create table MOV_ITPED_WEB_ESTOQUE
( codigo          NUMBER(10)  not null,
  numpedven       NUMBER(8)   not null,
  deposito        NUMBER(3)   not null,
  coditprod       NUMBER(6)   not null,
  codsitprod      VARCHAR2(2) not null,
  data_log        DATE        not null,
  fisico          NUMBER(9),
  resfis          NUMBER(9),
  dt_descarga     DATE,
  qtdagendada     NUMBER(9),
  qtd_estoque_edi NUMBER(6),
  flvdantec       CHAR(1)
) ;

-- Create/Recreate indexes 
create unique index IDX_MOV_ITPED_WEB_EST on MOV_ITPED_WEB_ESTOQUE (NUMPEDVEN, CODITPROD);

-- Create/Recreate primary, unique and foreign key constraints 
alter table MOV_ITPED_WEB_ESTOQUE
  add constraint PK_MOV_ITPED_WEB_EST primary key (CODIGO);
  
alter table MOV_ITPED_WEB_ESTOQUE
  add constraint FK_MOV_ITPED_WEB_ITPROD foreign key (CODITPROD) references WEB_ITPROD (CODITPROD);
  
-- Grant/Revoke object privileges 
grant select, references on MOV_ITPED_WEB_ESTOQUE to COLOMBO;
grant select on MOV_ITPED_WEB_ESTOQUE to CPD_1;
grant select on MOV_ITPED_WEB_ESTOQUE to INF_8;
grant select, insert, update, delete on MOV_ITPED_WEB_ESTOQUE to LVIRTUAL;
*/

alter table mov_itped_web_estoque add nuv_reservado number(9);