CREATE TABLE "WEBSITE"."WEB_INTEGR_PORTAL_CAMPO"
  (
    "COD"        NUMBER NOT NULL ENABLE,
    "COD_PORTAL" NUMBER(*,0) NOT NULL ENABLE,
    "COD_CAMPO"  NUMBER(*,0) NOT NULL ENABLE,
    "TAG_CAMPO"  VARCHAR2(30 BYTE) NOT NULL ENABLE,
    "TAG1"       VARCHAR2(30 BYTE),
    "TAG2"       VARCHAR2(30 BYTE),
    "TAGS"       VARCHAR2(80 BYTE),
    FOREIGN KEY ("COD_PORTAL") REFERENCES "WEBSITE"."WEB_INTEGR_PORTAL" ("COD") ENABLE,
    FOREIGN KEY ("COD_CAMPO") REFERENCES "WEBSITE"."WEB_INTEGR_CAMPO" ("COD") ENABLE,
    PRIMARY KEY ("COD") );