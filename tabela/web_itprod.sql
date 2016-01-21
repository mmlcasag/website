--
-- Armazena os dados dos itens de produtos do site
-- 100 registros / mes
--

  CREATE TABLE "WEBSITE"."WEB_ITPROD" 
   (	"CODITPROD" NUMBER(7,0) NOT NULL ENABLE, 
	"CODPROD" NUMBER(6,0) NOT NULL ENABLE, 
	"CODSITPROD" VARCHAR2(2 BYTE) NOT NULL ENABLE, 
	"CODPRODDF" VARCHAR2(11 BYTE) NOT NULL ENABLE, 
	"ESPECIFIC" VARCHAR2(20 BYTE), 
	"COR" VARCHAR2(15 BYTE), 
	"PRECO" NUMBER(15,2), 
	"DTALTER" DATE, 
	"USERALTER" VARCHAR2(20 BYTE), 
	"FLATIVO" VARCHAR2(1 BYTE) DEFAULT 'S' NOT NULL ENABLE, 
	 CONSTRAINT "WEB_ITPROD_PK" PRIMARY KEY ("CODITPROD") USING INDEX, 
	 CONSTRAINT "WEB_ITPROD_FK_PROD" FOREIGN KEY ("CODPROD")
	  REFERENCES "WEBSITE"."WEB_PROD" ("CODPROD") ENABLE
   );
 
  CREATE INDEX "WEBSITE"."WEB_ITPROD_IDX_CODPROD" ON "WEBSITE"."WEB_ITPROD" ("CODPROD");
  CREATE UNIQUE INDEX "WEBSITE"."WEB_ITPROD_PK" ON "WEBSITE"."WEB_ITPROD" ("CODITPROD");

-- Lucas - 24/01/2008 - controla a ativacao para o catalogo
ALTER TABLE WEB_ITPROD ADD ("FLCATALOGO" CHAR(1) DEFAULT 'S' NOT NULL);
--Thiago - 26/02/2008 - código de barras
ALTER TABLE WEB_ITPROD ADD CODBARRA NUMBER(14,0);
--Marcio - 09/07/2008 - privilégios para o lvirtual, necessário em pkg_politicas_frete
GRANT ALL ON web_itprod TO lvirtual;

--### projeto 1977 - site premium ###
alter table web_itprod
add flpremium char(1);

-- Aquiles CWI 10/01/2014 - codigo do item/produto no fornecedor
alter table web_itprod add cod_fornecedor varchar2(60);