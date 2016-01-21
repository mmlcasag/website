-- Create table
CREATE TABLE "WEBSITE"."WEB_USUARIOS_PREF"
(
  "USUARIO"      NUMBER(15) not null,
  "PREFERENCIAS" VARCHAR2(500) not null
)
-- Add comments to the columns 
comment on column WEB_USUARIOS_PREF.USUARIO
  is 'Chave do usuario';
comment on column WEB_USUARIOS_PREF.PREFERENCIAS
  is 'Chave do cookei que guarda o menu.';
-- Create/Recreate primary, unique and foreign key constraints 
alter table WEB_USUARIOS_PREF
  add constraint WEB_USUARIO_PREF_PK primary key (USUARIO)
