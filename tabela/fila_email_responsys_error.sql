-- Alisson CWI 02/01/2015
-- Projeto Responsys

create table fila_email_responsys_error(
  idFilaEmail NUMBER(15,0),
  email VARCHAR2(100),
  errorMessage VARCHAR2(300),
  CONSTRAINT pk_fila_email_responsys_error PRIMARY KEY (idFilaEmail, errorMessage),
  CONSTRAINT fk_fila_email_responsys_error FOREIGN KEY (idFilaEmail) REFERENCES fila_email_responsys
);

-- Alisson CWI 14/05/2015
-- Fila de email projeto Responsys
alter table FILA_EMAIL_RESPONSYS_ERROR add(stacktrace CLOB);