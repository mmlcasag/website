/*--
-- Armazena os vendedores do site
-- 500 registros total
--

  CREATE TABLE "WEBSITE"."WEB_VENDEDOR" 
   (	"USUARIO" VARCHAR2(30 BYTE) NOT NULL ENABLE, 
	"NOME" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"EMAIL" VARCHAR2(100 BYTE) NOT NULL ENABLE, 
	"PERFIL" NUMBER(3,0) NOT NULL ENABLE, 
	"FILIAL" NUMBER(3,0) NOT NULL ENABLE, 
	"SENHA" VARCHAR2(100 BYTE), 
	"FLATIVO" CHAR(1 BYTE) DEFAULT 'N' NOT NULL ENABLE, 
	"DTULTACES" DATE, 
	"DTCADAST" DATE, 
	"USCADAST" VARCHAR2(20 BYTE), 
	"DTALTER" DATE, 
	"USALTER" VARCHAR2(20 BYTE), 
	"CODIGO" NUMBER(9,0) NOT NULL ENABLE, 
	"PRONTUARIO" NUMBER(9,0), 
	 CONSTRAINT "WEB_VENDEDOR_PK" PRIMARY KEY ("CODIGO")
  USING INDEX, 
	 CONSTRAINT "WEB_VENDEDOR_WEB_PERFIL_FK1" FOREIGN KEY ("PERFIL")
	  REFERENCES "WEBSITE"."WEB_PERFIL" ("CODIGO") ENABLE
   );


alter table web_vendedor add fl_conteudo_html char(1) default 'S' not null;

--Aquiles CWI 07/11/2013 limite de preços
alter table web_vendedor add fl_limite_qtd_prod varchar2(1) default 'S';

-- Thiago 05/12/2013 grava log de pesquisa
alter table web_vendedor add(
fl_log_consulta char(1) default 'N');


-- Mandelli 05/06/2014 ajusste para exibição de preço site ou loja
alter table web_vendedor
add fl_exibe_preco_site char(1) default 'N';

update web_vendedor
set fl_exibe_preco_site = 'S'
where filial in (70, 400, 234);

-- CesarAugusto 24/08/2015
alter table WEB_VENDEDOR
add(
	prazo_maximo number(3)
);*/
-- Mandelli 26/08/2015 - remoção de campo 
alter table web_vendedor drop column prazo_maximo;