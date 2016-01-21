/*create table web_integr_portal_log(
codigo number(10),
portal number(10),
data  date,
qtd number (6),
constraint pk_integr_portal_log primary key (codigo),
constraint fk_integr_portal_log foreign key (portal) references web_integr_portal (cod));*/

-- Thiago 23/10/2012 - incluido tempo de execucao do xml
alter table web_integr_portal_log
add (tempo_geracao_segundos number(10));