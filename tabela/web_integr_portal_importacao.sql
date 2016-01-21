create table web_integr_portal_importacao (
codigo number(10),
cod_integr_portal number(10),
codlinha number(10),
tipo char(1)  not null, 
dias_vendas number(3),
percentual number(3),
preco_minimo number(10,2),
fl_domingo char(1) default 'N',
fl_segunda char(1) default 'N',
fl_terca char(1) default 'N',
fl_quarta char(1) default 'N',
fl_quinta char(1) default 'N',
fl_sexta char(1) default 'N',
fl_sabado char(1) default 'N',
fl_exclui_historico char(1) default 'N',
constraint pk_integr_portal_importacao primary key (codigo),
constraint fk_integr_portal_importacao foreign key (cod_integr_portal) references web_integr_portal (cod),
constraint ck_integr_portal_importacao check  (tipo in ('M','T')),
constraint fk_integr_portal_imp_linha foreign key (codlinha) references web_linha(codlinha));

create unique index idx_integr_portal_importacao on web_integr_portal_importacao (cod_integr_portal,codlinha);