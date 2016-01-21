/*-- 15 registros por dia

CREATE TABLE "WEBSITE"."WEB_CAMP_PRECO_PRODUTOS" 
   (	CPD_ID NUMBER(10) NOT NULL, 
	CPR_ID NUMBER(10) NOT NULL, 
	PRD_CODPROD NUMBER(6) NOT NULL, 
	CPD_VALOR_ANTIGO NUMBER(15,2),
	CONSTRAINT "WEB_CAMP_PRECO_PRODUTOS_PK" PRIMARY KEY ("CPD_ID"),
        CONSTRAINT "WEB_CPD_FK_WEB_CPR" FOREIGN KEY (CPR_ID) REFERENCES "WEBSITE"."WEB_CAMPANHAS_PRECO" (CPR_ID),
        CONSTRAINT "WEB_CPD_FK_WEB_PROD" FOREIGN KEY (PRD_CODPROD) REFERENCES "WEBSITE"."WEB_PROD" (CODPROD)
);

CREATE SEQUENCE SEQ_ID_WEB_CAMP_PRECO_PRODUTOS INCREMENT BY 1 START WITH 1 ; 

--
-- Alteração para integações e importações automáticas.
-- DESATIVAR TODAS AS TRIGGERS ANTES DE INCLUIR ESTA COLUNA
alter table web_camp_preco_produtos add flg_processa_online varchar2(1) default 'S' not null;*/

alter table web_camp_preco_produtos add (
cpd_qtde_limite_vendas number(4),
cpd_flativo char(1),
constraint ck_flativo check  (cpd_flativo in ('S','N')));

--Aquiles CWI limite itens na venda
alter table web_camp_preco_produtos add cpd_qtd_limite_compra number(3);

--Cesar Augusto Timer 15/7/2015
alter table WEB_CAMP_PRECO_PRODUTOS
add(
	"FL_TIMER_CAMPANHA" CHAR(1) DEFAULT 'S' NOT NULL ENABLE
);

