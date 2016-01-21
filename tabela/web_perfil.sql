--
-- Armazena os perfis de acesso do site
-- 10 registros total
--
/*
  CREATE TABLE "WEBSITE"."WEB_PERFIL" 
   (	"CODIGO" NUMBER(3,0) NOT NULL ENABLE, 
	"DESCRICAO" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"PESQUISA_PEDIDOS_FILIAL" CHAR(1 BYTE) DEFAULT 'N' NOT NULL ENABLE, 
	"ALTERA_ENTREGA_PEDIDO" CHAR(1 BYTE) DEFAULT 'N' NOT NULL ENABLE, 
	"ALTERA_PAGAMENTO_PEDIDO" CHAR(1 BYTE) DEFAULT 'N' NOT NULL ENABLE, 
	"CANCELA_PEDIDO" CHAR(1 BYTE) DEFAULT 'N' NOT NULL ENABLE, 
	"CADASTRA_VENDEDOR" CHAR(1 BYTE) DEFAULT 'N' NOT NULL ENABLE, 
	"CADASTRA_CLIENTE" CHAR(1 BYTE) DEFAULT 'N' NOT NULL ENABLE, 
	"VENDE_SEM_ESTOQUE" CHAR(1 BYTE) DEFAULT 'N' NOT NULL ENABLE, 
	"FRETE_GRATIS" CHAR(1 BYTE) DEFAULT 'N' NOT NULL ENABLE, 
	"VENDE_BOLETO" CHAR(1 BYTE) DEFAULT 'N' NOT NULL ENABLE, 
	"VENDE_CREDITO" CHAR(1 BYTE) DEFAULT 'N' NOT NULL ENABLE, 
	"VENDE_DEBITO" CHAR(1 BYTE) DEFAULT 'N' NOT NULL ENABLE, 
	"VENDE_CARNE" CHAR(1 BYTE) DEFAULT 'N' NOT NULL ENABLE, 
	"VENDE_MARGEM_INFERIOR" CHAR(1 BYTE) DEFAULT 'N' NOT NULL ENABLE, 
	"CONFIRMA_VENDA" CHAR(1 BYTE) DEFAULT 'N' NOT NULL ENABLE, 
	"FILIAL_VENDA" NUMBER(3,0) NOT NULL ENABLE, 
	"EXIBE_TODOS_PLANOS" CHAR(1 BYTE) DEFAULT 'N' NOT NULL ENABLE, 
	"EXIBE_TODOS_ITENS" CHAR(1 BYTE) DEFAULT 'N' NOT NULL ENABLE, 
	"VENDE_DESATIVADO" CHAR(1 BYTE) DEFAULT 'N' NOT NULL ENABLE, 
	"ALTERA_PRECO_PRODUTO" CHAR(1 BYTE) DEFAULT 'N' NOT NULL ENABLE, 
	"LOGOTIPO" VARCHAR2(200 BYTE), 
	 CONSTRAINT "WEB_PERFIL_PK" PRIMARY KEY ("CODIGO")
  USING INDEX 
   );
 
-- 16/08/2007 - Lucas - novas flags
ALTER TABLE WEB_PERFIL ADD ("EXIBE_LOGOUT" CHAR(1) DEFAULT 'S' NOT NULL);
ALTER TABLE WEB_PERFIL ADD ("PATH_IMAGENS_WINDOWS" VARCHAR2(200));
ALTER TABLE WEB_PERFIL ADD ("PATH_IMAGENS_LINUX" VARCHAR2(200));
ALTER TABLE WEB_PERFIL ADD ("DESCONTO_PARCELA_MARGEM" NUMBER(15, 4) DEFAULT 0 NOT NULL);

-- 30/11/2007 - Lucas - pasta onde fica armazenado layout do topo
ALTER TABLE WEB_PERFIL ADD ("PATH_TOPO" VARCHAR2(50));

-- 05/06/2007 - Thiago - campos novos para Store in Store
alter table web_perfil add vende_boleto_prazo char(1);
alter table web_perfil add resolucao char(1);

-- 21/12/2010 - Mandelli - meta loja física
alter table web_perfil
add LOJA_FISICA char(1) default 'N'

-- 10/10/2012 - Mandelli - define qual mecanismo de busca cada perfil utiliza (GCS)
ALTER TABLE web_perfil
add search_engine number(1);*/

-- 26/08/2013 - Mandelli - inclusão de campo para estoque
/*
ALTER TABLE web_perfil
add exibe_consulta_estoque char(1) default 'N';

update web_perfil set exibe_consulta_estoque = 'S' where codigo = 3; -- Inicialização

ALTER TABLE web_perfil
ADD exibe_estoque_lojas char(1) DEFAULT 'N';

update web_perfil set exibe_estoque_lojas = 'S' where codigo = 3; -- Inicialização
*/

-- Projeto Site na Nuvem
GRANT SELECT, REFERENCES ON website.web_perfil TO colombo;

-- Projeto Retira Loja
alter table web_perfil
add fl_utiliza_retira_loja char(1);

update web_perfil
set FL_UTILIZA_RETIRA_LOJA = 'T'
where codigo in (0, 2, 3, 4, 5);

update web_perfil
set FL_UTILIZA_RETIRA_LOJA = 'S'
where codigo in (1);

alter table web_perfil
add prz_max_venc_boleto number(2);
