/*-- 5000 registro

create table web_itprod_venda_agregada ( PIVA_ID number(10) not null primary key , 
										 PVA_id number(11) not null references web_prod_venda_agregada(pva_id) ,
										 itm_id_agregado number(10) not null references web_itprod(coditprod) );
*/

-- Aquiles CWI 20/11/13 projeto de quantidade de itens dos brindes
alter table web_itprod_venda_agregada add qnt_item number(2) default 1;