CREATE TABLE WEB_PALAVRA_CHAVE_PESQUISA (
	CODIGO NUMBER(10, 0) NOT NULL,
	DATA_PESQUISA DATE NOT NULL,
	TERMO VARCHAR2(100) NOT NULL,
	CONSTRAINT WEB_PALAVRA_CHAVE_PESQUIS_PK PRIMARY KEY(CODIGO) ENABLE 
);