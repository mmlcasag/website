
  CREATE TABLE "WEBSITE"."WEB_SLIDER" 
   (	"CODIGO" NUMBER(10,0) NOT NULL ENABLE, 
	"DESCRICAO" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"DT_ALTERACAO" DATE, 
	"DT_FIM" DATE, 
	"DT_INICIO" DATE, 
	"ALTURA" NUMBER(4,0), 
	"FL_ATIVO" VARCHAR2(1 BYTE), 
	"COR_FUNDO" VARCHAR2(20 BYTE), 
	"COR_FUNDO_SEL" VARCHAR2(20 BYTE), 
	"COR_FONTE_BORDA" VARCHAR2(20 BYTE), 
	"COR_FONTE_BORDA_SEL" VARCHAR2(20 BYTE), 
	 CONSTRAINT "WEB_SLIDER_PK" PRIMARY KEY ("CODIGO") ENABLE
   );
 
--cwi_cesar 13/02/2015 Novo Banner parte 2
ALTER TABLE WEB_SLIDER 
ADD (CODLINHA decimal(6,0),
   CODFAM decimal(6,0),
   CODGRUPO decimal(6,0),
   TPBANNER decimal(2,0));

ALTER TABLE WEB_SLIDER 
ADD (NAO_EXIBIR_FAMILIA VARCHAR2(1),
     NAO_EXIBIR_GRUPO VARCHAR2(1));

-- CWI Alisson - 10/03/2015 - Novo Banner Fase 3
ALTER TABLE WEB_SLIDER
ADD (PORTAL NUMBER(10),
    UTM_SOURCE VARCHAR2(100),
    UTM_MEDIUM VARCHAR2(100),
    CODPROD NUMBER(10),
    NAO_EXIBIR_PRODUTO VARCHAR2(1),
    FL_BULLET varchar2(1));