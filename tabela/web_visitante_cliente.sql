create table WEB_VISITANTE_CLIENTE (
	CODIGO_VISITANTE VARCHAR2(36) primary key,
	CODCLILV number(15) references WEB_USUARIOS
);