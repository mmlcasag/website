CREATE TABLE "WEBSITE"."WEB_COMPARADOR_PLANO"
  (
    "QTDPARCELAS"   NUMBER(2,0),
    "VLRPARCELA"    NUMBER(11,2),
    "VLRENTRADA"    NUMBER(11,2),
    "CARTOES"       VARCHAR2(30 BYTE),
    "PERIODICIDADE" VARCHAR2(40 BYTE),
    "TAXAJURO"      NUMBER(8,2),
    "CONDICAO"      VARCHAR2(20 BYTE),
    "CODCOMANUNCIO" NUMBER(10,0),
    "CODCOMPLANO"   NUMBER(10,0) NOT NULL ENABLE,
    CONSTRAINT "WEB_COMPARADOR_PLANO_PK" PRIMARY KEY ("CODCOMPLANO")  ENABLE,
    CONSTRAINT "FK_COMPARADOR_ANUNCIO" FOREIGN KEY ("CODCOMANUNCIO") REFERENCES "WEBSITE"."WEB_COMPARADOR_ANUNCIO" ("CODIGO") ENABLE
  )
     
   CREATE INDEX "WEBSITE"."WEB_COMPARADOR_PLANO_INDEX1" ON "WEBSITE"."WEB_COMPARADOR_PLANO" ("CODCOMANUNCIO");
  