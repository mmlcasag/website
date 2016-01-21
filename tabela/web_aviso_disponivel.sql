/*-- armazena os dados para avisar quando um produto esta disponivel
-- 500 registros por mes

  CREATE TABLE "WEBSITE"."WEB_AVISO_DISPONIVEL" 
   (	"NOME" VARCHAR2(100 BYTE), 
	"EMAIL" VARCHAR2(100 BYTE), 
	"ITEM" VARCHAR2(20 BYTE), 
	"DATA_LIMITE" DATE, 
	"DATA_RETORNO" DATE, 
	"DISPONIVEL" VARCHAR2(1 CHAR), 
	"DATA_PEDIDO" DATE, 
	"CEP" VARCHAR2(8 BYTE), 
	"DEPOSITO" NUMBER,
    CONSTRAINT "WEB_AVISO_DISPONIVEL_PK" PRIMARY KEY ("EMAIL", "ITEM", "DATA_PEDIDO")
   );
   
-- Ajuste para corrigir constraints = Mandelli 08/11
ALTER TABLE web_aviso_disponivel
add codigo number(15)

-- Ajuste das constraints - Mandelli 08/11
ALTER TABLE WEB_AVISO_DISPONIVEL
DROP CONSTRAINT PK_WEB_AVISO_DISPONIVEL; 

ALTER TABLE WEB_AVISO_DISPONIVEL
ADD CONSTRAINT UK_WEB_AVISO_DISPONIVEL UNIQUE 
(
  EMAIL 
, ITEM 
)
ENABLE;

-- Ajuste das constraints - Mandelli 08/11

ALTER TABLE WEB_AVISO_DISPONIVEL
DROP CONSTRAINT UK_WEB_AVISO_DISPONIVEL UNIQUE;


ALTER TABLE WEB_AVISO_DISPONIVEL
ADD CONSTRAINT UK_WEB_AVISO_DISPONIVEL UNIQUE
(
  EMAIL
, ITEM
)
ENABLE;

-- REMOCAO DE INDICE - THIAGO 20/12/2012 - EXISTE OUTRO INDICE PK PARA A TABELA
alter table web_aviso_disponivel
drop index WEB_AVISO_DISPONIVEL_PK;
*/
-- Mandelli Incusão da data de Cadastro - 2013
ALTER TABLE web_aviso_disponivel
add dt_cadastro date default sysdate;

-- Aquiles CWI - inclusao de flag de envio para Responsys 29/08/2014
alter table WEB_AVISO_DISPONIVEL
add FL_ENVIADO_RESPONSYS varchar2(1) default 'N';