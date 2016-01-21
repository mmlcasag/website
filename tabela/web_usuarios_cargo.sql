--
-- Armazena os usuarios cadastrados no site
-- 1000 registros / mes
--
  CREATE TABLE "WEBSITE"."WEB_USUARIOS_CARGO" 
   (	"USUARIO" NUMBER(15,0), 
	"CARGO" NUMBER(6,0), 
	"PROFISSAO" NUMBER(6,0), 
	"ORIGEM" VARCHAR2(1 BYTE), 
	"FUN_PRONT" NUMBER(6,0), 
	 PRIMARY KEY ("USUARIO"))