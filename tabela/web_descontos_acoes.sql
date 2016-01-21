-- acoes para descontos
-- 100 registros

create table web_descontos_acoes (
codigo number (10),
descricao varchar(250) not null,
fl_exige_cpf char(1),
dias_validade number(3),
constraint pk_descontos_acoes primary key (codigo),
constraint ck_descontos_acoes_exigeCpf check (fl_exige_cpf in ('S','N')));