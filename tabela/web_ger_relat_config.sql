create table web_ger_relat_config (
	id number(10) not null primary key
	, tipoRelatorio varchar2(10) not null
	, chave varchar2(10) not null
	, valor varchar2(255) not null
	, unique (tipoRelatorio, chave)
);


-- Aquiles CWI 29/04/2014
alter table WEB_GER_RELAT_CONFIG
modify TIPORELATORIO VARCHAR2(20);