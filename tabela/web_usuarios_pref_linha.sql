
create table web_usuarios_pref_linha
( cod number(15) not null primary key
	, codusuario number(15) not null references web_usuarios
	, codlinha number(15) not null references web_linha
);

-- Aquiles CWI - 01/08/2013 - adicao data de alteracao
alter table web_usuarios_pref_linha add dt_alteracao date;
