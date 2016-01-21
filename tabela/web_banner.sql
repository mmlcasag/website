/*--
-- Armazena os banners da loja virtual
-- 30 registros no total
--
  CREATE TABLE "WEBSITE"."WEB_BANNER" 
   (	"CODBANNER" NUMBER(6,0) NOT NULL ENABLE, 
	"DESCRICAO" VARCHAR2(30 BYTE), 
	"IMAGEM" VARCHAR2(200 BYTE), 
	"LINK" VARCHAR2(200 BYTE), 
	"DTINICIO" DATE NOT NULL ENABLE, 
	"DTFIM" DATE NOT NULL ENABLE, 
	"ORDEM" NUMBER(2,0), 
	"USERALTER" VARCHAR2(20 BYTE), 
	"DTALTER" DATE, 
	"LARGURA" VARCHAR2(4 BYTE), 
	"ALTURA" VARCHAR2(4 BYTE), 
	"TPBANNER" NUMBER(2,0) NOT NULL ENABLE, 
	"SCRIPT" LONG, 
	 CONSTRAINT "WEB_BANNER_PK" PRIMARY KEY ("CODBANNER") ENABLE, 
	 CONSTRAINT "WEB_BANNER_FK_TPBANNER" FOREIGN KEY ("TPBANNER")
	  REFERENCES "WEBSITE"."WEB_TPBANNER" ("CODBANNER") ENABLE
   ) ;

-- 20/11/2006 - Lucas - campo transparent para utilizar no script do flash
ALTER TABLE WEB_BANNER ADD ("TRANSPARENT" CHAR(1) DEFAULT 'S');

-- 30/01/2008 - Lucas - campo script varchar por causa do big no driver oracle para java
ALTER TABLE WEB_BANNER ADD ("SCRIPTS" VARCHAR2(4000));

-- 08/08/2008 - Mário - Campos para cadastro de banners em linha, família e grupo - projeto 1539
alter table WEB_BANNER add(CODLINHA NUMBER(6,0));
alter table WEB_BANNER add(CODFAM NUMBER(6,0));
alter table WEB_BANNER add(CODGRUPO NUMBER(6,0));
alter table WEB_BANNER add(FL_ATIVO VARCHAR2(1) DEFAULT 'S' NOT NULL);
alter table WEB_BANNER add(FL_EXCLUSIVO VARCHAR2(1) DEFAULT 'N' NOT NULL );
alter table WEB_BANNER add(PERIODICIDADE NUMBER(1) DEFAULT 0);

--06/06/2009 - Thiago - campo para tema do site colombo premium
alter table web_banner
add theme varchar(50);

--04/12/2012 - Thiago - aumentado o tamanho do campo link
alter table web_banner
modify link varchar2(255);

--22/02/2013 - Joao - campo para texto alternativo, para quando não houver flash instalado
alter table web_banner add alternativo varchar2(4000);
*/
--01/04/2014 - Mandelli - Aumento do campo LINK
alter table web_banner modify link varchar2(2000);