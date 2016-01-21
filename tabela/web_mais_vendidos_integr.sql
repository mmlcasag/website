create table web_mais_vendidos_integr (
codigo number(10),
codprod number (6),
codlinha number(3),
codIntegr number(10), 
data_compra date not null,
quantidade number(3) not null,
valor number(15,2) not null,
constraint pk_mais_vendidos_integr primary key (codigo),
constraint fk_mais_vendidos_int_prod foreign key (codprod) references web_prod (codprod),
constraint fk_mais_vendidos_int_linh foreign key (codlinha) references web_linha (codlinha),
constraint fk_mais_vendidos_integr foreign key (codIntegr) references web_integr_portal(cod));

create unique index idx_mais_vendidos_integr on web_mais_vendidos_integr (codprod, codIntegr, data_compra);

grant delete, select, insert, update on web_mais_vendidos_integr to lvirtual;

-- Mandelli (projeto brindes) 04/12
ALTER TABLE web_mais_vendidos_integr
add cod_brinde number(10);

drop index idx_mais_vendidos_integr;

CREATE UNIQUE INDEX idx_mais_vendidos_integr ON web_mais_vendidos_integr (codprod, codIntegr, data_compra, cod_brinde);
