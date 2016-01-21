create or replace type tp_web_virtual_gsa AS OBJECT (
  CODIGO                                  NUMBER(6),
  CODPROD                                 VARCHAR2(200),
  TIPOPROD                                CHAR(1),
  DESCRICAO                               VARCHAR2(4000),
  CODGRUPO                                NUMBER(6),
  DESC_GRUPO                              VARCHAR2(4000),
  DESC_FAM                                VARCHAR2(4000),
  CODFAM                                  NUMBER(3),
  CODLINHA                                NUMBER(3),
  DESC_LIN                                VARCHAR2(4000),
  MINIDESCRICAO                           VARCHAR2(4000),
  MINIDESCRICAO_LOB                       CLOB,
  PRECOVISTA                              NUMBER,
  CODEMPRESA                              NUMBER(6),
  DESC_EMPRESA                            VARCHAR2(4000),
  FLATIVO                                 CHAR(1),
  FLCATALOGO                              CHAR(1),
  MIME                                    CHAR(9),
  ESTOQUE_PR                              VARCHAR2(4000),
  ESTOQUE_RS                              VARCHAR2(4000),
  ESTOQUE_SP                              VARCHAR2(4000),
  URL                                     VARCHAR2(300),
  FLPREMIUM                               CHAR(1),
  FLOUTLET                                CHAR(1),

  CONSTRUCTOR FUNCTION tp_web_virtual_gsa(CODIGO NUMBER, TIPO CHAR)
    RETURN SELF AS RESULT

);
-- aquiles  - adicionado campo qnt_vendida para retornar quantidade de mais vendidos
ALTER TYPE tp_web_virtual_gsa ADD ATTRIBUTE (QNT_VENDIDA NUMBER(4)) CASCADE;
-- Thiago - excluido projeto do site premium
 ALTER TYPE tp_web_virtual_gsa DROP ATTRIBUTE flpremium invalidate;
--Aquiles - adicionado campo para retornar a media das avaliacoes
ALTER TYPE tp_web_virtual_gsa ADD ATTRIBUTE (AVALIACAO NUMBER(2,2)) CASCADE;