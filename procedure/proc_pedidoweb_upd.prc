create or replace procedure proc_pedidoweb_upd
( pident     in number
, pnumpedven in number
, pstatus    in varchar2
, pcoddevol  in varchar2
, psucesso   in out varchar2
, pdtpgbco   in date
) as
  
  v_sql long;
  
begin
  
  v_sql := ' declare v_aux varchar2(200); begin lvirtual.proc_pedidoweb_upd(' || pident || ',' || pnumpedven || ',' || '''' || pstatus || '''' || ',' || '''' || pcoddevol || '''' || ',v_aux,' || 'to_date(''' || pdtpgbco || ''',''dd/mm/yyyy'')' || '); end; ';
  
  insert into web_nuv_pendencias
    ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
  values
    ( seq_nuv_pendencias.nextval, sysdate, 'PROC_PEDIDOWEB_UPD', pnumpedven, v_sql, 'N', null );
  
  psucesso := 'S';
  
  commit;
  
exception
  when others then
    rollback;
    psucesso := 'N' || substr(sqlerrm,1,100);
end proc_pedidoweb_upd;
/
