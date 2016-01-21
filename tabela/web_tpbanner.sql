-- tabela para os tipos de banners - 26/07/2009
/*CREATE TABLE "WEBSITE"."WEB_TPBANNER"
  (
    "DESCRICAO" VARCHAR2(40 BYTE),
    "CODBANNER" NUMBER(2,0) NOT NULL ENABLE,
    CONSTRAINT "WEB_TPBANNER_PK" PRIMARY KEY ("CODBANNER") USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS STORAGE(INITIAL 40960 NEXT 40960 MINEXTENTS 1 MAXEXTENTS 505 PCTINCREASE 50 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT) TABLESPACE "SITE_IDX" ENABLE
  );
*/

-- controle para ativar / desativar tipos de banners - 31/10/2012
alter table web_tpbanner add (
fl_ativo char(1),
constraint ck_tpbanner check (fl_ativo in ('S','N')));

update web_tpbanner
set fl_ativo = 'S'
where codbanner in (1,10,11,14,16,17,18,19,20,21,22);

update web_tpbanner
set fl_ativo = 'N'
where codbanner not in (1,10,11,14,16,17,18,19,20,21,22);

--cwi_cesar 13/02/2015 Novo Banner parte 2
ALTER TABLE WEB_TPBANNER 
ADD (FL_ATIVO_SLIDER char(1));

update WEB_TPBANNER set FL_ATIVO_SLIDER = 'N';
update WEB_TPBANNER set FL_ATIVO_SLIDER = 'S' where DESCRICAO in ('Novo Super-Banner','Novo Banner','Tarja');