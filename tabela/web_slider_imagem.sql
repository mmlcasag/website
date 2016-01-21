
  CREATE TABLE "WEBSITE"."WEB_SLIDER_IMAGEM" 
   (	"CODIGO" NUMBER(10,0) NOT NULL ENABLE, 
	"SLIDER" NUMBER(10,0) NOT NULL ENABLE, 
	"PATH" VARCHAR2(200 BYTE), 
	"LABEL" VARCHAR2(30 BYTE), 
	"LINK" VARCHAR2(200 BYTE), 
	"TITLE" VARCHAR2(30 BYTE), 
	"ALT" VARCHAR2(30 BYTE), 
	"ORDEM" NUMBER(2,0), 
	"COR_FUNDO" VARCHAR2(20 BYTE), 
	"ONCLIC" VARCHAR2(500 BYTE), 
	 CONSTRAINT "WEB_SLIDER_IMAGEM_PK" PRIMARY KEY ("CODIGO") ENABLE, 
	 CONSTRAINT "WEB_SLIDER_IMAGEM_FK1" FOREIGN KEY ("SLIDER")
	  REFERENCES "WEBSITE"."WEB_SLIDER" ("CODIGO") ENABLE
   );
 
