/*
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	Autor: Jucemar Vaccaro
	Data: 01/10/2008
	Estimativa de registros: 1000 / mês
	OWNER: WEBSITE
*/
 CREATE TABLE web_prod_complementares (
  pco_id NUMBER(11) NOT NULL,
  prd_id_1 NUMBER(10),
  prd_id_2 NUMBER(10),
  pco_fl_cadastro CHAR(1) default 'N',  
  PRIMARY KEY(pco_id)
);

CREATE SEQUENCE web_prod_compl_id_sequence INCREMENT BY 1;