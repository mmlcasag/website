/*CREATE TABLE "WEBSITE"."WEB_LINHA" 
   (	"CODLINHA" NUMBER(3,0), 
	"DESCRICAO" VARCHAR2(60 BYTE), 
	"FLATIVO" CHAR(1 BYTE) DEFAULT 'S', 
	"ORDEM_MENU" NUMBER(2,0), 
	"DESCR_MENU" VARCHAR2(30 BYTE), 
	"USERALTER" VARCHAR2(20 BYTE), 
	"DTALTER" DATE
    )
    
   -- Modificado por: Bruno Zanotti
   -- Incluido 1 campo : APARECE_MENU para ver se aparece no menu lateral da capa do site;
    
    ALTER TABLE WEB_LINHA ADD ("APARECE_MENU" VARCHAR2(1));
    
-- Lucas - 24/01/2008 - controla a ativacao para o catalogo
ALTER TABLE WEB_LINHA ADD ("FLCATALOGO" CHAR(1) DEFAULT 'S' NOT NULL);


--Thiago 11/12/2009 - adicionado controle para landing page
alter table web_linha
add landing_page varchar2(400);

--Rodrigo Kuntzer 15/01/2010 - adicionada configuração para o layout da linha
alter table web_linha add path_layout varchar2(100);

--Rodrigo Kuntzer 20/01/2010
alter table web_linha add page_title varchar2(200);
alter table web_linha add page_description varchar2(200);

--### projeto 1977 - site premium ###
alter table web_linha
add flpremium char(1);

-- Mandelli - Tag Remarketing CADASTRA
alter table web_linha
add tag_remarketing varchar2(2000);

--### projeto outlet
alter table web_linha add floutlet char(1) default 'N';

--Aquiles B da Silva - CWI - 26/04/2011 - adicionado controle para page_title_brands
alter table web_grupo add page_title_brands varchar2(200);

--Gabriel Balensiefer - CWI - 04/05/2011 - Texto exibido no rodapé da página de linhas
ALTER TABLE WEB_LINHA ADD (TEXTO_RODAPE VARCHAR2(400 BYTE));

-- Mandelli - 31/05/2001 - Aumento nos campos
ALTER TABLE web_linha MODIFY ( TEXTO_RODAPE varchar2(4000) );
ALTER TABLE web_linha MODIFY ( LANDING_PAGE varchar2(4000) );
*/
-- Mandelli - 06/07/2012 - Inclusão de campo
ALTER TABLE web_linha
add redirect_linha number(3);

--Aquiles - 15/07/2013 - Inclusão de campo
ALTER TABLE web_linha
	add descricao_google varchar2(60);