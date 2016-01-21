create table web_pesquisa_nao_encontrada(
codigo number(10),
tipo_sugestao char(1),
nome_pesquisa varchar2(4000),
termo_pesquisa varchar2(4000),
constraint pk_pesquisa_nao_encontrada primary key (codigo),
constraint ck_pesquisa_nao_encontrada check (tipo_sugestao in ('P','T')) );