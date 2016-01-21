CREATE TABLE "WEBSITE"."WEB_PROD_URL"
  (
    "CODURL"    NUMBER(6,0) DEFAULT 1 NOT NULL ENABLE,
    "CODPROD"   NUMBER(6,0) NOT NULL ENABLE,
    "DESCRICAO" VARCHAR2(80 BYTE),
    "URL"       VARCHAR2(100 BYTE),
    "DTALTER" DATE,
    CONSTRAINT "WEB_PROD_URL_PK" PRIMARY KEY ("CODURL") ENABLE, 
    CONSTRAINT "WEB_PROD_URL_WEB_PROD_FK1" FOREIGN KEY ("CODPROD") REFERENCES "WEBSITE"."WEB_PROD" ("CODPROD") ENABLE
  )

 CREATE INDEX "WEBSITE"."WEB_PROD_URL_INDICE_URL" ON "WEBSITE"."WEB_PROD_URL" ("URL");