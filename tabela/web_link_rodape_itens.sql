CREATE TABLE "WEBSITE"."WEB_LINK_RODAPE_ITENS" (
	codigo number(10) not null,
	link_rodape number(10) not null,
	caminho_link varchar(100) not null,
	descricao  varchar(100) not null,
	fl_ativo char(1) not null,
	constraint pk_web_link_rodape_itens primary key (codigo),
	constraint fk_web_link_rodape_itens foreign key (link_rodape) references web_link_rodape (codigo),
	constraint ck_web_link_rodape_itens check (fl_ativo in ('S','N'))
);

-- Aquiles 31/07/2013 - adicionado campos fl_target_blank,fl_nofollow
alter table web_link_rodape_itens add (
fl_target_blank char(1) default 'N',
fl_nofollow char(1) default 'N',
constraint ck_web_link_itens_blank check (fl_target_blank in ('S','N')),
constraint ck_web_link_itens_nofollow check (fl_nofollow in ('S','N')) );
