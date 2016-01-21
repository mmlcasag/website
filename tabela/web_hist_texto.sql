CREATE TABLE "WEBSITE"."WEB_HIST_TEXTO"
  (
    "CODIGO" VARCHAR2(50) NOT NULL ENABLE,
    "IDIOMA" VARCHAR2(40) NOT NULL ENABLE,
    "DT_ALTER" TIMESTAMP (6) NOT NULL ENABLE,
    "USER_ALTER" VARCHAR2(50),
    "TEXTO" CLOB,
    CONSTRAINT "WEB_HIST_TEXTO_PK" PRIMARY KEY ("CODIGO", "IDIOMA", "DT_ALTER") 
  );
  
  
-- Joao 23/08/2013 - vers�o do texto
alter table web_hist_texto add versao varchar2(10);