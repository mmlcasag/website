-- Marcio Casagrande
-- Atribuir depósito 450 para algumas filiais de SC

-- Tamanho da tabela: pequena (até 200 registros)

create table web_depositos_ceps 
( codigo   number(10) not null
, deposito number(10) not null
, cep_ini  number(8)  not null
, cep_fim  number(8)  not null
, constraint pk_web_depositos_ceps primary key (codigo)
, constraint fk_web_depositos_ceps foreign key (deposito) references web_depositos (codigo)
, constraint uk_web_depositos_ceps unique (deposito, cep_ini, cep_fim)
) ;

create public synonym web_depositos_ceps for website.web_depositos_ceps;

grant select on web_depositos_ceps to apcol;
grant select on web_depositos_ceps to autocomweb;
grant select on web_depositos_ceps to colombo;
grant select on web_depositos_ceps to lvirtual;