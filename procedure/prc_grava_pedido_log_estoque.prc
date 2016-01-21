create or replace procedure prc_grava_pedido_log_estoque
( p_numpedven in number
, p_coditprod in number
, p_deposito  in number
, p_flvdantec in char default null
) as
  
  v_fisico       cad_prodloc.fisico%type := 0;
  v_resfis       cad_prodloc.resfis%type := 0;
  v_reservado    web_nuv_estoque.reservado%type := 0;
  v_codsit       cad_preco_situacao.codsitprod%type;
  v_qtd_agendada ordem_descarga_item.qtdagendada%type;
  v_dt_descarga  ordem_descarga.dt_descarga%type;
  v_qtd_estoque  int_estoque_forne.qtd_estoque%type;
  v_ec_bloq      cad_forne.fl_venda_ec_bloqueada%type;
  
begin
  
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
      v_fisico := null;
      v_resfis := null;
  end;
  
  -- verifica qtdade reservada desde ultima sincronização
  if fnc_retorna_parametro('LOGISTICA','ESTOQUE NUVEM') = 'S' then
    begin
      select reservado
      into   v_reservado
      from   web_nuv_estoque
      where  codfil = p_deposito
      and    coditprod = p_coditprod;
    exception
      when others then
        v_reservado := 0;
    end;
  else
    v_reservado := 0;
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
  
  -- busca agendamentos
  begin
    select trunc(max(ord.dt_descarga)), nvl(sum(nvl(ite.qtdagendada,0)),0)
    into   v_dt_descarga, v_qtd_agendada
    from   ordem_descarga ord, ordem_descarga_item ite
    where  ord.dep_descarga   = p_deposito
    and    ord.status         = 0
    and    ord.dt_descarga   >= trunc(sysdate)
    and    ite.ordem_descarga = ord.ordem_descarga
    and    ite.coditprod      = p_coditprod
    and    ite.qtdagendada    > 0
    and    ite.oc_cancelada  is null;
  exception
    when others then
      v_dt_descarga := null;
      v_qtd_agendada := null;
  end;
  
  -- busca estoque EDI
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
  
  if v_ec_bloq = 'S' then
    v_qtd_estoque := null;
  else
    -- verifica estoque no fornecedor
    begin
      select qtd_estoque
      into   v_qtd_estoque
      from   int_estoque_forne
      where  coditprod = p_coditprod;
    exception
      when no_data_found then
        v_qtd_estoque := null;
    end;
  end if;
  
  -- grava o log de estoque
  insert into mov_itped_web_estoque
    ( codigo, numpedven, deposito
    , coditprod, codsitprod, fisico
    , resfis, dt_descarga, qtdagendada
    , qtd_estoque_edi, data_log, flvdantec
    , nuv_reservado
    )
  values
    ( seq_mov_itped_web_est.nextval, p_numpedven, p_deposito
    , p_coditprod, v_codsit, v_fisico
    , v_resfis, v_dt_descarga, v_qtd_agendada
    , v_qtd_estoque, sysdate, p_flvdantec
    , v_reservado
  ) ;
  
end prc_grava_pedido_log_estoque;
/
