CREATE TABLE web_pedidos_ocorrencias(
id number(10) not NULL,
nro_pedido number(8) not NULL,
dt_ocorrencia date,
cod_ocorrencia number(4) not NULL,
CONSTRAINT pk_web_ped_ocorrencia PRIMARY KEY (id),
CONSTRAINT fk_web_ped_ocorrencia_cod FOREIGN KEY (cod_ocorrencia) 
					  REFERENCES web_ret_transportadora(codigo));