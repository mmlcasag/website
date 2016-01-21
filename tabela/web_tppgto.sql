--
-- Armazena as formas de pagamento para o site
-- 10 registros no total
--
    CREATE TABLE "WEBSITE"."WEB_TPPGTO" 
   (	"TPPGTO" NUMBER(2,0), 
	"DESCRICAO" VARCHAR2(60 BYTE), 
	"DIAS1PGTO" NUMBER(3,0)
   ) ;

-- 01/06/2006 - Lucas - Alteracao de campos para o sistema do televendas
ALTER TABLE WEB_TPPGTO ADD ("REDUZIDA" VARCHAR2(20));

-- 05/10/2007 - Lucas - Novas colunas para negociacao virtual
ALTER TABLE WEB_TPPGTO ADD ("ENTRADA" VARCHAR2(1) DEFAULT 'N' NOT NULL);
ALTER TABLE WEB_TPPGTO ADD ("DIASPGTO" NUMBER(3) DEFAULT 30 NOT NULL);
ALTER TABLE WEB_TPPGTO ADD ("PRCPADRAO" NUMBER(3) DEFAULT 1 NOT NULL);
ALTER TABLE WEB_TPPGTO ADD ("PRCMINIMA" NUMBER(15,2) DEFAULT 0 NOT NULL);