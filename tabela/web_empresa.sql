--
-- Armazena os nomes de empresas para o site
-- 1000 registros no total
--
/*
  CREATE TABLE "WEBSITE"."WEB_EMPRESA" 
   (	"CODEMPRESA" NUMBER(6,0) NOT NULL ENABLE, 
	"DESCRICAO" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	 CONSTRAINT "PK_WEB_EMPRESA" PRIMARY KEY ("CODEMPRESA") ENABLE
   ) ;

-- 01/06/2006 - Lucas - Alteracao de campos para o sistema do televendas
ALTER TABLE WEB_EMPRESA ADD ("IMGDEMO" VARCHAR2(200 BYTE));
ALTER TABLE WEB_EMPRESA ADD ("IMGASSIST" VARCHAR2(200 BYTE));
ALTER TABLE WEB_EMPRESA ADD ("LARGURADEMO" NUMBER(4,0));
ALTER TABLE WEB_EMPRESA ADD ("ALTURADEMO" NUMBER(4,0));
ALTER TABLE WEB_EMPRESA ADD ("LARGURAASSIST" NUMBER(4,0));
ALTER TABLE WEB_EMPRESA ADD ("ALTURAASSIST" NUMBER(4,0));
ALTER TABLE WEB_EMPRESA ADD ("LINKASSIST" VARCHAR2(200 BYTE));

-- 25/10/2006 - Lucas - Retirados links dos assistentes
ALTER TABLE WEB_EMPRESA DROP COLUMN "IMGASSIST";
ALTER TABLE WEB_EMPRESA DROP COLUMN "LARGURAASSIST";
ALTER TABLE WEB_EMPRESA DROP COLUMN "ALTURAASSIST";
ALTER TABLE WEB_EMPRESA DROP COLUMN "LINKASSIST";

-- 07/06/2013 - Joaop - Inclusão dados fornecedor
alter table web_empresa add ddd varchar2(4);
alter table web_empresa add fone varchar2(14);
alter table web_empresa add site varchar2(100);
alter table web_empresa add exibecontato char(1);
*/

alter table web_empresa
add descricao_original VARCHAR2(50);

update web_empresa set descricao_original = descricao;