/*
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	Autor: Jucemar Vaccaro
	Data: 01/09/2008
	Estimativa de registros: 5.000 mês
	OWNER: WEBSITE
*/

CREATE TABLE web_prod_avaliacoes (
  pav_id NUMBER(10) NOT NULL,
  usu_id NUMBER(10) NOT NULL,
  prd_id NUMBER(10) NOT NULL,
  pav_txt_titulo VARCHAR2(255),
  pav_txt_titulo_site VARCHAR2(255),
  pav_ds_avaliacao VARCHAR2(4000),
  pav_ds_avaliacao_site VARCHAR2(4000),
  pcl_id NUMBER(10) DEFAULT '4';
  pav_dt_cadastro DATE,
  pav_user_avaliador VARCHAR2(255),
  pav_dt_avaliada DATE,  
  pav_fl_aprovada VARCHAR(1) DEFAULT 'N',  
  CONSTRAINT PAV_PK PRIMARY KEY(pav_id),
  CONSTRAINT WEB_USUARIOS_FK FOREIGN KEY(usu_id)
	REFERENCES WEB_USUARIOS(codclilv),
  CONSTRAINT WEB_PROD_FK FOREIGN KEY(prd_id)
	REFERENCES WEB_PROD(codprod),
  CONSTRAINT WEB_PROD_ClASS_FK FOREIGN KEY(pcl_id)
	REFERENCES WEB_PROD_CLASSIFICACOES(pcl_id)	
);

CREATE SEQUENCE prod_avalicaoes_id_sequence  INCREMENT BY 1;



pav_num_nota


alter table WEB_PROD_AVALIACOES add PAV_PEDIDO number(10,0);

--cesaraugusto - 28/04/2015 - Avaliações 2.0
alter TABLE WEB_PROD_AVALIACOES
add (
	FL_RECOMENDARIA char(1)
);
alter TABLE WEB_PROD_AVALIACOES
add (
	UTIL decimal(10,0),
	INUTIL decimal(10,0)
);