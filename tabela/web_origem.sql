
  CREATE TABLE WEB_ORIGEM
   (	"CODIGO" NUMBER(10,0),
	"DESCRICAO" VARCHAR2(100 BYTE),
	 CONSTRAINT "PK_WEB_ORIGEM" PRIMARY KEY ("CODIGO")
   ) ;


insert into web_origem (codigo,descricao) values (1,'site');
insert into web_origem (codigo,descricao) values (2,'premium');
insert into web_origem (codigo,descricao) values (3,'outlet');
insert into web_origem (codigo,descricao) values (4,'mobile');