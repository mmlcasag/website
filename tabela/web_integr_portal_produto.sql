CREATE TABLE WEB_INTEGR_PORTAL_PRODUTO (
	CODIGO INTEGER NOT NULL,
	COD_INTEGR_PORTAL INTEGER NOT NULL,
	CODPROD NUMBER(6,0) NOT NULL,
	DATA_INCLUSAO DATE NOT NULL,
	CONSTRAINT PK_WEB_INTEGR_PORTAL_PRODUTO PRIMARY KEY (CODIGO),
	CONSTRAINT UK_WEB_INTEGR_PORTAL_PRODUTO UNIQUE (COD_INTEGR_PORTAL, CODPROD),
	CONSTRAINT FK_INTEGR_PORTAL_PRODUTO_POR FOREIGN KEY (COD_INTEGR_PORTAL) REFERENCES WEBSITE.WEB_INTEGR_PORTAL (COD)
);


--- estatística de acessos e visitas
alter table web_integr_portal_produto
add fl_ativo char(1) default 'S' not null;

-- controle para imprimir preco cartao
alter table web_integr_portal_produto add(
fl_preco_cartao char(1) default 'N',
constraint ck_integr_portal_produto check (fl_preco_cartao in ('N','S')));