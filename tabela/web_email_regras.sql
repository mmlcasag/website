-- Tabela para armazenar as regras de verificacao de emails
-- 50 registros total 
-- Bruno - 30/08/2007
/*
  CREATE TABLE "WEBSITE"."WEB_EMAIL_REGRAS" 
   (	"ERRADO" VARCHAR2(4000 BYTE), 
	"CERTO" VARCHAR2(4000 BYTE), 
	"ORDEM" NUMBER(6,0)
   );
*/

-- Thiago Rudzewicz 12/07/2012
alter table web_email_regras 
drop primary key;

alter table web_email_regras 
add  codigo number(10);

-- sql para inicializar a nova pk
  declare 
    cursor cr is
            select rowid ident
              from web_email_regras;
    v_cont  number(10) := 1;
    
  begin
    for c1 in cr
      loop
        update web_email_regras
           set codigo = v_cont
          where rowid = c1.ident;
          v_cont := v_cont + 1;
      end loop;
      commit;
  end;
  
drop index WEB_EMAIL_REGRAS_PK ;

alter table web_email_regras
add constraint web_email_regras_pk primary key (codigo);