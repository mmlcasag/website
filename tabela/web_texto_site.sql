-- Criado por: Márcio
-- Data: 09/07/2008
-- Previsão de registros: máximo 50
-- Utilizado aonde: site (detalheProduto.do)
-- Comentário: Tabela que conterá textos dinâmicos para o Site 

CREATE TABLE "WEBSITE"."WEB_TEXTO_SITE" (
	"CODIGO" NUMBER(5,0) NOT NULL ENABLE, 
	"DESCRICAO" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"MENSAGEM" VARCHAR2(2000 BYTE), 
	"FL_POLITICAS_FRETE" VARCHAR2(1 BYTE) NOT NULL ENABLE, 
	CONSTRAINT "WEB_TEXTO_SITE_PK" PRIMARY KEY ("CODIGO")
);

-- ATRIBUIÇÃO DE PRIVILÉGIOS --
GRANT ALL ON "WEBSITE"."WEB_TEXTO_SITE" TO lvirtual;

-- INICIALIZAÇÃO DE DADOS --
INSERT INTO web_texto_site (codigo,descricao,mensagem,fl_politicas_frete) VALUES (1,'DEFINIÇÃO DAS POLÍTICAS DE FRETE','DEFINIÇÃO DAS POLÍTICAS DE FRETE','S');


-- Projeto 1534 de 29/07/2008
-- Marcio Casagrande

alter table website.web_texto_site modify(mensagem varchar2(4000));
