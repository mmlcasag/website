/*
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	Autor: Jucemar Vaccaro
	Data: 06/10/2008
	Estimativa de registros: 50 / mês
	OWNER: WEBSITE

 CREATE TABLE WEB_PROD_VENDA_AGREGADA (
  PVA_ID NUMBER(11) NOT NULL,
  GRP_COD_GRUPO NUMBER(10) DEFAULT NULL,
  ITM_ID NUMBER(10),
  ITM_ID_AGREGADO NUMBER(10),
  USER_INC VARCHAR2(255),
  USER_ALT VARCHAR2(255),
  PVA_FL_ATIVO CHAR(1) DEFAULT 'N',  
  PVA_DT_CADASTRO DATE,
  PRIMARY KEY(PVA_ID),
  CONSTRAINT WEB_GRUPO_FK FOREIGN KEY(GRP_COD_GRUPO)
   REFERENCES WEB_GRUPO(CODGRUPO),
  CONSTRAINT WEB_ITPROD_FK1 FOREIGN KEY(ITM_ID)
   REFERENCES WEB_ITPROD(CODITPROD),
  CONSTRAINT WEB_ITPROD_FK2 FOREIGN KEY(ITM_ID_AGREGADO)
   REFERENCES WEB_ITPROD(CODITPROD)
);

CREATE SEQUENCE WEB_PROD_VENDA_AGREG_ID_SEQ INCREMENT BY 1;

------------------------------------

alter table  web_prod_venda_agregada add fl_inversao char(1) default 'S';

-- projeto de produtos virtuais
alter table web_prod_venda_agregada add pva_fl_lista_site char(1) default 'S' not null;
alter table web_prod_venda_agregada add pva_descricao_url varchar2(250);
alter table web_prod_venda_agregada add pva_descricao_title varchar2(250);
*/
-- Aquiles CWI 20/11/13 projeto de quantidade de itens dos brindes
alter table web_prod_venda_agregada add qnt_item number(2) default 1;