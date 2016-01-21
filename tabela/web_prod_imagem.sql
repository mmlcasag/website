/*CREATE TABLE "WEBSITE"."WEB_PROD_IMAGEM"
  (
    "CODIMG"  NUMBER(10,0) NOT NULL ENABLE,
    "CODPROD" NUMBER(6,0),
    "PATH"    VARCHAR2(500 BYTE),
    "ORDEM"   NUMBER(2,0),
    "TIPO"    VARCHAR2(3 BYTE) NOT NULL ENABLE,
    CONSTRAINT "WEB_PROD_IMAGEM_PK" PRIMARY KEY ("CODIMG"),
    CONSTRAINT "WEB_PROD_IMAGEM_WEB_PROD_FK1" FOREIGN KEY ("CODPROD") REFERENCES "WEBSITE"."WEB_PROD" ("CODPROD") ENABLE
  );

-- 27/12/2012 Aquiles B. da Silva
alter table 
   WEBSITE.WEB_PROD_IMAGEM
add (
      CODITPROD   number(10,0)
    );
alter table WEBSITE.WEB_PROD_IMAGEM
  add constraint WEB_PROD_IMAGEM_WEB_ITPROD foreign key (CODITPROD)
  references WEBSITE.WEB_ITPROD (CODITPROD);   
  
 --25/04/2012 Thiago
alter table web_prod_imagem
modify ordem number(2) default 0;

-- inclusão campo de titulo
alter table web_prod_imagem add titulo varchar2(80);

-- inclusão campo indicador de zoom*/
alter table web_prod_imagem add flzoom char(1);

-- Aquiles CWI 21/02/2014 - diferenciar imagens cadastradas e de integracoes
ALTER TABLE web_prod_imagem ADD FL_CADASTRO_MANUAL varchar2(1) default 'S';