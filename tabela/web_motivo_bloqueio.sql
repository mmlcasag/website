  
  CREATE TABLE "WEBSITE"."WEB_MOTIVO_BLOQUEIO" 
   (	"COD" NUMBER(10,0) NOT NULL, 
	"FLTIPO" CHAR(1 BYTE) NOT NULL, 
	"DESCR" VARCHAR2(80 BYTE) NOT NULL, 
	"FLATIVO" CHAR(1 BYTE), 
	 PRIMARY KEY ("COD")
    );
 