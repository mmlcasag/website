create table web_relatorio_hora (
codigo number(10),
codfil number(3),
codlinha number(3),
vendedor number(8),
data date not null,
hora number(2) not null,
qtd_clientes number(5) not null,
qtd_pedidos number(5) not null,
qtd_itens number(5) not null,
qtd_itens_sku number(5) not null,
valor_total number(10,2) not null,
margem number(5,2) not null,
constraint pk_relatorio_hora primary key (codigo),
constraint fk_relatorio_hora_linha foreign key (codlinha) references web_linha (codlinha),
constraint fk_relatorio_hora_cofil foreign key (codfil) references cad_filial(codfil));