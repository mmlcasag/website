--analista: Rodrigo Mandelli

--armazena alguns dados para os pedidos do site
CREATE TABLE "WEBSITE"."MOV_PEDIDO_IP_UF"
(
  "CODIGO"    NUMBER(10) NOT NULL,
  "UF"        VARCHAR2(2 BYTE) NOT NULL,
  "ESTADO"    VARCHAR2(200 BYTE) NOT NULL,
  CONSTRAINT "MOV_PEDIDO_IP_UF_PK" PRIMARY KEY ("CODIGO")
);
  
--06/06/2011 - Mandelli - script de inicialização
insert into mov_pedido_ip_uf (codigo, uf, estado) values (1,'AC', 'Acre');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (2,'AL', 'Alagoas');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (3,'AP', 'Amapa');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (4,'AM', 'Amazonas');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (5,'BA', 'Bahia');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (6,'CE', 'Ceara');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (7,'ES', 'Espirito Santo');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (8,'DF', 'Distrito Federal');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (9,'GO', 'Goias');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (10,'MA', 'Maranhao');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (11,'MT', 'Mato Grosso');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (12,'MS', 'Mato Grosso do Sul');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (14,'PR', 'Parana');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (15,'PB', 'Paraiba');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (16,'PA', 'Para');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (17,'PE', 'Pernambuco');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (18,'PI', 'Piaui');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (19,'RJ', 'Rio de Janeiro');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (20,'RN', 'Rio Grande do Norte');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (21,'RS', 'Rio Grande do Sul');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (22,'RO', 'Rondonia');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (23,'RR', 'Roraima');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (24,'SC', 'Santa Catarina');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (25,'SE', 'Sergipe');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (26,'SP', 'Sao Paulo');
insert into mov_pedido_ip_uf (codigo, uf, estado) values (27,'TO', 'Tocantins');

--06/06/2011 - Mandelli - grant
grant all on mov_pedido_ip_uf to lvirtual;

--recommit