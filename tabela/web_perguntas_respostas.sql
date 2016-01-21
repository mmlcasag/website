create table WEB_PERGUNTAS_RESPOSTAS (
codigo number(10),
tipo char(1),
referencia number(10) not null,
pergunta varchar2(4000) not null,
resposta clob not null,
fl_ativo char(1),
ordem number(3) not null,
constraint pk_web_perguntas primary key (codigo),
constraint ck_web_perguntas_tipo check (tipo in ('L','F','G')),
constraint ck_web_perguntas_ativo check (fl_ativo in ('S','N')))