CREATE TABLE web_respparam (
  codparam number(5) not NULL,
  resposta varchar2(255),
  perfil varchar(20),
  CONSTRAINT web_cad_respparam_PK PRIMARY KEY(codparam, perfil),
  CONSTRAINT web_respparam_param_FK FOREIGN KEY(codparam) REFERENCES web_parametros(codparam)
);