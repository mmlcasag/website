create or replace type tp_web_preco_ativo as object(
  CODIGO                         NUMBER(10),
  CODPROD                        NUMBER(10),
  DT_INICIO                      DATE,
  DT_FIM                         DATE,
  PROMOCAO                       NUMBER(10),
  PRECO                          NUMBER(10,2),
  PRECO_ANTIGO                   NUMBER(10,2),
  DT_ALTERACAO                   TIMESTAMP(6)
);