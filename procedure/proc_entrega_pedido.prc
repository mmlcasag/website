create or replace procedure proc_entrega_pedido
( pfilial        in number
, ppedido        in number
, pvendedor      in number
, pprontuario    in number
, pendereco      in number
, pdtfaturamento in date
, pobs           in varchar2
) is
  
  v_sql  long;
  
begin
  
  update mov_pedido
  set    obs       = replacechars(pobs)
  ,      dtentrega = pdtfaturamento
  where  codfil    = pfilial
  and    numpedven = ppedido;
  
  v_sql := ' update mov_pedido
             set    obs       = ''' || replacechars(pobs) || '''
             ,      dtentrega = to_date(''' || to_char(pdtfaturamento,'dd/mm/yyyy') || ''',''dd/mm/yyyy'')
             where  codfil    = ' || pfilial || '
             and    numpedven = ' || ppedido;
  
  insert into web_nuv_pendencias
    ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
  values
    ( seq_nuv_pendencias.nextval, sysdate, 'PROC_ENTREGA_PEDIDO', ppedido, v_sql, 'N', null );
  
  commit;
  
exception
  when others then
    rollback;
    raise;
end proc_entrega_pedido;
/
