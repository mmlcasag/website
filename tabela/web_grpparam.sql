CREATE TABLE web_grpparam (
  codgrpparam number(5) not NULL,
  descricao varchar2(255),
  fl_ativo number(1) default 1,
  CONSTRAINT web_cad_grpparam_PK PRIMARY KEY(codgrpparam)
);