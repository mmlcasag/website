-- Mandelli 09/06/11
CREATE TABLE WEB_INTEGR_PORTAL_IP(
  "CODIGO"  number(*,0)  not null,
  "COD_ACESSO" number(*,0) not null,
  "IP"  varchar2(100) not null,
  "PAIS" varchar2(100) not null,
  "CIDADE" varchar2(100) ,
  "ESTADO" varchar2(100) ,
  "QTDE" number(*,0),
  constraint "web_integr_portal_ip_pk" primary key ("CODIGO"),
  constraint "web_integr_portal_ip_acesso_fk" foreign key ("COD_ACESSO") references web_integr_portal_acesso (codigo)
)