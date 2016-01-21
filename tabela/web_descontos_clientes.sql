-- clientes por desconto
-- 2.000 por mês

create table web_descontos_clientes (
codigo number (10),
numcpf number (20) not null,
data_inclusao date not null,
fl_ativo char(1),
codDesconto number(15) not null,
constraint pk_web_descontos_clientes primary key (codigo),
constraint ck_web_descontos_cli_flativo check ( fl_ativo in ('S','N')),
constraint fl_web_descontos_cli_descon foreign key (coddesconto) references web_descontos (coddesconto))

-- Criada constraint para garantir que usuário não será inserido duas vezes no mesmo desconto - Mandelli 10/2010

alter table web_descontos_clientes
add constraint uk_cliente_desconto unique (numcpf, coddesconto);
