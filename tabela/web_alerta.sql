/*CREATE TABLE "WEBSITE"."WEB_ALERTA"
  (
    "CODIGO"      NUMBER(6,0) NOT NULL ENABLE,
    "PATH_IMAGEM" VARCHAR2(100 BYTE),
    "DT_FIM" DATE,
    "DT_INICIO" DATE,
    "LOCAL_INDEX"        VARCHAR2(1 BYTE),
    "LOCAL_CESTA"        VARCHAR2(1 BYTE),
    "TEMPO_ESPERA"       NUMBER(2,0),
    "FL_ATIVO"           VARCHAR2(1 BYTE),
    "DIAS_SEMANA"        VARCHAR2(100 BYTE),
    "ALTURA"             NUMBER(6,0),
    "LARGURA"            NUMBER(6,0),
    "POSICAO"            NUMBER(2,0),
    "URL"                VARCHAR2(200 BYTE),
    "NOME"               VARCHAR2(50 BYTE),
    "TP_EXIBICAO"        VARCHAR2(20 BYTE),
    "PATH_IMAGEM_FECHAR" VARCHAR2(200 BYTE),
    "DT_ALTER" DATE,
    "USERALTER"        VARCHAR2(20 BYTE),
    "LOCAL_CATEGORIAS" VARCHAR2(1 BYTE),
    "LOCAL_DETALHE"    VARCHAR2(1 BYTE),
    "HORA_INICIO"      NUMBER(2,0),
    "HORA_FIM"         NUMBER(2,0),
	
	CONSTRAINT "WEB_ALERTA_PK" PRIMARY KEY ("CODIGO") ENABLE
  );
*/
--Aquiles CWI 04/04/14
alter table WEB_ALERTA
add TP_CONTEUDO varchar2(10) default 'imagem';
  
--Aquiles CWI 04/04/14
alter table web_alerta
add html clob;

--Aquiles CWI 04/04/14
alter table web_alerta
add ALERTA_MODELO NUMBER(10,0);

--Aquiles CWI 04/04/14
alter table web_alerta
add CSS CLOB;

--Aquiles CWI 04/04/14
alter table web_alerta
add FL_EXIBIR_SEMPRE varchar2(1)DEFAULT 'S';

--Aquiles CWI 04/04/14
ALTER TABLE web_alerta
ADD FOREIGN KEY (ALERTA_MODELO)
REFERENCES "WEBSITE"."WEB_ALERTA_MODELO" ("CODIGO");

--Aquiles CWI 04/04/14
alter table web_alerta
add PORTAL NUMBER(10,0);

--Aquiles CWI 19/05/14
ALTER TABLE web_alerta
ADD FOREIGN KEY (PORTAL)
REFERENCES "WEBSITE"."WEB_PORTAL" ("CODIGO");

--Aquiles CWI 19/05/14
alter table web_alerta
add UTM_SOURCE varchar2(100);

--Aquiles CWI 19/05/14
alter table web_alerta
add UTM_MEDIUM varchar2(100);