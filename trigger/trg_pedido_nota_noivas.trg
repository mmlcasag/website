create or replace trigger website.trg_pedido_nota_noivas
after insert or update or delete on website.pedido_nota_noivas
for each row

declare
  
  v1    varchar2(200);
  v2    varchar2(200);
  v3    varchar2(200);
  v4    varchar2(200);
  
  v_id  number;
  v_sql clob;
  
begin
  
  who_called_me(v1, v2, v3, v4);
  
  -- Se replicou do NOIVAS pro WEBSITE, n�o precisa replicar de volta
  if v4 like '%TRIGGER%' and v1 like '%NOIVAS%' and v2 like '%TRG_PEDIDO_NOTA_NOIVAS%' then
    null;
  -- Se altera��o foi feita pelo site, precisa replicar do WEBSITE para o NOIVAS
  else
    if inserting or updating then
      v_id := :new.numero_da_lista;
      
      v_sql := ' begin proc_sincroniza_lista(' || v_id || ',''WEBSITE'',''NOIVAS''); end; ';
    elsif deleting then
      v_id := :old.numero_da_lista;
      
      v_sql := ' delete from colombo.pedido_nota_noivas where numero_da_lista = ' || v_id || ' and codfil = ' || :old.codfil || ' and numdoc = ' || :old.numdoc || ' and serie = ''' || :old.serie || ''' and dtnota = to_date(''' || to_char(:old.dtnota,'dd/mm/yyyy hh24:mi:ss') || ''',''dd/mm/yyyy hh24:mi:ss'') and coditprod = ' || :old.coditprod;
    end if;
    
    insert into web_nuv_pendencias
      ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
    values
      ( seq_nuv_pendencias.nextval, sysdate, 'WEBSITE.TRG_PEDIDO_NOTA_NOIVAS', v_id, v_sql, 'N', null );
  end if;
  
end trg_pedido_nota_noivas;
/
