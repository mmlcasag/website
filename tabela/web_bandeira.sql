-- Create table
create table WEB_BANDEIRA
(
  codbandeira NUMBER(2) not null,
  descricao   VARCHAR2(40) not null,
  imagem      VARCHAR2(40),
  dtalter     DATE,
  useralter   VARCHAR2(20),
  flativo     CHAR(1) not null
) ;
