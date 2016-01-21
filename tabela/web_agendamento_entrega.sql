create table web_agendamento_entrega (
codigo number(10),
frete_transportadora number(10),
dia date not null,
qtd_turno_manha number(4) default 0,
qtd_turno_tarde number(4) default 0,
qtd_turno_noite number(4) default 0,
constraint pk_agendamento_entrega primary key (codigo),
constraint fk_agendamento_entrega_transp foreign key (frete_transportadora) references fretes_transp_agend (codigo));

create sequence seq_web_agendamento_entrega

create unique index idx_web_agendamento_entrega on web_agendamento_entrega (frete_transportadora, dia);
