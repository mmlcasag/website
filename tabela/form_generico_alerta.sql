/*
CREATE TABLE "WEBSITE"."FORM_GENERICO_ALERTA" 
(	"CODIGO" NUMBER(10,0), 
	"ALERTA" NUMBER(10,0), 
	"ATRIBUTO1" VARCHAR2(250 BYTE), 
	"ATRIBUTO2" VARCHAR2(250 BYTE), 
	"ATRIBUTO3" VARCHAR2(250 BYTE), 
	"ATRIBUTO4" VARCHAR2(250 BYTE), 
	"ATRIBUTO5" VARCHAR2(250 BYTE), 
	"ATRIBUTO6" VARCHAR2(250 BYTE), 
	"ATRIBUTO7" VARCHAR2(250 BYTE), 
	"ATRIBUTO8" VARCHAR2(250 BYTE), 
	"ATRIBUTO9" VARCHAR2(250 BYTE), 
	"ATRIBUTO10" VARCHAR2(250 BYTE)
);
*/
 
alter table form_generico_alerta add constraint pk_form_generico_alerta primary key (codigo);