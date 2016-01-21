create table web_pedido_avaliacao (
  id  number(10,0) not null,
  numpedven number(10,0) not null,
  data_avaliacao date not null,
  pergunta  number(6,0) not null,
  nota      number(2,0),
  observacao varchar2(4000),
  constraint pk_web_pedido_avaliacao primary key (id),
  constraint uk_web_pedido_avaliacao unique (numpedven,pergunta)
);