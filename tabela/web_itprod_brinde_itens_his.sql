/*
CREATE TABLE "WEBSITE"."WEB_ITPROD_BRINDE_ITENS_HIS" 
( "COD_BRINDE" NUMBER(10,0)
, "COD_ITPROD" NUMBER(10,0)
, "VALOR" NUMBER(10,2)
, "VALOR_BOLETO" NUMBER(10,2)
, "DT_ALTERACAO" DATE
, "USR_ALTERACAO" VARCHAR2(60 BYTE)
, "OPERACAO_ALTERACAO" VARCHAR2(60 BYTE)
) ;
*/

alter table web_itprod_brinde_itens_his add constraint pk_web_itprod_brinde_itens_his primary key (cod_brinde, cod_itprod, operacao_alteracao, usr_alteracao, dt_alteracao);