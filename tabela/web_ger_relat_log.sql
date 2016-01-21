/*create table web_ger_relat_log (
	id number(10) not null primary key
	, id_agenda number(10) not null
	, dh_execucao timestamp not null
	, flok varchar2(1) not null
	, msg varchar2(255)
	, tipoAgendamento varchar2(10) not null
	, tipoRelatorio varchar2(10) not null
	, emissao_ini_dt date
	, emissao_ini_hora varchar2(8)
	, emissao_fim_dt date
	, emissao_fim_hora varchar2(8)
);
*/

-- Mandelli - Inclus�o do campo quantidade para grava��o no log
ALTER TABLE WEB_GER_RELAT_LOG
add qnt number(10) default 0 not null ;

-- Mandelli - Inclus�o do campo sql para grava��o no log
ALTER TABLE WEB_GER_RELAT_LOG
add sql varchar2(4000);

-- Aquiles CWI 29/04/2014
alter table WEB_GER_RELAT_LOG
modify TIPORELATORIO VARCHAR2(20);