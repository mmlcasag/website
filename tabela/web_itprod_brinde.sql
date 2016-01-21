/*    CREATE TABLE "WEBSITE"."WEB_ITPROD_BRINDE" 
   ("COD_BRINDE" NUMBER(10,0), 
	"COD_ITPROD_PRINCIPAL" NUMBER(10,0), 
	"VALOR" NUMBER(10,2), 
	"VALOR_BOLETO" NUMBER(10,2), 
	"FL_ATIVO" CHAR(1 BYTE), 
	"DTINICIO" DATE,
	"DTFIM" DATE,
	"USERALTER" VARCHAR2(20 BYTE),
	"DTALTER" DATE,
	"MELHORPLANO" VARCHAR2(3 BYTE),
	FOREIGN KEY ("MELHORPLANO") REFERENCES "WEBSITE"."WEB_PLANO" ("CODPLANO") ENABLE	 	
	PRIMARY KEY ("COD_BRINDE"))

-- projeto de produtos virtuais
alter table web_itprod_brinde add fl_lista_site char(1) default 'S' not null;
alter table web_itprod_brinde add descricao_url varchar2(250);
alter table web_itprod_brinde add descricao_title varchar2(250);

alter table "WEB_ITPROD_BRINDE" add ( "LIMITE_VENDAS" NUMBER (10,0) );
alter table "WEB_ITPROD_BRINDE" add ( "QUANTIDADE_VENDIDA" NUMBER (10,0) );
*/
-- Aquiles CWI 20/11/13 projeto de quantidade de itens dos brindes
alter table "WEB_ITPROD_BRINDE" add qnt_item number(2,0) default 1;