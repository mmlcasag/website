/*  CREATE TABLE "WEBSITE"."WEB_ITPROD_BRINDE_ITENS" 
   ("COD_BRINDE" NUMBER(10,0), 
	"COD_ITPROD" NUMBER(10,0), 
	"VALOR" NUMBER(10,2), 
	"VALOR_BOLETO" NUMBER(10,2), 
	 PRIMARY KEY ("COD_BRINDE", "COD_ITPROD"),
        CONSTRAINT "FK_COD_BRINDE" FOREIGN KEY ("COD_BRINDE")
	  REFERENCES "WEBSITE"."WEB_ITPROD_BRINDE" ("COD_BRINDE") ENABLE, 
	 CONSTRAINT "FK_CODITPROD" FOREIGN KEY ("COD_ITPROD")
	  REFERENCES "WEBSITE"."WEB_ITPROD" ("CODITPROD") ENABLE) ;

-- Aquiles CWI 20/11/13 projeto de quantidade de itens dos brindes
alter table web_itprod_brinde_itens add qnt_item number(2) default 1;
*/

alter table web_itprod_brinde_itens add constraint pk_web_itprod_brinde_itens primary key (cod_brinde, cod_itprod);