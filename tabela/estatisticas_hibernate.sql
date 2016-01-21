create table estatisticas_hibernate (
codigo number(10),
pagina varchar2(100),
sessoes number(10),
conexoes number(10),
transacoes number(10),
consultas number(10),
maior_consulta varchar2(2000),
tempo_maior_consulta number(10),
data_geracao date,
primary key(codigo));

create sequence seq_estatisticas_hibernate start with 1 maxvalue 999999999;