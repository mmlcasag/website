-- armazena os curriculos
-- 100 registros por dia

  CREATE TABLE WEB_CONTRATO_BRADESCO
   (	CODFIL NUMBER(3,0), 
	NUMCONTRAFIN NUMBER(9,0), 
	DIGCONTRAFIN NUMBER(1,0), 
	DESDTIT CHAR(2 BYTE), 
	NOSSONRO NUMBER(11,0), 
	DATABOLETO DATE, 
	FLPROC NUMBER(1,0), 
	PRIMARY KEY (NOSSONRO));