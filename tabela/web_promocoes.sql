--
-- Tabela desnormalizada, armazena as promocoes, produtos e planos
-- 5000 registros total
--

  CREATE TABLE "WEBSITE"."WEB_PROMOCOES" 
   (	"CODPROMO" NUMBER(6,0) NOT NULL ENABLE, 
	"CODPROD" NUMBER(6,0) NOT NULL ENABLE, 
	"CODPLANO" VARCHAR2(3 BYTE) NOT NULL ENABLE, 
	"QTDPRC" NUMBER(3,0), 
	"PRECO" NUMBER(*,0), 
	"PRECOANTERIOR" NUMBER(*,0), 
	"VLRDESCONTO" NUMBER(*,0), 
	"PERDESCONTO" NUMBER(*,0), 
	"DESCLISTA" VARCHAR2(1 BYTE), 
	 CONSTRAINT "WEB_PROMOCAO_PK1" PRIMARY KEY ("CODPROMO", "CODPROD", "CODPLANO")
  USING INDEX, 
	 CONSTRAINT "WEB_PROMOCAO_WEB_PROMO_FK1" FOREIGN KEY ("CODPROMO")
	  REFERENCES "WEBSITE"."WEB_PROMO" ("CODPROMO") ENABLE, 
	 CONSTRAINT "WEB_PROMOCAO_WEB_PROD_FK1" FOREIGN KEY ("CODPROD")
	  REFERENCES "WEBSITE"."WEB_PROD" ("CODPROD") ENABLE, 
	 CONSTRAINT "WEB_PROMOCAO_WEB_PLANO_FK1" FOREIGN KEY ("CODPLANO")
	  REFERENCES "WEBSITE"."WEB_PLANO" ("CODPLANO") ENABLE
   );
 