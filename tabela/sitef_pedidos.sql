-- Create table
create table SITEF_PEDIDOS
(
  idepedidositef       NUMBER(10) not null,
  acaooperacao         NUMBER(10),
  codadministradora    NUMBER(10) not null,
  dathorapedido        DATE not null,
  datvalidadecartao    VARCHAR2(8) not null,
  descodigoretorno     VARCHAR2(30),
  desmensagemretorno   VARCHAR2(90),
  desnsuhost           VARCHAR2(30),
  desnsuhostcancelar   VARCHAR2(30),
  desnsusitef          VARCHAR2(30),
  desnomerede          VARCHAR2(30),
  desnumeroautorizacao VARCHAR2(30),
  desorigemretorno     VARCHAR2(30),
  estadooperacao       NUMBER(10) not null,
  nrocartao            VARCHAR2(100) not null,
  nrocodseguracacartao VARCHAR2(10),
  nroparcelas          NUMBER(10) not null,
  nropedido            NUMBER(10) not null,
  vlrtotal             NUMBER(18,4) not null,
  idelotesitef         NUMBER(10)
) ;

-- Create/Recreate indexes 
create index SITEF_PEDIDOS_IDX_IDELOTESITEF on SITEF_PEDIDOS (IDELOTESITEF);
create index SITEF_PEDIDOS_IDX_NRPPED on SITEF_PEDIDOS (NROPEDIDO, IDELOTESITEF);

-- Create/Recreate primary, unique and foreign key constraints 
alter table SITEF_PEDIDOS add primary key (IDEPEDIDOSITEF);
alter table SITEF_PEDIDOS add constraint FK_PEDIDO_LOTE foreign key (IDELOTESITEF) references SITEF_LOTES (IDELOTESITEF);

-- Grant/Revoke object privileges 
grant select on SITEF_PEDIDOS to COLOMBO;
grant select, insert, update, delete, references on SITEF_PEDIDOS to LVIRTUAL;
