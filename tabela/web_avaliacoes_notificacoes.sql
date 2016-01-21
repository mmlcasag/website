/*
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	Autor: Jucemar Vaccaro
	Data: 01/09/2008
	Estimativa de registros: 10
	OWNER: WEBSITE
*/

CREATE TABLE web_avaliacoes_notificacoes (
  avn_id NUMBER(10) NOT NULL,
  avn_txt_nome VARCHAR2(255),
  avn_txt_email VARCHAR2(255),
  avn_num_qtde_avaliacoes NUMBER(5),
  CONSTRAINT AVN_PK PRIMARY KEY(avn_id)
);