create table web_categ_redirect (
	cod number(10) not null primary key
	, codlinha number(3) unique references web_linha(codlinha)
	, codfam number(3) unique references web_familia(codfam)
	, codgrupo number(6) unique references web_grupo(codgrupo)
	, codlinha_dest number(3) references web_linha(codlinha)
	, codfam_dest number(3) references web_familia(codfam)
	, codgrupo_dest number(6) references web_grupo(codgrupo)
	, constraint web_categ_redirect_chk check(nvl2(codlinha, 1, 0) + nvl2(codfam, 1, 0) + nvl2(codgrupo, 1, 0) = 1)
	, constraint web_categ_redirect_dest_chk check(nvl2(codlinha_dest, 1, 0) + nvl2(codfam_dest, 1, 0) + nvl2(codgrupo_dest, 1, 0) = 1)
);

insert into web_categ_redirect (cod, codlinha, codlinha_dest)
select seq_web_categ_redirect.nextval, codlinha, redirect_linha from web_linha where redirect_linha is not null;

insert into web_categ_redirect (cod, codfam, codfam_dest)
select seq_web_categ_redirect.nextval, codfam, redirect_familia from web_familia where redirect_familia is not null;

insert into web_categ_redirect (cod, codgrupo, codgrupo_dest)
select seq_web_categ_redirect.nextval, codgrupo, redirect_grupo from web_grupo where redirect_grupo is not null;

commit;
