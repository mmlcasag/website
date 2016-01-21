create table web_descontos_progressivo_item (
  id number(10,0) not null,
  id_desconto number(10,0) not null,
  ordem_item integer not null,
  perc_desconto number(14,2) not null,
  constraint pk_web_descontos_progres_item primary key (id),
  constraint fk_web_desc_progr_item foreign key (id_desconto) references web_descontos_progressivo (id)
);