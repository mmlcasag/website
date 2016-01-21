CREATE TABLE "WEBSITE"."WEB_COMPARADOR_ANUNCIO"
  (
    "CODIGO"      NUMBER(10,0),
    "CODPROD"     NUMBER(10,0) NOT NULL ENABLE,
    "CODEMPRESA"  NUMBER(10,0) NOT NULL ENABLE,
    "UF"          VARCHAR2(2 BYTE),
    "VEICULO"     VARCHAR2(100 BYTE),
    "VAREJO"      VARCHAR2(100 BYTE),
    "PRECO_VISTA" NUMBER(10,2),
    CONSTRAINT "PK_COMPARADOR_ANUNCIO" PRIMARY KEY ("CODIGO")  ENABLE,
    CONSTRAINT "FK_WEB_COMPARADOR_EMPRESA" FOREIGN KEY ("CODEMPRESA") REFERENCES "WEBSITE"."WEB_COMPARADOR_EMPRESA" ("CODEMPRESA") ENABLE,
    CONSTRAINT "FK_WEB_PROD_COMPARADOR" FOREIGN KEY ("CODPROD") REFERENCES "WEBSITE"."WEB_PROD" ("CODPROD") ENABLE
  )


  CREATE INDEX "WEBSITE"."idx_web_comparador_anuncio " ON "WEBSITE"."WEB_COMPARADOR_ANUNCIO"( "CODPROD","CODEMPRESA","VAREJO","VEICULO","UF");
    