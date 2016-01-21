/*--
-- Armazena os usuarios cadastrados no site
-- 1000 registros / mes
--
  CREATE TABLE "WEBSITE"."WEB_USUARIOS" 
   (	"CODCLILV" NUMBER(15,0) NOT NULL ENABLE, 
	"NUMCPF" NUMBER(20,0) NOT NULL ENABLE, 
	"SENHA" VARCHAR2(100 BYTE), 
	"NOME" VARCHAR2(100 BYTE), 
	"EMAIL" VARCHAR2(100 BYTE), 
	"NUMDOC" VARCHAR2(20 BYTE), 
	"EMISSOR" VARCHAR2(5 BYTE), 
	"APELIDO" VARCHAR2(20 BYTE), 
	"DTNASC" DATE, 
	"SEXO" CHAR(1 BYTE), 
	"NOMEMAE" VARCHAR2(40 BYTE), 
	"NOMEPAI" VARCHAR2(40 BYTE), 
	"CODESTCIVIL" NUMBER(3,0), 
	"NOMECONJ" VARCHAR2(40 BYTE), 
	"EMPRESA" VARCHAR2(40 BYTE), 
	"CODCARGO" NUMBER(6,0), 
	"DTULTACES" DATE, 
	"NATJUR" CHAR(1 BYTE), 
	"ENDERECO" VARCHAR2(40 BYTE), 
	"NUMERO" NUMBER(6,0), 
	"COMPLEMENTO" VARCHAR2(20 BYTE), 
	"DDDRESID" NUMBER(2,0), 
	"FONERESID" NUMBER(10,0), 
	"DDDCOML" NUMBER(2,0), 
	"RAMALRESID" NUMBER(5,0), 
	"FONECOML" NUMBER(10,0), 
	"DDDCELUL" NUMBER(2,0), 
	"CIDADE" VARCHAR2(60 BYTE), 
	"FONECELUL" NUMBER(10,0), 
	"UF" VARCHAR2(2 BYTE), 
	"CEP" NUMBER(8,0), 
	"FLMAILMKT" CHAR(1 BYTE), 
	"FLATULOJA" CHAR(1 BYTE), 
	"RAMALCOML" NUMBER(5,0), 
	"BAIRRO" VARCHAR2(30 BYTE), 
	"REFERENCIA" VARCHAR2(100 BYTE), 
	"FLATIVO" CHAR(1 BYTE) DEFAULT 'S', 
	"DTCADAST" DATE, 
	"CODCLI_GEMCO" NUMBER(15,0), 
	"TPUSUARIO" NUMBER(2,0) DEFAULT 0, 
	"DTALTER" DATE, 
	"CODCLIALTER" NUMBER(15,0), 
	 CONSTRAINT "WEB_USUARIOS_PK" PRIMARY KEY ("CODCLILV") ENABLE, 
	 CONSTRAINT "WEB_USUARIOS_UK" UNIQUE ("NUMCPF") ENABLE
   ) ;
 
CREATE UNIQUE INDEX "WEBSITE"."WEB_USUARIOS_UK" ON "WEBSITE"."WEB_USUARIOS" ("NUMCPF");

-- 01/06/2006 - Lucas - Alteracao de campos para o sistema do televendas
ALTER TABLE WEB_USUARIOS DROP COLUMN "ENDERECO";
ALTER TABLE WEB_USUARIOS DROP COLUMN "NUMERO";
ALTER TABLE WEB_USUARIOS DROP COLUMN "COMPLEMENTO";
ALTER TABLE WEB_USUARIOS DROP COLUMN "DDDRESID";
ALTER TABLE WEB_USUARIOS DROP COLUMN "FONERESID";
ALTER TABLE WEB_USUARIOS DROP COLUMN "DDDCOML";
ALTER TABLE WEB_USUARIOS DROP COLUMN "RAMALRESID";
ALTER TABLE WEB_USUARIOS DROP COLUMN "FONECOML";
ALTER TABLE WEB_USUARIOS DROP COLUMN "DDDCELUL";
ALTER TABLE WEB_USUARIOS DROP COLUMN "CIDADE";
ALTER TABLE WEB_USUARIOS DROP COLUMN "FONECELUL";
ALTER TABLE WEB_USUARIOS DROP COLUMN "UF";
ALTER TABLE WEB_USUARIOS DROP COLUMN "CEP";
ALTER TABLE WEB_USUARIOS DROP COLUMN "RAMALCOML";
ALTER TABLE WEB_USUARIOS DROP COLUMN "BAIRRO";
ALTER TABLE WEB_USUARIOS DROP COLUMN "REFERENCIA";
ALTER TABLE WEB_USUARIOS DROP COLUMN "FLATULOJA";
ALTER TABLE WEB_USUARIOS DROP COLUMN "FLATIVO";
ALTER TABLE WEB_USUARIOS DROP COLUMN "TPUSUARIO";

ALTER TABLE WEB_USUARIOS ADD ("FLSITE" CHAR(1) DEFAULT 'S');
ALTER TABLE WEB_USUARIOS ADD ("FLTELE" CHAR(1) DEFAULT 'N');
ALTER TABLE WEB_USUARIOS ADD ("FLADMIN" CHAR(1) DEFAULT 'N'); 
ALTER TABLE WEB_USUARIOS ADD ("VENDPRONTUARIO" NUMBER(6,0));
ALTER TABLE WEB_USUARIOS ADD ("CODCLIALTER" NUMBER(15,0));
ALTER TABLE WEB_USUARIOS ADD ("CODCLI_GEMCOANT" NUMBER(15,0));
ALTER TABLE WEB_USUARIOS ADD ("VENDFILIAL" NUMBER(3,0));
ALTER TABLE WEB_USUARIOS ADD ("ULTENDERECO" NUMBER DEFAULT 0 NOT NULL);
ALTER TABLE WEB_USUARIOS ADD ("PERCMAXDESC" NUMBER(15,2));

-- 02/08/2006 - Lucas - Alteracao de campos para o sistema do televendas
ALTER TABLE WEB_USUARIOS ADD ("RENDA" NUMBER(15,2));

-- 22/11/2006 - Lucas - Novos campos para armazenar os dados sobre a residencia
ALTER TABLE WEB_USUARIOS ADD ("TIPORESID" VARCHAR2(2));
ALTER TABLE WEB_USUARIOS ADD ("TEMPORESID" NUMBER(4));

-- 02/08/2007 - Lucas - Exclusao campos com otimizacao cadastro
ALTER TABLE WEB_USUARIOS RENAME COLUMN "FLSITE" TO "FLATIVO";
ALTER TABLE WEB_USUARIOS DROP COLUMN "APELIDO";
ALTER TABLE WEB_USUARIOS DROP COLUMN "FLMAILMKT";
ALTER TABLE WEB_USUARIOS DROP COLUMN "FLTELE";
ALTER TABLE WEB_USUARIOS DROP COLUMN "FLADMIN";
ALTER TABLE WEB_USUARIOS DROP COLUMN "VENDPRONTUARIO";
ALTER TABLE WEB_USUARIOS DROP COLUMN "VENDFILIAL";
ALTER TABLE WEB_USUARIOS DROP COLUMN "PERCMAXDESC";

-- 06/06/2007 - Thiago - Inclus�o de campo para Store in Store
ALTER TABLE WEB_USUARIOS ADD RENDACONJ NUMBER(15,2);
ALTER TABLE WEB_USUARIOS ADD DTADMISSAO DATE;
ALTER TABLE WEB_USUARIOS ADD DTNASCCONJ DATE;

--02/05/2012 - Aquiles - Adicao de campos para login pelo facebook e google account
ALTER TABLE WEB_USUARIOS ADD ("ID_FACEBOOK" NUMBER(17,0) DEFAULT NULL);
ALTER TABLE WEB_USUARIOS ADD ("ID_GOOGLE" NUMBER(25,0) DEFAULT NULL);*/


-- corre��o de base, o tamanho do campo nome esta diferente da cad_cliente
declare  
 cursor nomes is 
     select rowid, nome
     from web_usuarios u
     where length(u.nome) > 40;
     
begin
  for cr in nomes
    loop
      update web_usuarios
         set nome = substr(nome,0,39)
        where rowid = cr.rowid;
    end loop;
    commit;
end;

--exclusao da indice funcional
drop index WEB_USUARIOS_EMAIL_IDX_LOWER;


alter table web_usuarios
modify nome varchar2(40);


--recriacao do indice funcional
CREATE INDEX "WEBSITE"."WEB_USUARIOS_EMAIL_IDX_LOWER" ON "WEBSITE"."WEB_USUARIOS"
  (
    LOWER("NOME")
  );

alter table web_usuarios add COD_MOTIVO_BLOQUEIO number(10) references web_motivo_bloqueio (cod);

-- Gabriel CWI login por email
ALTER TABLE WEB_USUARIOS ADD FL_EMAIL_LOGIN CHAR(1 BYTE);

-- Alisson CWI 03/02/2015
-- add flag projeto Responsys
alter table web_usuarios ADD FL_ENVIADO_RESPONSYS varchar2(1);
create index idx_web_usuarios_fl_responsys on web_usuarios (fl_enviado_responsys);