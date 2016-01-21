/*
create table web_nuv_pendencias
( id             number(10) not null
, dat_inclusao   date default sysdate not null
, nom_programa   varchar2(30) not null
, sql_comando    varchar2(4000) not null
, flg_processado char default 'N' not null
, dat_processado date
, constraint pk_nuv_pendencias primary key (id)
) ;

create index id1_nuv_pendencias on web_nuv_pendencias (flg_processado);

alter table web_nuv_pendencias add primary_key number(10);
*/
ALTER TABLE website.web_nuv_pendencias MODIFY NOM_PROGRAMA VARCHAR2(60);