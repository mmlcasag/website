create table web_mais_vendidos_int_pedidos (
codigo number(10),
numpedven number(8),
mais_vendidos_integr number(10),
constraint pk_mais_vendidos_int_pedidos primary key (codigo),
constraint fk_mais_vendidos_int_pedidos foreign key (mais_vendidos_integr) references web_mais_vendidos_integr (codigo));

grant delete, select, insert, update on web_mais_vendidos_int_pedidos to lvirtual;