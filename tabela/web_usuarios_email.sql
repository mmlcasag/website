--
-- Armazena os email para envio da newsletter
-- 1000 registros / mes
--

  CREATE TABLE "WEBSITE"."WEB_USUARIOS_EMAIL" 
   (	"EMAIL" VARCHAR2(100 BYTE) NOT NULL ENABLE, 
	"NOME" VARCHAR2(100 BYTE), 
	"DTNASC" DATE, 
	"SEXO" CHAR(1 BYTE), 
	"FLEMAIL" CHAR(1 BYTE) DEFAULT 'S' NOT NULL ENABLE, 
	"DTALTER" DATE, 
	 CONSTRAINT "WEB_USUARIOS_EMAIL_PK" PRIMARY KEY ("EMAIL")
  USING INDEX
   );

-- Definição Projeto 33
-- Inclusão coluna cod_mkt
  ALTER TABLE WEB_USUARIOS_EMAIL
  ADD cod_mkt number(10);