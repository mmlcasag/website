-- Alisson CWI 02/01/2015
-- Fila de email projeto Responsys

create table fila_email_responsys(
  idFilaEmail NUMBER(15,0) CONSTRAINT pk_fila_email_transacionais PRIMARY KEY,
  tpEmail NUMBER(30,0) NOT NULL,
  email VARCHAR2(100) NOT NULL,
  parametros VARCHAR2(1000),
  dtCadastro DATE NOT NULL,
  dtEnvio DATE
);