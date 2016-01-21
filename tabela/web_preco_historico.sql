-- Create table
create table WEB_PRECO_HISTORICO
(
  idhistorico NUMBER(30) not null,
  dtpreco     DATE not null,
  hora        NUMBER(2) not null,
  minuto      NUMBER(2) not null,
  plano       VARCHAR2(4) not null,
  codprod     NUMBER(7) not null,
  parcela     NUMBER(2) not null,
  preco       NUMBER(10,2) not null,
  juros       NUMBER(9,2),
  promocao    NUMBER(10)
) ;
