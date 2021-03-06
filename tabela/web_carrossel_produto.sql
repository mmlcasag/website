CREATE TABLE "WEBSITE"."WEB_CARROSSEL_PRODUTO" (
	"IDCARROSSELPRODUTO" NUMBER(6,0) NOT NULL ENABLE,
	"CODPROD" NUMBER(6,0) NOT NULL ENABLE,
	"IDCARROSSELCONJUNTO" NUMBER(6,0) NOT NULL ENABLE,
	"TEXTO_APOIO" VARCHAR2(100 BYTE),
	 CONSTRAINT "CARROSSEL_PRODUTO_PK" PRIMARY KEY ("IDCARROSSELPRODUTO"),
	 CONSTRAINT "CARROSSEL_CONJUNTO_FK" FOREIGN KEY ("IDCARROSSELCONJUNTO")
	  REFERENCES "WEBSITE"."WEB_CARROSSEL_CONJUNTO" ("IDCARROSSELCONJUNTO") ON DELETE CASCADE ENABLE
);
