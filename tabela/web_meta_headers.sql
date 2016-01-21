

create table web_meta_headers (
	cod number(10) not null primary key
	, tipo number(2) not null
	, codlinha number(6) references web_linha (codlinha)
	, codfam number(6) references web_familia (codfam)
	, codgrupo number(6) references web_grupo (codgrupo)
	, codprod number(6) references web_prod (codprod)
	, tit_padrao varchar2(255)
	, tit_pre varchar2 (50)
	, tit_pos varchar2 (50)
	, meta_descr varchar2 (255)
	, meta_keys varchar2 (255)
	, scripts varchar2 (1000)
);


/* constraint: 
	permite que no máximo um dos campos da estrutura seja preenchido 
	valida o tipo, sendo: 1:geral 2:linha 3:familia 4:grupo 5:produto
*/
alter table web_meta_headers add constraint web_meta_headers_valid check (
  nvl2(codlinha, 1, 0) + nvl2(codfam, 1, 0) + nvl2(codgrupo, 1, 0) + nvl2(codprod, 1, 0) <= 1
  and nvl2(codlinha, 1, 0) + nvl2(codfam, 2, 0) + nvl2(codgrupo, 3, 0) + nvl2(codprod, 4, 0) = tipo - 1
);

create unique index web_meta_headers_unique on web_meta_headers (
  tipo, coalesce(codprod, codgrupo, codfam, codlinha, 0)
);

