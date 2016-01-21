CREATE TABLE web_parametros (
  codparam number(5) not NULL,
  codgrpparam number(5) not NULL,
  descricao varchar2(255),
  fl_perfil number(1),
  fl_ativo number(1) default 1,
  CONSTRAINT web_parametros_PK PRIMARY KEY(codparam),
  CONSTRAINT web_parametros_grp_FK FOREIGN KEY(codgrpparam) REFERENCES web_grpparam(codgrpparam)
);
