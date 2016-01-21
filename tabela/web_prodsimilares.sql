--
-- Armazena os produtos similares para os produtos do site
--

  CREATE TABLE WEB_PRODSIMILARES 
   (	"CODPROD" NUMBER(6,0), 
	"CODSIMILAR" NUMBER(6,0), 
	 CONSTRAINT "web_prodSimilares_PK" PRIMARY KEY ("CODPROD", "CODSIMILAR"), 
	 CONSTRAINT "web_codSimilar_prod_FK" FOREIGN KEY ("CODPROD")
	  REFERENCES "WEBSITE"."WEB_PROD" ("CODPROD") ENABLE,
         CONSTRAINT "web_codSimilar_similar_FK" FOREIGN KEY ("CODSIMILAR")
	  REFERENCES "WEBSITE"."WEB_PROD" ("CODPROD") ENABLE);
   
alter table web_prodsimilares add flautomatico varchar2(1) default 'S' not null;
