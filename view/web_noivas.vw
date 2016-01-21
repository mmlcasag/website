create or replace view web_noivas as
select a.numero_da_lista codigo,
       a.nome_da_noiva nome_noiva,a.nome_do_noivo nome_noivo,
       a.data_casamento dtcasamento,
       b.endereco,str2num(b.numero) numero,b.complemento compl,b.bairro,b.cidade,b.estado,
       str2num(substr(b.cep,1,8)) cep,
       b.ddd_residencial dddres,replace(b.telefone_residencial,'-','') foneres,
       b.ddd_comercial dddcom,replace(b.telefone_comercial,'-','') fonecom,
       b.ddd_celular dddcel,replace(b.telefone_celular,'-','') fonecel,
       b.dtentrega1,b.dtentrega2, a.cod_usuario_site, nvl(a.status_da_lista,'S') status_da_lista,
       a.flg_modo_entrega, ena.email email_noiva, ena.status_email status_email_noiva,
       eno.email email_noivo, eno.status_email status_email_noivo, a.cpf_noiva, a.cpf_noivo,
       a.mensagem, b.observacao observacao_endereco,a.fl_enviado_responsys, a.data_cadastramento
  from listas_de_noivas a, dados_identificacao_da_lista b,
       ( select x.numero_da_lista, x.email, x.status_email
           from dados_identificacao_da_lista x
          where x.tipo_informacao = 'A'
       ) ena,
       ( select x.numero_da_lista, x.email, x.status_email
           from dados_identificacao_da_lista x
          where x.tipo_informacao = 'O'
       ) eno
 where a.numero_da_lista = b.numero_da_lista
   and a.numero_da_lista = ena.numero_da_lista (+)
   and a.numero_da_lista = eno.numero_da_lista (+)
   and a.status_autorizacao_de_acesso = 'S'
   and b.tipo_informacao = 'E'
   and str2num(substr(b.cep,1,8)) is not null
   and b.endereco is not null
 order by a.data_casamento,a.nome_da_noiva;
