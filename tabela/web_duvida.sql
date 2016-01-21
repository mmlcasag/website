-- Create table
create table WEB_DUVIDA
(
  codduvida NUMBER(2) not null,
  duvida    VARCHAR2(60) not null,
  resposta  VARCHAR2(2000) not null,
  reduzida  VARCHAR2(20) not null,
  useralter VARCHAR2(20),
  dtalter   DATE
) ;
