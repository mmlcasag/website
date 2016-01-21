-- Marcio Casagrande
-- Cadastro de links para seções do site
-- 08/08/2014
-- Estimativa de registros: 100 registros / ano

create table web_links_menu as select * from cad_secoes;

alter table web_links_menu add constraint pk_web_links_menu primary key (codigo);

grant select, insert, update, delete on cad_secoes to lvirtual;
grant select, insert, update, delete on cad_secoes to inf_8;

alter table web_links_menu add modo_exibicao number(1) default 0 not null;

-- Tipo Link = 1: Seções
-- Tipo Link = 2: Páginas Especiais
update web_links_menu set modo_exibicao = 1;