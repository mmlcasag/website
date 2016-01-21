create table DADOS_IDENTIFICACAO_DA_LISTA as 
select d.numero_da_lista, d.tipo_informacao, d.endereco, d.bairro, d.cidade, d.estado, d.cep, d.numero
,      d.complemento, d.observacao, d.codcli, d.dtentrega1, d.dtentrega2, d.email, d.status_email
,      d.ddd_residencial, d.telefone_residencial, d.ddd_comercial, d.telefone_comercial
,      d.ddd_celular, d.telefone_celular
from   noivas.DADOS_IDENTIFICACAO_DA_LISTA@lnkproducao d
join   listas_de_noivas l on l.numero_da_lista = d.numero_da_lista
where  l.codfil = 400
and    trunc(l.data_cadastramento) >= '01/01/2015';

create index DILI_CLI_FK_I on DADOS_IDENTIFICACAO_DA_LISTA (CODCLI);
create index DILI_LINO_FK_I on DADOS_IDENTIFICACAO_DA_LISTA (NUMERO_DA_LISTA);
  
alter table DADOS_IDENTIFICACAO_DA_LISTA add constraint DILI_PK primary key (NUMERO_DA_LISTA, TIPO_INFORMACAO);
alter table DADOS_IDENTIFICACAO_DA_LISTA add constraint DILI_LINO_FK foreign key (NUMERO_DA_LISTA) references LISTAS_DE_NOIVAS (NUMERO_DA_LISTA);

alter table DADOS_IDENTIFICACAO_DA_LISTA add constraint AVCON_207095_STATU_000 check (STATUS_EMAIL BETWEEN 'S' AND 'S' OR STATUS_EMAIL BETWEEN 'N' AND 'N');
alter table DADOS_IDENTIFICACAO_DA_LISTA add constraint DILI_TIPO check (TIPO_INFORMACAO BETWEEN 'E'  AND 'E' OR TIPO_INFORMACAO BETWEEN 'A'  AND 'A' OR TIPO_INFORMACAO BETWEEN 'O' AND 'O');
