reate table fretes_transp_agend_semana (
codigo number(10),
fretes_transp_agend number(10),
dia_semana number(1),
qtd_turno_manha number(4) default 0,
qtd_turno_tarde number(4) default 0,
qtd_turno_noite number(4) default 0,
constraint pk_fretes_transp_agend_semana primary key (codigo),
constraint fk_fretes_transp_agend_semana foreign key (fretes_transp_agend) references fretes_transp_agend (codigo),
constraint ck_fretes_transp_agend_semana check (dia_semana in (1,2,3,4,5,6,7)));

create unique index idx_fretes_transp_agend_semana on fretes_transp_agend_semana(fretes_transp_agend,dia_semana);