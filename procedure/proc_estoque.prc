create or replace procedure proc_estoque
( p_coditprod     in number
, p_deposito      in number
, p_numlistacas   in number
, p_qtdedisp     out number
, p_diasent      out number
, p_tipo         out varchar2
) is
  
  -- Identifica a disponbilidade de estoque dos itens
  
  v_dat_entrega  date;
  v_dtlista1     date;
  v_dtlista2     date;
  v_qtd_agendada number;
  v_fisico       number := 0;
  v_resfis       number := 0;
  v_reservado    number := 0;
  v_online       number := 0;
  v_fldisponivel char(1) := 'N';
  v_prevenda     char(1) := 'N';
  v_ec_bloq      char(1) := 'N';
  v_codsit       char(2);
  
  v_qtd_maxima_cesta_site number;
  
  cursor agendamentos (p_coditprod number, p_deposito number) is
  select ord.dt_descarga, ite.qtdagendada
  from   ordem_descarga ord, ordem_descarga_item ite
  where  ord.dep_descarga   = p_deposito
  and    ord.status         = 0
  and    ord.dt_descarga   >= trunc(sysdate)
  and    ite.ordem_descarga = ord.ordem_descarga
  and    ite.coditprod      = p_coditprod
  and    ite.qtdagendada    > 0
  and    ite.oc_cancelada  is null
  order  by ord.dt_descarga;
  
begin
  
  begin
    select flprevenda
    into   v_prevenda
    from   web_depositos
    where  codigo = p_deposito;
  exception
    when others then
      v_prevenda := 'N';
  end;
  
  -- quantidade maxima do produto na cesta de compras
  select fnc_retorna_parametro('COMERCIAIS','LIMITE QTD PROD', 'prod1') 
  into   v_qtd_maxima_cesta_site 
  from   dual;
  
  p_qtdedisp := 0;
  p_diasent  := 0;
  p_tipo     := '';
  
  -- verifica estoque fisico e reserva
  begin
    select nvl(fisico,0), nvl(resfis,0)
    into   v_fisico, v_resfis
    from   cad_prodloc
    where  codfil    = p_deposito
    and    coditprod = p_coditprod
    and    tpdepos   = 'D';
  exception
    when no_data_found then
      v_fisico := 0;
      v_resfis := 0;
  end;
  
  if v_resfis >= 0 then
    p_qtdedisp := v_fisico - v_resfis;
  else
    p_qtdedisp := v_fisico;
  end if;
  
  -- verifica qtdade reservada desde ultima sincronização
  if fnc_retorna_parametro('LOGISTICA','ESTOQUE NUVEM') = 'S' then
    begin
      select reservado
      into   v_reservado
      from   web_nuv_estoque
      where  codfil    = p_deposito
      and    coditprod = p_coditprod;
    exception
      when others then
        v_reservado := 0;
    end;
  else
    v_reservado := 0;
  end if;
  
  if v_reservado > 0 then
    p_qtdedisp := p_qtdedisp - v_reservado;
  end if;
  
  -- busca o atributo do produto
  begin
    select codsitprod
    into   v_codsit
    from   cad_preco_situacao
    where  coditprod = p_coditprod;
  exception
    when others then
      v_codsit := null;
  end;
  
  -- Verifica se existem ordens de descarga
  if p_qtdedisp <= 0 and v_codsit <> 'EC' and (v_prevenda = 'S' or (p_coditprod in (529339,529338,517120,522931))) then
    
    begin
      for cr in agendamentos (p_coditprod, p_deposito) loop
        if p_qtdedisp <= v_qtd_maxima_cesta_site then
          p_qtdedisp := p_qtdedisp + nvl(cr.qtdagendada,0);
          p_diasent  := cr.dt_descarga - trunc(sysdate) + 1;
        end if;
        
        -- novo teste para sair do loop quando satisfeita condicao
        if p_qtdedisp >= v_qtd_maxima_cesta_site then
          goto end_loop;
        end if;
      end loop;
      
      <<end_loop>>
      p_tipo     := 'L';
    exception
      when others then
        p_qtdedisp := 0;
        p_diasent  := 0;
        p_tipo     := 'N';
    end;
    
  -- verifica produto encomenda
  elsif p_qtdedisp <= 0 and v_codsit = 'EC' then
    
    -- verifica se estoque é por Webservices
    begin
      select integracao_online
      into   v_online
      from   web_prod
      where  codprod = ( select codprod from web_itprod where coditprod = p_coditprod );
    exception
      when no_data_found then
        v_online := 0;
    end;
    
    -- se for um produto normal, busca estoque em tabelas do EDI
    if v_online = 0 then
      -- Giovani -- Testa se fornecedor está disponível para entregar encomendas
      begin
        select nvl(f.fl_venda_ec_bloqueada,'N')
        into   v_ec_bloq
        from   cad_itprod  i
        join   cad_forne   f on f.codforne = i.codforne
        where  i.coditprod = p_coditprod;
      exception
        when others then
          v_ec_bloq := 'N';
      end;
      --
      if v_ec_bloq = 'S' then
        p_qtdedisp := 0;
      else
        begin
          SELECT NVL(QTD_ESTOQUE, 0)
          INTO   P_QTDEDISP
          FROM   INT_ESTOQUE_FORNE
          WHERE  CODITPROD = P_CODITPROD;
        exception
          when no_data_found then
            p_qtdedisp := 999;
        end;
      end if;
      
      if nvl(p_qtdedisp,0) > 0 then
        p_tipo := 'E';
        prc_cad_forne_prazo(p_coditprod, p_diasent);
      end if;
    else
      p_tipo := 'E';
      p_diasent := fnc_retorna_parametro('INTEGRAÇÃO DISAL','INTERVALO DIAS CESTA');
      
      begin
        select d.fldisponivel
        into   v_fldisponivel
        from   web_prod_depositos d
        where  codprod  = ( select codprod from web_itprod i where i.coditprod = p_coditprod )
        and    deposito = p_deposito;
      exception
        when no_data_found then
            v_fldisponivel := 'N';
      end;
      
      if nvl(v_fldisponivel,'S') = 'S' then
        p_qtdedisp := 1;
      else
        p_qtdedisp := 0;
      end if;
    end if;
  end if;
  
  -- apura prazo para lista de casamento
  if p_numlistacas is not null then
    begin
      select nvl(l.dtentrega1,trunc(sysdate-1)), nvl(l.dtentrega2,trunc(sysdate-1))
      into   v_dtlista1, v_dtlista2
      from   website.dados_identificacao_da_lista l
      where  l.numero_da_lista = p_numlistacas
      and    l.tipo_informacao = 'E';
      
      if v_dtlista1 > v_dtlista2 then
        v_dtlista2 := v_dtlista1;
      end if;
    exception
      when no_data_found then
        raise_application_error(-20903, 'Dados para entrega da Lista de Noivas não existem: ' || p_numlistacas);
    end;
    
    if p_qtdedisp <= 0 and v_codsit <> 'EC' and (v_prevenda = 'S' or p_coditprod in (529339,529338,517120,522931)) then
      begin
        select trunc(max(ord.dt_descarga)), nvl(sum(nvl(ite.qtdagendada,0)),0)
        into   v_dat_entrega, v_qtd_agendada
        from   ordem_descarga ord, ordem_descarga_item ite
        where  ord.dep_descarga   = p_deposito
        and    ord.status         = 0
        and    ord.dt_descarga   >= trunc(sysdate)
        and    ord.dt_descarga   <= v_dtlista2
        and    ite.ordem_descarga = ord.ordem_descarga
        and    ite.coditprod      = p_coditprod
        and    ite.qtdagendada    > 0
        and    ite.oc_cancelada  is null;
        
        p_qtdedisp := p_qtdedisp + v_qtd_agendada;
        p_diasent  := v_dat_entrega - trunc(sysdate) + 1;
        p_tipo     := 'L';
      exception
        when others then
          p_tipo     := 'L';
      end;
    end if;
    
  end if;
  
  if nvl(p_diasent,0) <= 0 then
    p_diasent := 0;
  end if;
  
  if p_qtdedisp <= 0 then
    p_tipo := 'N';
  end if;
  
exception
  when others then
    p_qtdedisp := 0;
    p_diasent  := 0;
    p_tipo     := 'N';
    raise;
end proc_estoque;
/
