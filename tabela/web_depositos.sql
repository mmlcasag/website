/*-- 10 registros; tabela com cadastro de depósitos para o Site

create table web_depositos (
codigo number(10),
flativo char(1),
fldefault char(1),
constraint pk_web_depositos primary key (codigo),
constraint check_flativo check (flativo in ('S','N')),
constraint check_fldefault check (fldefault in ('S','N'))
);

create index idx_web_depositos_flativo on  web_depositos (flativo);
---
alter table web_depositos add cnpj number(15);*/

-- Mandelli 12/2013 - Inclusão de FLAG para habilitar/desabilitar modalidade pré-venda
ALTER TABLE WEB_DEPOSITOS
ADD FLPREVENDA CHAR(1) DEFAULT 'S';