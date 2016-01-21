/*create table web_ocorrencias_frota_propria(
codigo number(10),
numpedven number(8),
codigo_ocorrencia number(2),
data_ocorrencia date,
constraint pk_ocorrencias_frota_propria primary key (codigo) );

create index idx_ocor_frota_propria_numped on web_ocorrencias_frota_propria (numpedven);

create index idx_ocor_frota_propria_data on web_ocorrencias_frota_propria (data_ocorrencia);

-- Mandelli 25/03 - INFO LOG
alter table web_ocorrencias_frota_propria
add filial_destino number(3);

alter table web_ocorrencias_frota_propria
add filial_origem number(3);

alter table web_ocorrencias_frota_propria
add data_cadastro date;

alter table web_ocorrencias_frota_propria
add transportadora number(3);
*/
-- Mandelli 26/03 - Informacoes para tentar entender funcionamento das tabelas de logistica
alter table web_ocorrencias_frota_propria
add tabela char(1);

alter table web_ocorrencias_frota_propria
add operation char(1);