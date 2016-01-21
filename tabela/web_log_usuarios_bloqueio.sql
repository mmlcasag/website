
create table web_log_usuarios_bloqueio (
	cod number(10) not null primary key
	, codclilv number(10) not null references web_usuarios (codclilv)
	, cod_motivo number(10) not null references web_motivo_bloqueio (cod)
	, dh date not null
	, ip varchar2(15) not null
	);	
