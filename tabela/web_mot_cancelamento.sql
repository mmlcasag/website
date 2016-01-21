
CREATE TABLE WEB_MOT_CANCELAMENTO
   (COD_MOT_CANCELAMENTO NUMBER(10,0) NOT NULL PRIMARY KEY, 
	DESCR VARCHAR2(40 BYTE) NOT NULL, 
	ATIVO VARCHAR2(1 BYTE));
 
grant all on web_mot_cancelamento to lvirtual;

insert into website.web_mot_cancelamento values (1, 'Cancelamento automático pelo Sistema', 'S');
