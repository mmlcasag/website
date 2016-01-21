/*
create table web_ger_relat_ag_dia (
	id_agenda number(10) not null references web_ger_relat_agenda(id)
	, diaSemana number(2) not null
	, unique (id_agenda, diaSemana)
);
*/

alter table WEB_GER_RELAT_AG_DIA add constraint pk_WEB_GER_RELAT_AG_DIA primary key (id_agenda, diasemana);