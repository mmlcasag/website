create table estatisticas_hibernate_sql (
codigo number(10),
estatistica number(10),
consulta varchar2(2000),
quantidade number(10),
tempo_medio number(10),
primary key (codigo),
constraint fk_estatisticas_hibernate foreign key (estatistica) references estatisticas_hibernate(codigo)
);

create sequence seq_estatisticas_hibernate_sql start with 1 maxvalue 999999999;