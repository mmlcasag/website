/*CREATE TABLE "WEBSITE"."WEB_INTEGR_PORTAL"
  (
    "COD"          NUMBER(*,0) NOT NULL ENABLE,
    "PORTAL"       VARCHAR2(20 BYTE) NOT NULL ENABLE,
    "FLATIVO"      CHAR(1 BYTE),
    "LISTLINHAS"   VARCHAR2(200 BYTE),
    "LISTFAMILIAS" VARCHAR2(200 BYTE),
    "LISTGRUPOS"   VARCHAR2(200 BYTE),
    "TAG_RAIZ"     VARCHAR2(30 BYTE),
    "TAG_PRODUTO"  VARCHAR2(30 BYTE),
    "LISTEMPRESAS" VARCHAR2(200 BYTE),
    "FLEC"         CHAR(1 BYTE),
    "FLXML"        CHAR(1 BYTE),
    "FLESTOQUE"    CHAR(1 BYTE),
    "BLOCOEXTRA"   VARCHAR2(400 BYTE),
    "SEP_VALOR"    CHAR(1 BYTE),
    "FILTRO"       VARCHAR2(10 BYTE),
    PRIMARY KEY ("COD")
  );

alter table WEB_INTEGR_PORTAL drop column portal;
alter table WEB_INTEGR_PORTAL add portal integer;
alter table WEB_INTEGR_PORTAL add constraint fk_integr_portal_portal foreign key (portal) references web_portal (codigo);

alter table web_integr_portal add chave_url varchar2(150);
alter table web_integr_portal add descricao varchar2(150);

alter table web_integr_portal drop column listlinhas;
alter table web_integr_portal drop column listfamilias;
alter table web_integr_portal drop column listgrupos;
alter table web_integr_portal drop column listempresas;

alter table web_integr_portal add flcontent char(1) default 'C' not null;
alter table web_integr_portal add jsp_content clob;
alter table web_integr_portal add charset varchar2(30) default 'ISO-8859-1' not null;
alter table web_integr_portal add flsalvaxml char(1) default 'S' not null;

alter table web_integr_portal rename column portal to portal_id;

--controle para salvar log
alter table web_integr_portal add(
save_log char(1) default 'N',
constraint ck_integr_poral_save_log check (save_log in ('S','N')))

ALTER TABLE web_integr_portal
add incluibrinde  char(1);

-- Thiago - 18/03/2013 - incluído quantidade de estoque com o produto
alter table web_integr_portal
add qtd_estoque number(2) default 1;
*/
alter table web_integr_portal add (FL_LAYOUT char(1) default 'N');


-- CWI John - 25/03/2015 - Templates XML
ALTER TABLE WEB_INTEGR_PORTAL 
ADD (TEMPLATE_XML clob) ;