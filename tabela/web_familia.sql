/*CREATE TABLE "WEBSITE"."WEB_FAMILIA" 
   (	"CODFAM" NUMBER(3,0), 
	"DESCRICAO" VARCHAR2(60 BYTE), 
	"CODLINHA" NUMBER(3,0), 
	"DTALTER" DATE, 
	"USERALTER" VARCHAR2(20 BYTE), 
	"FLATIVO" CHAR(1 BYTE) DEFAULT 'S'
   )
   
   -- Modificado por: Bruno Zanotti
   -- Incluido 2 campos : APARECE_MENU para ver se aparece no menu lateral da capa do site;
   --                     APARECE_XML para ver se o produtos da familia aparece no XML
   
   ALTER TABLE WEB_FAMILIA ADD ("APARECE_MENU" VARCHAR2(1));
   ALTER TABLE WEB_FAMILIA ADD ("APARECE_XML" VARCHAR2(1));

-- Lucas - 24/01/2008 - controla a ativacao para o catalogo
ALTER TABLE WEB_FAMILIA ADD ("FLCATALOGO" CHAR(1) DEFAULT 'S' NOT NULL);

--Thiago 11/12/2009 - adicionado controle para landing page
alter table web_familia
add landing_page varchar2(400);

--Rodrigo Kuntzer 20/01/2010
alter table web_familia add page_title varchar2(200);
alter table web_familia add page_description varchar2(200);

--### projeto 1977 - site premium ###
alter table web_familia
add flpremium char(1); 

-- Mandelli - Tag Remarketing CADASTRA

alter table web_familia
add tag_remarketing varchar2(2000);

--### projeto outlet
alter table web_familia add floutlet char(1) default 'N';

--Aquiles B da Silva - CWI - 26/04/2011 - adicionado controle para page_title_brands
alter table web_grupo add page_title_brands varchar2(200);

--Gabriel Balensiefer - CWI - 04/05/2011 - Texto exibido no rodapé da página de familias
ALTER TABLE WEB_FAMILIA ADD (TEXTO_RODAPE VARCHAR2(400 BYTE));

-- Mandelli - 31/05/2001 - Aumento nos campos
ALTER TABLE web_familia MODIFY ( TEXTO_RODAPE varchar2(4000) );
ALTER TABLE web_familia MODIFY ( LANDING_PAGE varchar2(4000) );*/


-- Mandelli - 06/07/2012 - Inclusão de campo

ALTER TABLE web_familia
ADD redirect_familia NUMBER(3);

--Aquiles - 15/07/2013 - Inclusão de campo
ALTER TABLE web_familia
ADD descricao_google varchar2(60);

--cesaraugusto - 28/04/2015 Ordenação de Menus
alter TABLE WEB_FAMILIA
add (
	ORDEM_MENU decimal(2,0)
);