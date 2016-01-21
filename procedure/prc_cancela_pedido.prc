create or replace procedure prc_cancela_pedido
( p_codfil     in number
, p_numpedven  in number
, p_prontuario in varchar2
, p_motivo     in number default null
, p_coddevol   in char   default null
) is
  
  b_erro       boolean       := false;
  v_sql        long          := null;
  v_mensagem   varchar2(200) := null;
  n_aux        number        := 0;
  
begin
  
  -- verifica se o pedido está com status de liberação de pedidos ralizados com cartao 3 ou 9
  -- se passou pelo cancelamento via SiTEF
  select count(*)
  into   n_aux
  from   mov_pedido         pd
  join   pedidos_liberacoes pl on pl.pli_id = pd.numpedven and pl.pls_id in (3,9)
  where  pd.numpedven        = p_numpedven
  and    pd.status           = 5;
  
  if not b_erro and n_aux = 0 then
    b_erro := true;
    v_mensagem := 'Cancelamento de pedidos liberados não permitida';
  end if;
  
  if b_erro then
    raise_application_error(-20000, v_mensagem);
  else
    v_sql := ' begin prc_cancela_pedido(' || p_codfil || ',' || p_numpedven || ',' || '''' || p_prontuario || '''' || ',' || p_motivo || ',' || '''' || p_coddevol || '''' || '); end; ';
    
    insert into web_nuv_pendencias
      ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
    values
      ( seq_nuv_pendencias.nextval, sysdate, 'PRC_CANCELA_PEDIDO', p_numpedven, v_sql, 'N', null );
  end if;
  
end prc_cancela_pedido;
/
