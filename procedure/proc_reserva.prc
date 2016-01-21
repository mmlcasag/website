create or replace
procedure proc_reserva(--dados da nota
                       p_codfil in number,
                       p_deposito in number,
                       p_vendedor in number,
                       p_numpedven in number,
                       p_numcontra in number,
                       p_cep in number,
                       p_numlistacas in number,
                       --dados dos itens
                       p_coditprod in owa_util.ident_arr,
                       p_qtcomp in owa_util.ident_arr,
                       p_tpitem in owa_util.ident_arr,
                       --retorno
                       p_diasent out owa_util.ident_arr,
                       p_tipo out owa_util.ident_arr,
                       p_qtedisp out owa_util.ident_arr) is
  
  v_depaux     number;
  v_itsreman   owa_util.ident_arr;
  v_diasrem    number := 0;
  v_nomevend   ven_vend.nome%type;
  v_sql        long;
  v_qtd_resfis number := 0;
  v_codsitprod cad_preco.codsitprod%type;
  
begin
  
  -- busca deposito auxiliar cadastrado
  begin
    select deposito
    into   v_depaux    
    from   web_depositos_remanejos r, web_depositos d
    where  deposito_remanejo = p_deposito
    and    r.deposito = d.codigo
    and    d.fldefault = 'S';     
  exception
    when no_data_found then
      v_depaux := p_deposito;
  end;
  
  for i in 1 .. p_coditprod.last loop
    -- Identifica se o item precisa de reserva
    if p_tpitem(i) = 'PE' then
      -- Verifica estoque
      begin
        proc_estoque(p_coditprod(i), p_deposito, p_numlistacas, p_qtedisp(i), p_diasent(i), p_tipo(i));
      exception
        when no_data_found then
          raise_application_error(-20903, 'Erro reservando o estoque: item('||p_coditprod(i)||') deposito ('||p_deposito||') qtd ('||p_qtedisp(i)||') '||sqlerrm);
      end;
      
      if to_number(p_qtedisp(i)) < to_number(p_qtcomp(i)) then
        -- procura estoque no deposito visinho
        if v_depaux is not null then
          begin
            proc_estoque(p_coditprod(i), v_depaux, p_numlistacas, p_qtedisp(i), p_diasent(i), p_tipo(i));
          exception
            when no_data_found then
              raise_application_error(-20903, 'Erro reservando o estoque: item('||p_coditprod(i)||') deposito ('||v_depaux||') qtd ('||p_qtedisp(i)||') '||sqlerrm);
          end;
          if p_tipo(i) is not null then
            p_qtedisp(i) := 0;
          end if;
        end if;
        
        -- se venda do site e nao tem estoque disponivel, nao vende
        if p_vendedor = 9999 and to_number(p_qtedisp(i)) < to_number(p_qtcomp(i)) then
          raise_application_error(-20903, 'Item sem estoque Disponível: '||p_coditprod(i)||' CEP: '||p_cep);
        end if;
        
        -- se tem estoque disponivel faz o remanejo
        if to_number(p_qtedisp(i)) >= to_number(p_qtcomp(i)) then
          -- adiciona o item ao array
          v_itsreman(v_itsreman.count+1) := i;
          p_tipo(i) := 'R';
          
          -- aumenta o prazo do remanejo
          p_diasent(i) := p_diasent(i) + 6;
          
          if p_diasent(i) > v_diasrem then
            v_diasrem := p_diasent(i);
          end if;
        else
          -- se nao tem estoque e for televendas, manda email para a raquele remanejar
          p_tipo(i) := 'R';
          
          begin
            select nome
            into   v_nomevend
            from   ven_vend
            where  codfil   = p_codfil
            and    codvendr = p_vendedor;
          exception
            when others then
              v_nomevend := p_vendedor;
          end;
          
          send_mail
          ( 'site-erros@colombo.com.br'
          , 'rosaura@colombo.com.br'
          , 'Remanejamento de pedido'
          , 'Remanejar o item '||p_coditprod(i)||' referente ao pedido '||p_numpedven||' para o deposito '||p_deposito||' pois o(a) vendedor(a) '||v_nomevend||' efetuou uma venda sem estoque disponível.'
          ) ;
        end if;
      end if;
      
      v_qtd_resfis := nvl(p_qtcomp(i),0);
      
      if v_qtd_resfis > 0 then
        if fnc_retorna_parametro('LOGISTICA','ESTOQUE NUVEM') = 'S' then
          begin
            update website.web_nuv_estoque
            set    reservado = reservado + v_qtd_resfis
            where  codfil    = p_deposito
            and    coditprod = p_coditprod(i);
            
            if sql%notfound then
              insert into website.web_nuv_estoque
                ( codfil, coditprod, reservado )
              values
                ( p_deposito, p_coditprod(i), v_qtd_resfis );
            end if;
          end;
          
          v_sql := ' begin
                       update website.web_nuv_estoque
                       set    reservado = reservado - ' || v_qtd_resfis || '
                       where  codfil    = ' || p_deposito || '
                       and    coditprod = ' || p_coditprod(i) || ';
                       
                       if sql%notfound then
                         insert into website.web_nuv_estoque
                           ( codfil, coditprod, reservado )
                         values
                           ( ' || p_deposito || ',' || p_coditprod(i) || ',' || v_qtd_resfis || ');
                       end if;
                     end; ';
          
          insert into web_nuv_pendencias
            ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
          values
            ( seq_nuv_pendencias.nextval, sysdate, 'PROC_RESERVA', p_numpedven, v_sql, 'N', null );
        end if;
        
        v_sql := ' update cad_prodloc
                   set    resfis          = resfis + ' || v_qtd_resfis || '
                   where  codfil          = ' || p_deposito     || '
                   and    coditprod       = ' || p_coditprod(i) || '
                   and    tpdepos         = ''D'' ';
        
        insert into web_nuv_pendencias
          ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
        values
          ( seq_nuv_pendencias.nextval, sysdate, 'PROC_RESERVA', p_numpedven, v_sql, 'N', null );
      end if;
      
      select codsitprod
      into   v_codsitprod
      from   cad_preco
      where  codfil    = p_codfil
      and    coditprod = to_number(p_coditprod(i))
      and    rownum    < 2;
      
      if v_codsitprod = 'EC' then
        v_sql := ' update int_estoque_forne
                   set    qtd_estoque = qtd_estoque - ' || nvl(to_number(p_qtcomp(i)),0) || '
                   where  coditprod   = ' || p_coditprod(i);
        
        insert into web_nuv_pendencias
          ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
        values
          ( seq_nuv_pendencias.nextval, sysdate, 'PROC_RESERVA', p_numpedven, v_sql, 'N', null );
      end if;
    end if;
  end loop;
  
  if v_itsreman.count > 0 then
    declare
      --
      v_reserva   mov_pedido.numpedven%type;
      v_praca     cad_filial.praca%type;
      v_dtlimite  date;
      v_dtentrega date := trunc(sysdate);
      --
      v_item      mov_itped.coditprod%type;
      v_qtd       mov_itped.qtcomp%type;
      v_vlr       mov_itped.precounit%type;
      v_dias      number;
      --
      v_rua       cad_prodloc.rua%type;
      v_bloco     cad_prodloc.bloco%type;
      v_apto      cad_prodloc.apto%type;
      v_qtestoque cad_prodloc.fisico%type;
      v_cubagem   cad_prod.cubagmax%type;
      v_peso      cad_prod.pesounit%type;
      v_aliqicms  cad_imptribut.aliquota%type;
      --
      v_vlmercad  number := 0;
      --
      p_status    number := 2;
      p_flvdantec char := 'N';
      --
      v_codprod   cad_prod.codprod%type;
    begin
      -- busca o proximo pedido na sequencia
      select seqped.nextval
      into   v_reserva
      from   dual;
      
      -- busca a praca e data limite do pedido para o deposito
      select praca, dtproc + nvl(nrdiasproposta,0)
      into   v_praca, v_dtlimite
      from   cad_filial
      where  codfil = p_deposito;
      
      -- inclusao do pedido
      insert into mov_pedido
        ( codfil, tipoped, numpedven, codvendr, tpped, encomenda, filorig
        , local, codcli, dtpedido, dtentrega, praca, vloutdesp, vldesconto
        , vlfrete, vlseguro, vlmercad, sitcarga, status, numcontra, tpnota
        , vltotal, codnatop, hrpedido, dtlimite, codfilsolic, flestat
        , nome, fllibfat, numpedsolic, tipopedsolic, fllibfatant, col_dtentregaant
        , col_flencom, identproc
        )
      values
        ( v_depaux, 2, v_reserva, p_vendedor, 'E', null, v_depaux
        , 1, p_deposito, sysdate, v_dtentrega, v_praca, 0, 0
        , 0, 0, v_vlmercad, 0, p_status, p_numcontra, 30
        , v_vlmercad, 15, sysdate, v_dtlimite, p_codfil, 'S'
        , null, 'N', p_numpedven, 0, 'N', v_dtlimite
        , 'N', 'proc_reserva'
      ) ;
      
      for li in v_itsreman.first .. v_itsreman.last loop
        -- separa a string do item para remanejo
        v_item := p_coditprod(v_itsreman(li));
        v_qtd  := p_qtcomp(v_itsreman(li));
        v_dias := p_diasent(v_itsreman(li));
        
        -- busca localizacao na loja
        begin
          select rua, bloco, apto
          into   v_rua, v_bloco, v_apto
          from   cad_prodloc
          where  codfil    = p_codfil
          and    tpdepos   = 'D'
          and    coditprod = v_item;
        exception
          when others then
            null;
        end;
        
        -- busca estoque no deposito
        begin
          select fisico
          into   v_qtestoque
          from   cad_prodloc
          where  codfil    = v_depaux
          and    tpdepos   = 'D'
          and    coditprod = v_item;
        exception
          when others then
            v_qtestoque := 0;
        end;
        
        begin
          select d.altura * d.largura * d.comp / 1000000, d.pesounit
          into   v_cubagem, v_peso
          from   cad_prod d, cad_itprod a
          where  a.codprod   = d.codprod
          and    a.coditprod = v_item;
        exception
          when others then
            v_cubagem := 0;
            v_peso := 0;
        end;
        
        select codprod
        into   v_codprod
        from   cad_itprod
        where  coditprod = v_item;
        
        select cuei
        into   v_vlr
        from   ven_prodfil
        where  codfil in ( select codfilcust from cad_filial where codfil = p_codfil )
        and    codprod = v_codprod;
        
        select cad_imptribut.aliquota
        into   v_aliqicms
        from   cad_imptribut, cad_itprod, cad_prod, cad_filial cad_filial_orig, cad_filial cad_filial_dest
        where  cad_prod.codprod           = cad_itprod.codprod
        and    cad_filial_orig.codfil     = v_depaux
        and    cad_filial_dest.codfil     = p_deposito
        and    cad_imptribut.estdest      = cad_filial_dest.estado
        and    cad_imptribut.estorig      = cad_filial_orig.estado
        and    cad_itprod.coditprod       = v_item
        and    cad_imptribut.tpimp        = 'I'
        and    cad_imptribut.codimp       = cad_prod.codicms
        and    cad_imptribut.codgrptpnota = 2;
        
        insert into mov_itped
          ( codfil, tipoped, numpedven, coditprod, item, codcli, qtcomp, precounit
          , aliqicm, aliqicmsub, aliqicmred, aliqicmsubuf, filorig
          , cubagem, dpi, peso, status, tpnota, medger, dtpedido
          , local, tpdepos, flvdantec, codembal, qtreceb, qtemb, rua, bloco
          , apto, flvdantecant, numpedcomp, qtestoque, vltotitem, fllibfat
          )
        values
          ( v_depaux, 2, v_reserva, v_item, li, p_deposito, v_qtd, v_vlr
          , v_aliqicms, 0, 0, 0, v_depaux
          , v_cubagem, 0, v_peso, 4, 30, 0, sysdate
          , 1, 'D', p_flvdantec, 0, 0, 1, v_rua, v_bloco
          , v_apto, p_flvdantec, null, v_qtestoque, v_qtd*v_vlr, 'S'
        ) ;
        
        if fnc_retorna_parametro('LOGISTICA','ESTOQUE NUVEM') = 'S' then
          begin
            update website.web_nuv_estoque
            set    reservado = reservado + v_qtd
            where  codfil    = v_depaux
            and    coditprod = v_item;
            
            if sql%notfound then
              insert into website.web_nuv_estoque
                ( codfil, coditprod, reservado )
              values
                ( v_depaux, v_item, v_qtd );
            end if;
          end;
          
          v_sql := ' begin
                       update website.web_nuv_estoque
                       set    reservado = reservado - ' || v_qtd || '
                       where  codfil    = ' || v_depaux || '
                       and    coditprod = ' || v_item || ';
                       
                       if sql%notfound then
                         insert into website.web_nuv_estoque
                           ( codfil, coditprod, reservado )
                         values
                           ( ' || v_depaux || ',' || v_item || ',' || v_qtd || ');
                       end if;
                     end; ';
          
          insert into web_nuv_pendencias
            ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
          values
            ( seq_nuv_pendencias.nextval, sysdate, 'PROC_RESERVA', p_numpedven, v_sql, 'N', null );
        end if;
        
        v_sql := ' update cad_prodloc
                   set    resfis          = resfis + ' || v_qtd || '
                   where  codfil          = ' || v_depaux       || '
                   and    coditprod       = ' || v_item         || '
                   and    tpdepos         = ''D'' ';
        
        insert into web_nuv_pendencias
          ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
        values
          ( seq_nuv_pendencias.nextval, sysdate, 'PROC_RESERVA', p_numpedven, v_sql, 'N', null );
        
        v_vlmercad := v_vlmercad + v_qtd * v_vlr;
      end loop;
      
      update mov_pedido
      set    vlmercad  = v_vlmercad
      ,      vltotal   = v_vlmercad
      where  codfil    = v_depaux
      and    tipoped   = 2
      and    numpedven = v_reserva;
      
      v_sql := ' begin proc_sincroniza_pedido(' || v_reserva || '); end; ';
      
      insert into web_nuv_pendencias
        ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
      values
        ( seq_nuv_pendencias.nextval, sysdate, 'PROC_RESERVA', p_numpedven, v_sql, 'N', null );
    exception
      when others then
        send_mail('site-erros@colombo.com.br', 'site-erros@colombo.com.br', 'REMANEJO - LojaVirtual - ERRO DE EXECUCAO', sqlerrm||' - '||p_numpedven);
        raise_application_error(-20903, 'Erro no remanejamnento dos itens do '||v_depaux||' para '||p_deposito||' '||sqlerrm);
    end;
  end if;
  
end proc_reserva;
/
