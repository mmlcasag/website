create table fretes_transp_agend (
codigo number(10),
qtd_dias_min number(3) default 3 not null ,
qtd_dias_max number(3) default 30 not null,
fl_ativo char(1) default 'N',
constraint pk_fretes_transp_agend primary key (codigo),
constraint fk_fretes_transp_agend foreign key (codigo) references fretes_transportadora (codigo),
constraint ck_fretes_transp_agend check (fl_ativo in ('S','N')));