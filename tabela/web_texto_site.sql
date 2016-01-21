-- Criado por: M�rcio
-- Data: 09/07/2008
-- Previs�o de registros: m�ximo 50
-- Utilizado aonde: site (detalheProduto.do)
-- Coment�rio: Tabela que conter� textos din�micos para o Site 

CREATE TABLE "WEBSITE"."WEB_TEXTO_SITE" (
	"CODIGO" NUMBER(5,0) NOT NULL ENABLE, 
	"DESCRICAO" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"MENSAGEM" VARCHAR2(2000 BYTE), 
	"FL_POLITICAS_FRETE" VARCHAR2(1 BYTE) NOT NULL ENABLE, 
	CONSTRAINT "WEB_TEXTO_SITE_PK" PRIMARY KEY ("CODIGO")
);

-- ATRIBUI��O DE PRIVIL�GIOS --
GRANT ALL ON "WEBSITE"."WEB_TEXTO_SITE" TO lvirtual;

-- INICIALIZA��O DE DADOS --
INSERT INTO web_texto_site (codigo,descricao,mensagem,fl_politicas_frete) VALUES (1,'DEFINI��O DAS POL�TICAS DE FRETE','DEFINI��O DAS POL�TICAS DE FRETE','S');


-- Projeto 1534 de 29/07/2008
-- Marcio Casagrande

alter table website.web_texto_site modify(mensagem varchar2(4000));
