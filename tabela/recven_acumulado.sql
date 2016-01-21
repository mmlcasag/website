-- Marcio Casagrande
-- 27/06/2014
-- Máximo 100 registros
-- Serve apenas para mastigar algumas informações para o relatório gerencial do sistema de recuperação de vendas.
/*
create table recven_acumulado
( recven_consultor number(8) not null
, tipo_consulta    varchar2(50) not null
, qtd_vendas       number(15,2) default 0 not null
, vlr_vendas       number(15,2) default 0 not null
, constraint pk_recven_acumulado primary key (recven_consultor, tipo_consulta)
) ;
*/

alter table recven_acumulado add natjur char;
