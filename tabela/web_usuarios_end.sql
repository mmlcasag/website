/*--
-- Armazena os enderecos de entrega que o cliente jah utilizou
-- 500 registros / mes
--
  CREATE TABLE "WEBSITE"."WEB_USUARIOS_END" 
   (	"CODCLILV" NUMBER(15,0) NOT NULL ENABLE, 
	"CODENDLV" NUMBER(6,0) NOT NULL ENABLE, 
	"ENDERECO" VARCHAR2(40 BYTE), 
	"NUMERO" NUMBER(6,0), 
	"COMPLEMENTO" VARCHAR2(20 BYTE), 
	"BAIRRO" VARCHAR2(30 BYTE), 
	"CIDADE" VARCHAR2(60 BYTE), 
	"UF" CHAR(2 BYTE), 
	"CEP" NUMBER(8,0), 
	"REFERENCIA" VARCHAR2(150 BYTE), 
	"DDDRESID" NUMBER(2,0), 
	"FONERESID" NUMBER(10,0), 
	"RAMALRESID" NUMBER(5,0), 
	"DDDCOML" NUMBER(2,0), 
	"FONECOML" NUMBER(10,0), 
	"RAMALCOML" NUMBER(5,0), 
	"DDDCELUL" NUMBER(2,0), 
	"FONECELUL" NUMBER(10,0), 
	"DTCADAST" DATE, 
	"FLSITE" CHAR(1 BYTE), 
	"FLTELE" CHAR(1 BYTE), 
	 CONSTRAINT "WEB_USUARIOS_END_PK" PRIMARY KEY ("CODCLILV", "CODENDLV") ENABLE
   ) ;

-- 06/08/2007 - Lucas - Alteracao Store in Store
ALTER TABLE WEB_USUARIOS_END RENAME COLUMN "FLSITE" TO "FLATIVO" ;
ALTER TABLE WEB_USUARIOS_END DROP COLUMN "FLTELE";

--02/05/2012 - Aquiles - Adicao de campos para novo layout dos enderecos
ALTER TABLE WEB_USUARIOS_END ADD ("NOME" VARCHAR2(60));
ALTER TABLE WEB_USUARIOS_END ADD ("DESTINATARIO" VARCHAR2(100));

--02/05/2012 - Mandelli - Incluido campo para salvar os responsaveis pelo recebimento da encomenda
ALTER TABLE web_usuarios_end
ADD autorizados_recebimento VARCHAR2(60);
*/

--14/10/2014 - Mandelli - Sincronizar tamanho do campo com cad_endcli
/*
ALTER TABLE WEB_USUARIOS_END
MODIFY ENDERECO VARCHAR2(108);
*/

ALTER TABLE WEB_USUARIOS_END MODIFY BAIRRO VARCHAR2(65);

--23/04/2015 - Gabriel - Incluido campo para identificar quando o endereço é de uma lista de casamento
ALTER TABLE WEB_USUARIOS_END ADD (CODIGO_WEB_NOIVAS NUMBER(6));