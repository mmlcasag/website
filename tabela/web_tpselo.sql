--
-- Tipos de Selos dos produtos
-- 10 registros total
--

  CREATE TABLE "WEBSITE"."WEB_TPSELO" 
   (	"CODIGO" NUMBER(3,0) NOT NULL ENABLE, 
	"DESCRICAO" VARCHAR2(30 BYTE) NOT NULL ENABLE, 
	 CONSTRAINT "WEB_TPSELO_PK" PRIMARY KEY ("CODIGO")
   );