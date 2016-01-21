/* CREATE TABLE "WEBSITE"."WEB_GRUPO" 
   (	"CODGRUPO" NUMBER(6,0), 
	"DESCRICAO" VARCHAR2(40 BYTE), 
	"CODFAM" NUMBER(3,0), 
	"DTALTER" DATE, 
	"USERALTER" VARCHAR2(20 BYTE), 
	"FLATIVO" CHAR(1 BYTE) DEFAULT 'S'
   )
   
   -- Modificado por: Bruno Zanotti
   -- Incluido 1 campo : APARECE_MENU para ver se aparece no menu lateral da capa do site;
   
   ALTER TABLE WEB_GRUPO ADD ("APARECE_MENU" VARCHAR2(1));

-- Lucas - 24/01/2008 - controla a ativacao do grupo para o catalogo
ALTER TABLE WEB_GRUPO ADD ("FLCATALOGO" CHAR(1) DEFAULT 'S' NOT NULL);

--Thiago 11/12/2009 - adicionado controle para landing page
alter table web_grupo
add landing_page varchar2(400);


--### projeto 1977 - site premium ###
alter table web_grupo
add flpremium char(1);

--### projeto outlet
alter table web_grupo add floutlet char(1);

--Aquiles B da Silva - CWI - 26/04/2011 - adicionado controle para page_description,page_title,page_title_brands
alter table web_grupo add (
    page_description varchar2(200),
    page_title varchar2(200),
    page_title_brands varchar2(200),
);

--Gabriel Balensiefer - CWI - 04/05/2011 - Texto exibido no rodapé da página de grupos
ALTER TABLE WEB_GRUPO ADD (TEXTO_RODAPE VARCHAR2(400 BYTE));

-- Mandelli - 31/05/2001 - Aumento nos campos
ALTER TABLE web_grupo MODIFY ( TEXTO_RODAPE varchar2(4000) );
ALTER TABLE web_grupo MODIFY ( LANDING_PAGE varchar2(4000) );*/


-- Mandelli - 06/07/2012 - Inclusão de campo
ALTER TABLE web_grupo
add redirect_grupo number(6);

--Aquiles - 15/07/2013 - Inclusão de campo
ALTER TABLE web_grupo
add descricao_google varchar2(60);

--cesaraugusto - 28/04/2015 - Ordenação de Menus
alter TABLE WEB_GRUPO
add (
	ORDEM_MENU decimal(2,0)
);