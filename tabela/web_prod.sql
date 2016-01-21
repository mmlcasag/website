/*
--
-- Armazena os dados dos produtos do site
-- 100 registros / mes
--
  CREATE TABLE "WEBSITE"."WEB_PROD" 
   (	"CODPROD" NUMBER(6,0) NOT NULL ENABLE, 
	"DESCRICAO" VARCHAR2(80 BYTE) NOT NULL ENABLE, 
	"CODGRUPO" NUMBER(6,0), 
	"CODFORNE" NUMBER(6,0), 
	"FLTRANSPORTE" CHAR(1 BYTE), 
	"DTALTER" DATE, 
	"USERALTER" VARCHAR2(20 BYTE), 
	"FLBRINDE" CHAR(1 BYTE), 
	"FLATIVO" CHAR(1 BYTE) NOT NULL ENABLE, 
	"NUMFOTOS" NUMBER(2,0) DEFAULT 0 NOT NULL ENABLE, 
	"MELHORPROMO" NUMBER(5,0), 
	"MELHORPLANO" VARCHAR2(3 BYTE) DEFAULT 'AV' NOT NULL ENABLE, 
	"PRECO" NUMBER(15,2) DEFAULT 0 NOT NULL ENABLE, 
	"CODEMPRESA" NUMBER(6,0), 
	"LINK_DEMONSTRACAO" VARCHAR2(300 BYTE), 
	 CONSTRAINT "WEB_PROD_PK" PRIMARY KEY ("CODPROD") ENABLE, 
	 CONSTRAINT "AVCON_WEB_P_FLATI_000" CHECK (FLATIVO IN ('S','N')) ENABLE, 
	 CONSTRAINT "AVCON_WEB_P_FLTRA_000" CHECK (FLTRANSPORTE BETWEEN 'C'
AND 'C' OR FLTRANSPORTE BETWEEN 'P'
AND 'P' OR FLTRANSPORTE BETWEEN 'T' AND 'T') ENABLE, 
	 CONSTRAINT "WEB_PROD_FK_FORNE" FOREIGN KEY ("CODFORNE")
	  REFERENCES "WEBSITE"."WEB_FORNE" ("CODFORNE") ENABLE, 
	 CONSTRAINT "WEB_PROD_FK_GRUPO" FOREIGN KEY ("CODGRUPO")
	  REFERENCES "WEBSITE"."WEB_GRUPO" ("CODGRUPO") ENABLE
   ) ;

  CREATE INDEX "WEBSITE"."WEB_PROD_IDX_FLATIVO" ON "WEBSITE"."WEB_PROD" ("FLATIVO") ;

-- 01/06/2006 - Lucas - Alteracao de campos para o sistema do televendas
ALTER TABLE WEB_PROD RENAME COLUMN "MELHORPROMO" TO "MELHORPROMOSITE" ;
ALTER TABLE WEB_PROD RENAME COLUMN "MELHORPLANO" TO "MELHORPLANOSITE" ;
ALTER TABLE WEB_PROD ADD ("MELHORPROMOTELE" NUMBER(5, 0));
ALTER TABLE WEB_PROD ADD ("MELHORPLANOTELE" VARCHAR2(3) DEFAULT 'AV' NOT NULL);

-- 01/09/2006 - Lucas - Adicionados campos para armazenar a situacao do estoque
ALTER TABLE WEB_PROD ADD ("ESTOQUE_RS" CHAR(1) DEFAULT 'S' NOT NULL);
ALTER TABLE WEB_PROD ADD ("ESTOQUE_SP" CHAR(1) DEFAULT 'S' NOT NULL);
ALTER TABLE WEB_PROD ADD ("ESTOQUE_REDE" CHAR(1) DEFAULT 'S' NOT NULL);

-- 20/12/2006 - Lucas - Flag para identificar quando o grupo do produto foi alterado
ALTER TABLE WEB_PROD ADD ("ALT_GRUPO" NUMBER(6, 0));

-- 01/02/2006 - Lucas - Campo para armazenar uma breve descricao do item
ALTER TABLE WEB_PROD ADD ("MINICARACT" VARCHAR2(210));

-- 06/03/2006 - Lucas - Armazena o melhor plano a vista
ALTER TABLE WEB_PROD ADD ("PRECOVISTA" NUMBER(15, 2));

-- 20/03/2006 - Lucas - Guarda a data de inclusao para utilizar nos lancamentos
ALTER TABLE WEB_PROD ADD ("DTINC" DATE);

-- 06/08/2007 - Lucas - Retirados alguns campos desnecessarios
ALTER TABLE WEB_PROD RENAME COLUMN "MELHORPROMOSITE" TO "MELHORPROMO" ;
ALTER TABLE WEB_PROD RENAME COLUMN "MELHORPLANOSITE" TO "MELHORPLANO" ;
ALTER TABLE WEB_PROD DROP COLUMN "MELHORPROMOTELE";
ALTER TABLE WEB_PROD DROP COLUMN "MELHORPLANOTELE";

-- Lucas - 24/01/2008 - controla a ativacao para o catalogo
ALTER TABLE WEB_PROD ADD ("FLCATALOGO" CHAR(1) DEFAULT 'S' NOT NULL);
ALTER TABLE WEB_PROD ADD ("DESCRICAOCAT" VARCHAR2(80));
ALTER TABLE WEB_PROD ADD ("GRUPOCAT" NUMBER(6));
ALTER TABLE WEB_PROD MODIFY ("DESCRICAO" NULL);

--Thiago - 26/03/2007 - aumento do campo descrição
alter table web_prod
modify minicaract varchar2(500);

--09/09/2008 - Mário - Inclusão de campo de envio do produto através de XML para portais
alter table web_prod add (FL_ENVIA_XML varchar2(1) default 'N', 
						  FL_POSSUI_MANUAL varchar2(1) default 'N');


--Jucemar - 22/09/2008 - Criação campo Classificação e nota do produto
ALTER TABLE WEB_PROD
ADD pcl_id NUMBER(10) not null default '0';

ALTER TABLE WEB_PROD
ADD CONSTRAINT WEB_CLASS_FK FOREIGN KEY(pcl_id)
	REFERENCES WEB_PROD_CLASSIFICACOES(pcl_id);

ALTER TABLE WEB_PROD
ADD nota NUMBER(5,2);

--01/10/2008 - Thiago - inclusão de campo para controle de brindes
alter table web_prod
add fl_disponivel_venda char(1);	

--21/05/2009 - Rodrigo Mandelli - default para campo fl_disponivel_venda
alter table web_prod
modify fl_disponivel_venda default 'N';

--24/08/2009 - Rodrigo Mandelli - inclusão do campo NUMVIDEOS
alter table web_prod
add numvideos number(2);

--26/11/2009 - Rodrigo Kuntzer, CWI - inclusão do campo DESCRICAOURL
alter table web_prod add descricaourl varchar2(100);
update web_prod set descricaourl = TRANSLATE(replace(replace(fnc_tiraacentos(descricao),'   ',' '),'  ',' '),' ','+');
--
alter table web_prod modify minicaract varchar2(4000);
--
alter table web_prod add INTEGRACAO_ONLINE NUMBER(1) default 0;


--### projeto 1977 - site premium ###
alter table web_prod
add flpremium char(1);

--### projeto outlet
alter table web_prod add floutlet char(1);

--25/04/2011 - Aquiles B da Silva, CWI - inclusão do campo link_youtube e html
alter table web_prod add( link_youtube varchar2(200), html varchar2(4000) );

--22/09/2011 - Aquiles B da Silva, CWI - inclusão do campo path_pdf
alter table web_prod add( path_pdf varchar2(200));

-- Alteração para remoção da cad_prod_web e cad_itprod_web
-- Mandelli 24/05/2012

ALTER TABLE web_prod
add CARACT_USALTER VARCHAR2(20);

ALTER TABLE web_prod
ADD CARACT_DTALTER DATE;

ALTER TABLE web_prod
add FLATUCARACT CHAR(1) DEFAULT 'N' NOT NULL;

ALTER TABLE web_prod
ADD MINI_DESCRICAO VARCHAR2(4000); */

-- integracao tramontina
alter table web_prod
add (fl_atualiza_automatic char(1) default 'S');
alter table web_prod
add constraint ch_atualiza_automac check (fl_atualiza_automatic in ('S','N'));