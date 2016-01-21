  CREATE TABLE "WEBSITE"."WEB_FALECONOSCO" 
   (	"DATA" TIMESTAMP (6) NOT NULL ENABLE, 
	"EMAIL" VARCHAR2(100 BYTE) NOT NULL ENABLE, 
        "ASSUNTO" VARCHAR2(100 BYTE), 
        "NOME" VARCHAR2(100 BYTE), 
	"SEXO" VARCHAR2(1 BYTE), 
	"FONE" VARCHAR2(50 BYTE), 
	"LOCAL" VARCHAR2(100 BYTE), 
	"MENSAGEM" VARCHAR2(4000 BYTE), 
	 CONSTRAINT "WEB_FALECONOSCO_PK" PRIMARY KEY ("DATA", "EMAIL") USING INDEX
   );

alter table web_faleconosco
add codigo number(10);

create sequence web_faleconosco_seq
increment by 1
start with 1                        --verificar onde começa a sequence

---------------------------------------------------------------------------------------------------

alter table web_faleconosco
drop constraint web_faleconosco_pk

create index web_faleconosco_idx
on web_faleconosco(data asc, email desc);

ALTER TABLE web_faleconosco
add CONSTRAINT web_faleconosco_pk PRIMARY KEY(codigo)