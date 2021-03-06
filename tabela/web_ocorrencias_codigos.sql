-- TABELA QUE ARMAZENA OS C�DIGOS DAS OCORRENCIAS DAS TRANSPORTADORAS.
-- REGISTROS: - EM TORNO DE 100.
-- Rodrigo Mandelli

CREATE TABLE "WEBSITE"."WEB_OCORRENCIAS_CODIGOS" 
("CODIGO" NUMBER(4) NOT NULL, 
"DESCRICAO" VARCHAR2(255) NOT NULL, 
"DESC_CLIENTE" VARCHAR2(255), 
"FL_ATIVO" VARCHAR2(1) DEFAULT 'N', 
 CONSTRAINT "CK_WEB_RET_FLAG" CHECK (fl_ativo in ('S','N')), 
 CONSTRAINT "PK_WEB_RET_CODIGO" PRIMARY KEY ("CODIGO")
)
