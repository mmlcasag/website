--
-- Armazena os emails de newsletter enviados
-- 100 registros por ano
--

  CREATE TABLE "WEBSITE"."WEB_MAIL_MARKETING" 
   (	"CODIGO" NUMBER(6,0) NOT NULL ENABLE, 
	"ASSUNTO" VARCHAR2(100 BYTE), 
	"DTCADASTRO" DATE, 
	"DTENVIO" DATE, 
	"ARQUIVO" VARCHAR2(255 BYTE), 
	"SEXO" CHAR(1 BYTE), 
	"DTNASC1" DATE, 
	"DTNASC2" DATE, 
	"STATUS" CHAR(1 BYTE), 
	"NROEMAILS" NUMBER(6,0), 
	"CAMPANHA" VARCHAR2(20 BYTE), 
	 CONSTRAINT "PK_WEB_MAIL_MARKETING" PRIMARY KEY ("CODIGO")
  USING INDEX
   );
  
-- 17/08/2007 - Peterson - Campos retirados para o novo sistema de envio de newsletter
ALTER TABLE WEB_MAIL_MARKETING DROP COLUMN "ESTADOS";
ALTER TABLE WEB_MAIL_MARKETING DROP COLUMN "CIDADES";