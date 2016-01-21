create or replace procedure prc_gravaparcelas(pcodfil     number,
                                              pnumpedven  number,
                                              pprontuario number,
                                              --dados pagto
                                              pformapagto number,
                                              pcondpgto   varchar2,
                                              pvlentrada  number,
                                              pvljurosfin number,
                                              ppjuros     number,
                                              --dados parcelas
                                              arr_vlrparc  owa_util.ident_arr,
                                              arr_dtvencto owa_util.ident_arr,
                                              --dados cartao
                                              padmcartao      number,
                                              pnumcartao      varchar2,
                                              pcodseg         varchar2,
                                              pdtvctocartao   date,
                                              pnomecartao     varchar2,
                                              pnumCartaoCript varchar2) is
  
  n_aux	       number := 0;
  wcodcon      number;
  wforma       varchar2(4);
  wcodplancart mov_pedido.cod_plan_cart%type;
  wqtdparccart mov_pedido.qtd_parc_cart%type;
  wqtdparcelas number := arr_vlrparc.count;
  wcodeve      number := 12;
  v_prontuario mov_pedido.cod_prontuario%type;
  v_codcli     mov_pedido.codcli%type;
  v_dtpedido   mov_pedido.dtpedido%type;
  v_status     mov_pedido.status%type;
  wvlrjurosfin mov_pedido.vljurosfin%type;
  wvlrdesconto mov_pedido.vldesconto%type;
  v_sql        long;
  
begin
  
  begin
    select p.cod_prontuario, p.codcli, p.dtpedido, p.status
    into   v_prontuario, v_codcli, v_dtpedido, v_status
    from   mov_pedido  p
    where  p.codfil    = pcodfil
    and    p.numpedven = pnumpedven
    and    p.status    < 5;
  exception
    when others then
      raise_application_error(-20903, 'Alteração de endereço de entrega de pedidos liberados ou cancelados não permitida.');
  end;
  
  if pformapagto = 1 then
    wcodplancart := pcondpgto;
    wqtdparccart := wqtdparcelas;
  end if;
  
  if pvljurosfin > 0 then
    wvlrjurosfin := pvljurosfin;
    wvlrdesconto := 0;
  else
    wvlrdesconto := pvljurosfin * -1;
    wvlrjurosfin := 0;
  end if;
  
  delete cxa_lancto
  where  codfil = pcodfil
  and    numped = pnumpedven;
  
  if sql%rowcount > 0 then
    begin
      update mov_pedido
      set    condpgto      = pcondpgto
      ,      vltotal       = vltotal - vljurosfin + wvlrjurosfin
      ,      vlentrada     = pvlentrada
      ,      vljurosfin    = wvlrjurosfin
      ,      vldesconto    = wvlrdesconto
      ,      pjuros        = ppjuros
      ,      qtprc         = wqtdparcelas
      ,      vlprc         = trunc((vltotal - vljurosfin + wvlrjurosfin) / wqtdparcelas,2)
      ,      col_formapgto = pformapagto
      ,      col_admcartao = padmcartao
      ,      cod_plan_cart = wcodplancart
      ,      qtd_parc_cart = wqtdparccart
      ,      condpgtofil   = pcondpgto
      ,      dtalter       = sysdate
      ,      coduseralter  = 0
      ,      identproc     = substr(identproc, 1, 210) || ', ALTERACAO PARCELAS POR ' || pprontuario
      where  codfil        = pcodfil
      and    numpedven     = pnumpedven;
      
      v_sql := ' begin proc_sincroniza_pedido(' || pnumpedven || '); end; ';
      
      insert into web_nuv_pendencias
        ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
      values
        ( seq_nuv_pendencias.nextval, sysdate, 'PRC_GRAVAPARCELAS', pnumpedven, v_sql, 'N', null );
    exception
      when others then
        raise_application_error(-20903, 'Erro atualizando o pedido: ' || sqlerrm);
    end;
  end if;
  
  -- 1 = cartao de credito
  if pformapagto = 1 then
    wforma := '12';
    -- Associa a administradora da CAD_TEF_AUTORIZADORA com os cadastros da CXA_CADCON
    if padmcartao = 3 then
      wcodcon := 10; -- VISA
    elsif padmcartao = 4 then
      wcodcon := 11; -- AMEX
    elsif padmcartao = 5 then
      wcodcon := 12; -- MASTERCARD/CREDICARD
    elsif padmcartao = 19 then
      wcodcon := 14; -- DINNERS
    elsif padmcartao = 20 then
      wcodcon := 41; -- AURA
    elsif padmcartao = 45 then
      wcodcon := 17; -- HIPERCARD
    else
      wcodcon := 0;
    end if;
  -- 2 = boleto bancario
  elsif pformapagto = 2 then
    wforma  := '17';
    wcodcon := null;
    wcodeve := 17;
  -- 3 = deposito bancario
  -- 5 = carne colombo
  elsif pformapagto = 3 or pformapagto = 5 then
    wforma  := '9';
    wcodcon := null;
  end if;
  
  -- 1546 adicionada restricao de pformapagto <> 6 tb.
  
  if pformapagto not in (2, 6) then
    for i in arr_vlrparc.first .. arr_vlrparc.last loop
      n_aux := n_aux + 1;
      
      -- Grava caixa para liberacao pelo Gemco
      insert into cxa_lancto
        ( codfil, datent, datref, codeve, vallan, condpgto
        , filori, codcli, numtit, destit, numnot, numprc
        , vltotal, dtpagto, tpnota, tipoped, filped, serie
        , forma, numdoc, numped, integracrc, numlan, numprccob
        , status, taxadm, datdep, dtvcto, floperautom, codfilcxa
        , flgeraer, codcon, numcartao, codsegcartao, validcartao
        , obslan, numcartaocript
        ) 
      values
        ( pcodfil, to_date(v_dtpedido,'dd/mm/rr'), to_date(v_dtpedido,'dd/mm/rr'), wcodeve, to_number(arr_vlrparc(i)), pcondpgto
        , pcodfil, v_codcli, null, lpad(i, 2, '0'), 0, i
        , null, null, 52, 0, pcodfil, '0'
        , wforma, null, pnumpedven, 'N', 1, i
        , 0, 0, to_date(arr_dtvencto(i),'dd/mm/yyyy'), to_date(arr_dtvencto(i),'dd/mm/yyyy'), null, 0
        , 'N', wcodcon, f_decripta(pnumcartao), to_char(pcodseg), to_char(pdtvctocartao,'MMYY')
        , pnomecartao, pnumCartaoCript
      ) ;
    end loop;
    
    begin
      insert into mov_pedido_web_ce
        ( codfil, numpedven, codcli, data, numCartaoCript
        , numcartao, codsegcartao, admcartao, proc
        )
      values
        ( pcodfil, pnumpedven, null, systimestamp, pnumCartaoCript
        , pnumcartao, pcodseg, padmcartao, 'prc_gravaparcelas'
      ) ;
    exception
      when dup_val_on_index then
        null;
    end;
    
    if n_aux > 0 then
      v_sql := ' begin proc_sincroniza_parcelas(' || pnumpedven || '); end; ';
      
      insert into web_nuv_pendencias
        ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
      values
        ( seq_nuv_pendencias.nextval, sysdate, 'PRC_GRAVAPARCELAS', pnumpedven, v_sql, 'N', null );
    end if;
  end if;
  
end prc_gravaparcelas;
/
