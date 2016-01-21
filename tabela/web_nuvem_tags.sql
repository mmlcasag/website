-- Tabela que armazena as tags da nuvem de tags do site.
-- Criado por: Rodrigo Mandelli - 18/06/2009.
-- Armazena máximo de 100 registros.
/*
create table "WEBSITE"."WEB_NUVEM_TAGS"
("DESCRICAO" VARCHAR2(255) NOT NULL,
 "LINHA"     NUMBER(3))
*/

alter table web_nuvem_tags add constraint pk_web_nuvem_tags primary key (descricao);