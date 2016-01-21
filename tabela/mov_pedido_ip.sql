-- Tabela que armazena o endereço IP do cliente que finalizou a compra.
-- Criado por: Rodrigo Mandelli - 24/05/2011.
-- Armazena em tordo de 2 mil registros por dia.

CREATE TABLE "WEBSITE"."MOV_PEDIDO_IP" 
("NUMPEDVEN" NUMBER(8,0) NOT NULL ENABLE, 
"IP" VARCHAR2(30 BYTE) NOT NULL ENABLE, 
"PAIS" VARCHAR2(200 BYTE), 
"ESTADO" VARCHAR2(200 BYTE), 
"CIDADE" VARCHAR2(200 BYTE), 
"LATITUDE" NUMBER(10,5), 
"LONGITUDE" NUMBER(10,5), 
 CONSTRAINT "MOV_PEDIDO_IP_PK" PRIMARY KEY ("NUMPEDVEN"));
 
 -- Mandelli 06/06/2011
 grant all on mov_pedido_ip to lvirtual;