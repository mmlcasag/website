CREATE TABLE "WEBSITE"."WEB_PROD_HTML"
  (
    "CODHTML" NUMBER(6,0) NOT NULL ENABLE,
    "HTML" CLOB,
    "CODPROD" NUMBER(6,0),
    CONSTRAINT "WEB_PROD_HTML_PK" PRIMARY KEY ("CODHTML") ENABLE,
    CONSTRAINT "WEB_PROD_FK" FOREIGN KEY ("CODPROD") REFERENCES "WEBSITE"."WEB_PROD" ("CODPROD") ENABLE
  )