create table web_ger_relat_agenda (
	id number(10) not null primary key
	, tipoAgendamento varchar2(10) not null
	, tipoRelatorio varchar2(10) not null
	, diaSemana number(2)
	, dtmanual date
	, hora varchar2(8) not null
	, emissao_ini_dt date
	, emissao_ini_hora varchar2(8)
	, emissao_fim_dt date
	, emissao_fim_hora varchar2(8)
);

--Aquiles CWI 29/04/2014
alter table WEB_GER_RELAT_AGENDA
modify TIPORELATORIO VARCHAR2(20);