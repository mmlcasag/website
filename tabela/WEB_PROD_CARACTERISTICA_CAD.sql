CREATE TABLE WEB_PROD_CARACTERISTICA_CAD
(
	PCAR_ID decimal(10,0) PRIMARY KEY NOT NULL,
	PTPC_ID decimal(10,0),
	DESCRICAO varchar2(255),
	CODLINHA decimal(6,0),
   	CODFAM decimal(6,0),
   	CODGRUPO decimal(6,0),
	CODPROD decimal(6,0),
	FL_ATIVO char(1)
	CONSTRAINT FK_CAD_PTPC_ID FOREIGN KEY(PTPC_ID) REFERENCES WEB_PROD_TP_CARACTERISTICA(PTPC_ID)
);
CREATE SEQUENCE WEB_PROD_CARACT_CAD_SEQ
 START WITH     1
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;