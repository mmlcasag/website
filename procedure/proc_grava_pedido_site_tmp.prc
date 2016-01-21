CREATE OR REPLACE PROCEDURE website.PROC_GRAVA_PEDIDO_SITE_TMP( -- PEDIDO
                                                     pcodfil         in number, -- Filial da venda
                                                     pprontuario     in number, -- Prontuario do pedido
                                                     pvendedor       in number, -- Prontuario da venda
                                                     pcodcli         in number, -- Codigo do cliente
                                                     pendent         in number, -- Codigo do endereco de entrega
                                                     pdeposito       in number, -- Codigo do deposito de saida ou null para calcular
                                                     pdtfaturamento  in date, -- Data para faturar o pedido
                                                     pcodfonte       in varchar2, -- Codigo da midia do pedido
                                                     pnumcontra      in number, -- Numero de pedido (numcontra)
                                                     pnumlistacasam  in number, -- Numero da lista de casamento
                                                     pobs            in varchar2, -- Observacoes do pedido
                                                     pvlentrada      in number, -- Valor da entrada
                                                     pvlfrete        in number, -- Valor total do frete
                                                     pvlguia         in number, -- Valor total da guia do frete
                                                     pvlaliquota     in number, -- Valor total da aliquota do frete
                                                     pdiasentregamin in number, -- Numero minimo de dias para a entregua
                                                     pdiasentregamax in number, -- Numero maximo de dias para a entregua
                                                     ptransportadora in number, -- Empresa que fara a entrega da mercadoria, S:Correio, X:Sedex, N:Itapemirim, P:Propria
                                                     pvltotitens     in number, -- Valor total das mercadorias adquiridas (preco unit x qtcomp)
                                                     pvljurosfin     in number, -- Valor do juro a ser gravado na capa
                                                     pvlTaxaJuros    in number, -- Taxa de Juros (mÈdia ponderada)
                                                     pvltotal        in number, -- Valor total do pedido (com juros, descontos e frete)
                                                     pformapagto     in number, -- Forma de pagamento (cartao, boleto)
                                                     pcondpgto       in varchar2, -- Condicao de Pagamento cadastrada pela adm.
                                                     ppjuros         in number, -- Percentual de juros para a compra
                                                     -- DADOS DO CARTAO
                                                     padmcartao       in number, -- Codigo da administradora do cartao
                                                     pnumcartao       in varchar2, -- Numero do cartao de credito
                                                     pnumCartaoCripto in varchar2, -- Numero do cartao de credito criptografado
                                                     pcodseg          in number, -- Codigo de seguranca
                                                     pnomecartao      in varchar2, -- Nome do cliente no cartao
                                                     pdtvctocartao    in date, -- Data de vencimento do cartao
                                                     -- ITENS
                                                     pcoditprod      in owa_util.ident_arr, -- Codigo dos itens
                                                     pseqgarantia    in owa_util.ident_arr, -- Sequencia da capa da garantia
                                                     ptpitem         in owa_util.ident_arr, -- Identifica se o item e de pedido (PE) ou garantia (G:GA, T:TG, M:GM)
                                                     pqtcomp         in owa_util.ident_arr, -- Quantidade comprada de cada item
                                                     pprecounit      in owa_util.ident_arr, -- Preco unitario de cada
                                                     pvldesconto     in owa_util.ident_arr, -- Valor do Desconto por item
                                                     pdescontoweb    in owa_util.ident_arr, -- Desconto web por item - WEB_DESCONTO
                                                     pItemVlJurosFin in owa_util.ident_arr, -- Valor de juros por item
                                                     -- PARCELAS
                                                     pdtvencto    in owa_util.ident_arr, -- Vencimento da parcela
                                                     pvlrparcela  in owa_util.ident_arr, -- Valor da parcela
                                                     pBancoDebito in number,
                                                     pCodEmailMkt in number,
                                                     -- log de venda
                                                     pLogPedido in varchar,
                                                     -- VARIAVEIS DE RETORNO
                                                     pnumpedven out number, -- Numero do pedido no Gemco
                                                     pmens      out varchar2, -- Mensagem de retorno
                                                     -- VARIAVEIS PARA OS LIVROS NO SITE
                                                     pCodPedAgrupado in number default null,
                                                     pDesmembrado    in varchar2 default null,
                                                     pFilialRetirar  IN integer DEFAULT NULL,
                                                     -- VARIAVEIS
                                                     pPerfil   in number default null,
                                                     pOrigem   in varchar2 default null,
                                                     pPortal   IN NUMBER DEFAULT NULL,
                                                     pIsBrinde IN owa_util.ident_arr,
                                                     pVlicmret in number default null, -- Valor ICMS Adicional
                                                     -- variaveis de agendamento
                                                     p_data_agendamento_entrega  in date default null,
                                                     p_turno_agendamento_entrega in varchar default null,
                                                     p_jsession                  in varchar2 default null,
                                                     p_refaturamento             in varchar2 default 'N',
                                                     -- parâmetros do televendas
                                                     p_frete_tele in number default null,
                                                     -- central de descontos
                                                     p_numcupom    in varchar2 default null,
                                                     p_tip_desc    in varchar2 default null,
                                                     p_per_desc    in number default null,
                                                     p_vlr_desc    in number default null,
                                                     pvldesccapa   in number default 0,
                                                     p_venc_boleto in date default null) is

  -- Procedimento de Gravacao do pedido na base corporativa
  -- Analista: Scheila Ariotti
  -- Desenvolvido em fev/2005
  --
  -- 25/11/2008   JÙse   alteraÁ¿o na busca das alÌquotas
  --
  -- Arrays de itens e parcelas
  arr_diasent   owa_util.ident_arr;
  arr_tpestitem owa_util.ident_arr;
  arr_pqtedisp  owa_util.ident_arr;
  wnumparcelas  number := pvlrparcela.count;

  -- Variaveis da capa do pedido
  wdtpedido         mov_pedido.dtpedido%type;
  wprontuario       mov_pedido.cod_prontuario%type;
  wvendedor         mov_pedido.cod_prontuario%type;
  wcodfilvendr      vendedores.fun_estab%type;
  wdtentrega        mov_pedido.dtentrega%type;
  wdtentrega_lista1 mov_pedido.dtentrega%type;
  wdtentrega_lista2 mov_pedido.dtentrega%type;
  wcep_lista        dados_identificacao_da_lista.cep%type;
  wpraca            cad_cep.praca%type;
  wdep              mov_pedido.filorig%type;
  wstatus           mov_pedido.status%type;
  wcodplancart      mov_pedido.cod_plan_cart%type;
  wqtdparccart      mov_pedido.qtd_parc_cart%type;
  wvlmercad         mov_pedido.vlmercad%type := 0;
  wvlrjurosfin      mov_pedido.vljurosfin%type;
  wvlrdesconto      mov_pedido.vldesconto%type;
  westorig          cad_filial.estado%type;
  westdest          cad_filial.estado%type;
  wobs              varchar2(1000);
  d_dtultmcomp      date;
  
  -- Variaveis dos itens do pedido
  wdpi        mov_itped.dpi%type;
  wvlitem     mov_itped.precounit%type;
  wtotitem    mov_itped.vltotitem%type;
  wtotdesc    mov_itped.vldescitem%type;
  waliqicms   cad_imptribut.aliquota%type;
  wcubagmax   cad_prod.cubagmax%type;
  wunidade    cad_prod.unidade%type;
  windmedger  ven_prodfil.indmedger%type;
  wcmup       ven_prodfil.cmup%type;
  wcodsitprod cad_preco.codsitprod%type;
  wqtdvolume  cad_prod.qtdvolume%type;
  wpeso       cad_prod.pesounit%type;
  -- Variaveis de garantia
  wtpnotagar    number;
  wvlgarantpror number;
  wnumpedvengar number;
  -- Gerais
  wtemgarantia char(1);
  --
  v_codvendr mov_pedido.codvendr%type;
  v_fllibfat char(1);
  --
  v_aliqred  cad_imptribut.aliquota%type;
  v_ctf      cad_imptribut.ctf%type;
  waliqsub   cad_imptribut.aliquota%type;
  waliqsubuf cad_imptribut.aliquota%type;
  wcolchao   varchar2(01);
  --
  v_cep_e   cad_endcli.cep%type;
  v_uf_e    cad_endcli.estado%type;
  v_codprod cad_prod.codprod%type;
  --
  v_coddesconto number;
  v_camppreco   number;
  --
  v_codfildist      cad_filial.codfildist%type;
  v_cmup_cd         number;
  v_preco_reposicao number;
  --
  v_vlfrete    number;
  v_diasmin    number;
  v_diasmax    number;
  v_transp     number;
  v_aliquota   number;
  v_vlrguia    number;
  v_frete_loja number := null;
  v_frete_tele number := p_frete_tele;
  v_vltotal    number;
  --
  v_codlinha        web_linha.codlinha%type;
  v_versao_contrato mov_pedido_web.versao_contrato%TYPE;

  arr_vlfrete owa_util.ident_arr;
  arr_diasmin owa_util.ident_arr;
  arr_diasmax owa_util.ident_arr;
  arr_transp  owa_util.ident_arr;
  arr_filiais owa_util.ident_arr;

  v_rat_frete_in  varchar2(2000);
  v_rat_frete_out varchar2(2000);
  arr_rat_frete   owa_util.ident_arr;
  
  v_mais_vendido_portal web_mais_vendidos_integr%rowtype;
  v_cod_mais_vendido    web_mais_vendidos_integr.codigo%type;
  v_portal              web_integr_portal.portal_id%type;
  v_cod_brinde          web_itprod_brinde.cod_brinde%type;
  v_regra_margem        cad_familia.regra_cmv_margem%type;
  v_codfam              cad_familia.codfam%type;
  
  v_sql                 clob;
  
begin
  
  wdtpedido   := trunc(sysdate);
  wprontuario := pprontuario;
  wvendedor   := pprontuario;
  v_vltotal   := pvltotal;
  
  wdtentrega := pdtfaturamento;
  if p_data_agendamento_entrega is not null then
    wdtentrega := p_data_agendamento_entrega;
  end if;
  
  pmens := pmens || ' DtPedido:' || wdtpedido || ' DtFaturamento: ' || wdtentrega;
  
  if pvljurosfin >= 0 then
    wvlrjurosfin := pvljurosfin;
    wvlrdesconto := pvldesccapa;
  else
    wvlrdesconto := pvldesccapa + (pvljurosfin * -1);
    wvlrjurosfin := 0;
  end if;
  
  begin
    select fun_estab
    into   wcodfilvendr
    from   vendedores
    where  fun_pront = wprontuario;
  exception
    when no_data_found then
      wcodfilvendr := 400;
  end;
  
  begin
    select codvendr
    into   v_codvendr
    from   ven_vend
    where  codfil = wcodfilvendr
    and    codfunc = wprontuario
    and    nvl(status,0) = 0;
  exception
    when others then
      begin
        select codvendr
        into   v_codvendr
        from   ven_vend
        where  codfil = 400
        and    codfunc = wprontuario
        and    nvl(status, 0) = 0;
      exception
        when others then
          v_codvendr := 9998;
      end;
  end;
  
  pmens := pmens || ' vendedor: ' || wprontuario;
  
  wobs := replacechars(pobs);
  
  -- Se for lista de casamento, a data de entrega passa a ser a definida pelos noivos
  if pnumlistacasam is not null then
    wobs := wobs || util.test(wobs is not null, ', ') || 'LISTA CASAMENTO: ' || pnumlistacasam;
    declare
      wnomenoivo date;
      wnomenoiva date;
    begin
      select l.dtentrega1, l.dtentrega2, l.cep
      into   wdtentrega_lista1, wdtentrega_lista2, wcep_lista
      from   website.dados_identificacao_da_lista l
      where  l.numero_da_lista = pnumlistacasam
      and    l.tipo_informacao = 'E';
      
      select l.nome_do_noivo, l.nome_da_noiva
      into   wnomenoivo, wnomenoiva
      from   website.listas_de_noivas l
      where  l.numero_da_lista = pnumlistacasam;
      
      -- pega o primeiro nome do noivo e noiva caso exista
      if instr(wnomenoivo,' ') > 0 then
        wnomenoivo := substr(wnomenoivo, 1, instr(wnomenoivo, ' '));
      end if;
      
      if instr(wnomenoiva, ' ') > 0 then
        wnomenoiva := substr(wnomenoiva, 1, instr(wnomenoiva, ' '));
      end if;
      
      wobs := wobs || ' NOIVO: ' || wnomenoivo || ' NOIVA: ' || wnomenoiva;
    exception
      when others then
        null;
    end;
  end if;
  
  -- ARMAZENA OS ARRAYS
  -- Os valores dos parametros de itens e parcelas tem o caracter # no inicio, no fim da string e entre cada valor
  pmens := pmens || ' ' || pcoditprod.count || ' itens no pedido';
  
  if pcoditprod.count = 0 then
    raise_application_error(-20903, 'O Pedido nao possui itens.');
  end if;
  
  for i in pcoditprod.first .. pcoditprod.last loop
    if ptpitem(i) = 'PE' then
      wvlmercad := wvlmercad + (pprecounit(i) + pvldesconto(i)) * pqtcomp(i);
    end if;
    
    pmens := pmens || ' Item(' || i || '):' || pcoditprod(i) || ' QtComp:' ||
             pqtcomp(i) || ' TpItem:' || ptpitem(i) || ' Preco:' ||
             pprecounit(i) || '; ';
  end loop;
  
  pmens := pmens || wnumparcelas || ' parcelas';
  
  -- GRAVA O PEDIDO NO GEMCO
  -- Verifica se existe algum pedido com o mesmo numcontra para a loja corrente
  /*
  begin
    select 'S'
    into   wjaexisteped
    from   mov_pedido
    where  codfil    = pcodfil
    and    numcontra = pnumcontra
    and    status   != 9
    and    rownum    = 1;
    
    raise_application_error(-20903, 'Numero de contrato duplicado: ' || pnumcontra);
  exception
    when no_data_found then
      null;
  end;
  */
  
  pmens := pmens || ' numcontra:' || pnumcontra;
  
  -- Busca o proximo numero de pedido
  select seqped.nextval into pnumpedven from dual;
  
  d_dtultmcomp := sysdate;
  
  -- atualiza data da ultima compra para o gemco
  update cad_cliente set dtultmcomp = d_dtultmcomp where codcli = pcodcli;
  
  v_sql := ' update cad_cliente set dtultmcomp = to_date(''' || to_char(d_dtultmcomp,'dd/mm/yyyy hh24:mi:ss') || ''',''dd/mm/yyyy hh24:mi:ss'') where codcli =  ' || pcodcli;
  
  insert into web_nuv_pendencias
    ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
  values
    ( seq_nuv_pendencias.nextval, sysdate, 'PROC_GRAVA_PEDIDO_SITE_TMP', pnumpedven, v_sql, 'N', null );
  
  pmens := pmens || ' Cliente ' || pcodcli;
  
  -- Log de entrada do cart¿o de crÈdito
  begin
    if pcodfil = 400 then
      insert into mov_pedido_web_ce
        (codfil,
         numpedven,
         codcli,
         data,
         numCartaoCript,
         numcartao,
         codsegcartao,
         admcartao,
         proc)
      values
        (pcodfil,
         pnumpedven,
         pcodcli,
         systimestamp,
         pnumCartaoCripto,
         pnumcartao,
         pcodseg,
         padmcartao,
         'proc_grava_pedido');
    end if;
  exception
    when others then
      null;
  end;
  
  -- RESERVA A MERCADORIA
  select cep, estado
  into   v_cep_e, v_uf_e
  from   cad_endcli
  where  codcli = pcodcli
  and    codend = pendent;
  
  if nvl(pdeposito,0) = 0 then
    -- verifica se o deposito È o mesmo de todos os produtos do pedido
    for cr in 1 .. pcoditprod.last loop
      select codprod
      into   v_codprod
      from   cad_itprod
      where  coditprod = pcoditprod(cr);
      
      if wdep is null then
        wdep := f_deposito(v_cep_e, v_codprod);
      elsif wdep <> f_deposito(v_cep_e, v_codprod) then
        raise_application_error(-20903, 'Todos os produtos devem pertencer ao mesmo deposito ');
      end if;
    end loop;
  else
    wdep := pdeposito;
  end if;
  
  begin
    proc_reserva(pcodfil,
                 wdep,
                 v_codvendr,
                 pnumpedven,
                 pnumcontra,
                 v_cep_e,
                 pnumlistacasam,
                 pcoditprod,
                 pqtcomp,
                 ptpitem,
                 arr_diasent,
                 arr_tpestitem,
                 arr_pqtedisp);
    
    pmens := pmens || ' Itens Reservados';
    
    -- verifica se houve remanejo e coloca o libfat para N
    v_fllibfat := 'S';
    
    for i in 1 .. arr_tpestitem.last loop
      if arr_tpestitem(i) in ('E', 'R', 'L') then
        pmens      := pmens || ' ' || pcoditprod(i) || '-' || arr_tpestitem(i);
        v_fllibfat := 'N';
      end if;
    end loop;
    
    if v_cep_e = wcep_lista then
      if wdtentrega_lista1 is not null and wdtentrega_lista1 >= wdtentrega then
        wdtentrega := wdtentrega_lista1;
      elsif wdtentrega_lista2 is not null and wdtentrega_lista2 >= wdtentrega then
        wdtentrega := wdtentrega_lista2;
      end if;
    end if;
    
    pmens := pmens || ' Fim Reservada';
  exception
    when others then
      raise_application_error(-20903,'Erro na reserva dos itens: ' || sqlerrm);
  end;
  
  pmens := pmens || ' ' || ' FLLIBFAT - ' || v_fllibfat;
  
  -- Grava os dias informados para a entrega do pedido
  declare
    v_coditpr owa_util.ident_arr;
    v_qtdcomp owa_util.ident_arr;
  begin
    if pvlguia is null then
      begin
        for i in pcoditprod.first .. pcoditprod.last loop
          if ptpitem(i) = 'PE' then
            v_coditpr(v_coditpr.count) := pcoditprod(i);
            v_qtdcomp(v_qtdcomp.count) := pqtcomp(i);
          end if;
        end loop;
      
        -- Projeto Retira Loja
        proc_calcula_frete(v_cep_e,
                           wdep,
                           v_coditpr,
                           v_qtdcomp,
                           wvlmercad,
                           v_vlfrete,
                           v_diasmin,
                           v_diasmax,
                           v_transp,
                           v_aliquota,
                           v_vlrguia,
                           pnumlistacasam,
                           pDeposito,
                           pFilialRetirar,
                           false,
                           false,
                           arr_vlfrete,
                           arr_diasmin,
                           arr_diasmax,
                           arr_transp,
                           arr_filiais,
                           v_frete_loja,
                           v_frete_tele,
                           1);
      exception
        when others then
          v_vlfrete  := nvl(v_frete_tele, nvl(pvlfrete, 0));
          v_vlrguia  := nvl(pvlguia, 0);
          v_aliquota := nvl(pvlaliquota, 0);
          v_diasmin  := nvl(pdiasentregamin, 0);
          v_diasmax  := nvl(pdiasentregamax, 0);
          v_transp   := nvl(ptransportadora, 0);
      end;
    else
      v_vlfrete  := nvl(v_frete_tele, nvl(pvlfrete, 0));
      v_vlrguia  := nvl(pvlguia, 0);
      v_aliquota := nvl(pvlaliquota, 0);
      v_diasmin  := nvl(pdiasentregamin, 0);
      v_diasmax  := nvl(pdiasentregamax, 0);
      v_transp   := nvl(ptransportadora, 0);
    end if;
    
    -- Identifica a praca de logistica de entrega
    -- A partir do transportadora retornada na simulaÁ¿o de fretes
    if pFilialRetirar is not null then
      begin
        select praca_retira
        into   wpraca
        from   cad_filial
        where  codfil = pFilialRetirar;
      exception
        when others then
          wpraca := null;
          send_mail('site-erros@colombo.com.br',
                    'site-erros@colombo.com.br',
                    '[RETIRA LOJA] PRAÇA NÃO CADASTRADA',
                    'Praça para a filial ' || pFilialRetirar ||
                    ' não cadastrada pela LOGÍSTICA');
      end;
    end if;
    
    if wpraca is null then
      begin
        select praca
        into   wpraca
        from   fretes_transportadora
        where  codigo = v_transp;
      exception
        when others then
          wpraca := null;
      end;
    end if;
    
    begin
      select versao
      into   v_versao_contrato
      from   web_texto_pagina
      where  codaba = 'contrato_compra'
      and    idioma = 'portugues';
    exception
      when others then
        v_versao_contrato := '';
    end;
    
    INSERT INTO mov_pedido_web
      (numpedven,
       diasentmin,
       diasentmax,
       transp,
       prontuario_vendedor,
       codfil_vendedor,
       vlfrete_real,
       banco,
       codEmailMkt,
       log_pedido,
       origem,
       cod_integr_portal,
       data_agendamento_entrega,
       turno_agendamento_entrega,
       cod_frete_transportadora,
       versao_contrato,
       jsession,
       fl_refaturamento,
       numcupom,
       tip_desc,
       per_desc,
       vlr_desc)
    values
      (pnumpedven,
       v_diasmin,
       v_diasmax,
       v_transp,
       wvendedor,
       wcodfilvendr,
       v_vlfrete,
       pBancoDebito,
       pCodEmailMkt,
       plogPedido || ', pDesmembrado=' || pDesmembrado,
       pOrigem,
       pPortal,
       p_data_agendamento_entrega,
       p_turno_agendamento_entrega,
       v_transp,
       v_versao_contrato,
       p_jsession,
       p_refaturamento,
       p_numcupom,
       p_tip_desc,
       p_per_desc,
       p_vlr_desc);
  exception
    when others then
      send_mail('site-erros@colombo.com.br',
                'site-erros@colombo.com.br',
                '[LojaVirtual] ERRO insert mov_pedido_web',
                pnumpedven || ', ' || v_diasmin || ', ' || v_diasmax || ', ' ||
                v_transp || ', ' || wvendedor || ', ' || wcodfilvendr ||
                ' - ' || sqlerrm);
  end;
  
  if p_numcupom is not null then
    insert into web_cupom_utilizacoes
      ( id
      , codigo
      , codclilv
      , numpedven
      )
    values
      ( ( select nvl(max(id), 0) + 1 from web_cupom_utilizacoes )
      , ( p_numcupom )
      , ( select codclilv from web_usuarios where codcli_gemco = pcodcli )
      , pnumpedven
    ) ;
  end if;
  
  -- Calculo de rateio de frete
  begin
    for i in pcoditprod.first .. pcoditprod.last loop
      v_rat_frete_in := v_rat_frete_in || ((to_number(pprecounit(i)) + (to_number(pvldesconto(i)) / to_number(pqtcomp(i)))) * to_number(pqtcomp(i))) * 100 || '#';
    end loop;
    
    prc_rateia_frete(v_vlfrete * 100, v_rat_frete_in, v_rat_frete_out);
    
    arr_rat_frete := f_ret_array(v_rat_frete_out);
  end;
  
  -- Selecionar frota propria quando entrega e em cidades proximas de lojas fisicas
  if nvl(wpraca,0) = 0 then
    begin
      select nvl(cf.praca, 0)
        into wpraca
        from cad_filial        fil,
             cidades_freteiros cf,
             cad_cidade        cid,
             cad_cep           cep
       where cep.cep = v_cep_e
         and trim(upper(cid.local)) = trim(upper(cep.local))
         and trim(upper(cid.uf)) = trim(upper(cep.uf))
         and cf.cod_local = cid.codlocal
         and cf.status = 0
         and fil.codfil = cf.codfil;
    exception
      when others then
        wpraca := 0;
    end;
  end if;
  
  -- seleciona a praca se nao foi preenchida
  if nvl(wpraca, 0) = 0 then
    begin
      select nvl(praca,0)
        into wpraca
        from cad_pracacep
       where v_cep_e between cepinic and cepfim;
    exception
      when others then
        begin
          select nvl(praca, 0)
            into wpraca
            from cad_cep
           where cep = v_cep_e;
        exception
          when others then
            wpraca := 0;
        end;
    end;
  end if;
  
  pmens := pmens || ' VlEntrada:' || pvlentrada;
  
  -- Identifica a condicao de pagamento a ser gravada na coluna codplancart (chave da cad_condpg)
  if pformapagto = 1 then
    wcodplancart := pcondpgto;
    wqtdparccart := wnumparcelas;
  end if;
  
  wstatus := 3;
  
  pmens := pmens || 'Status: ' || wstatus || ' VlTotal:' || v_vltotal || ' CondPgto:' || pcondpgto;
  
  -- Capa do pedido
  declare
    
    pvlvdvista      number := pvltotitens + v_vlfrete;
    pcoduser        number := 0;
    vCodPedAgrupado number := nvl(pCodPedAgrupado, pnumpedven);
    vRetirarLoja    varchar2(1) := 'N';
    
  begin
    
    if pFilialRetirar is not null then
      vRetirarLoja := 'S';
    end if;
    
    insert into mov_pedido
      (
       --campos do gemco
       codfil,
       tipoped,
       numpedven,
       codvendr,
       tpped,
       filorig,
       local,
       condpgto,
       codcli,
       codtransp,
       dtpedido,
       dtentrega,
       endcob,
       endent,
       praca,
       vldespaces,
       vloutdesp,
       vldespfin,
       vldesconto,
       vlentrada,
       vlfrete,
       vlseguro,
       vlmercad,
       sitcarga,
       status,
       vljurosfin,
       tpnota,
       flfatura,
       vltotal,
       nome,
       codmodal,
       pjuros,
       vlvdvista,
       vliof,
       vlvdliq,
       digcontrafin,
       hrpedido,
       qtprc,
       tpfrete,
       numcontrafin,
       fllibfat,
       vltotalind,
       redutorbaseicms,
       obs,
       coduser,
       vlprc,
       identproc,
       vlmontagem,
       flinstalaterceiro,
       vlfreteterceiro,
       codcargo,
       regracreditscore,
       tpcontrato,
       seriecontrafin,
       vlirrf,
       codlista,
       codconvenio,
       codfunc,
       codfiltransffat,
       flentvar,
       vljuros,
       codclipublicidade,
       codendclipublicidade,
       vlpiscofinscsll,
       codfonte,
       pmargrent,
       vltotitemacum,
       --campos para o site
       numcontra,
       col_formapgto,
       col_admcartao,
       col_dtentregaant,
       col_numlistnoiva,
       cod_prontuario,
       cod_plan_cart,
       qtd_parc_cart,
       fllibfatant,
       condpgtofil,
       COL_TAXAJUROS,
       NUMPEDVENAGRUP,
       col_entregar_loja,
       col_aliquota,
       col_vlrguia,
       vlicmret,
       dtlimite)
    values
      (
       --campos do gemco
       pcodfil,
       0,
       pnumpedven,
       v_codvendr,
       'E',
       wdep,
       1,
       pcondpgto,
       pcodcli,
       v_transp,
       wdtpedido,
       wdtentrega,
       0,
       pendent,
       wpraca,
       0,
       0,
       0,
       wvlrdesconto,
       pvlentrada,
       v_vlfrete,
       0,
       wvlmercad,
       0,
       wstatus,
       wvlrjurosfin,
       52,
       'P',
       v_vltotal,
       '1',
       '1',
       ppjuros,
       pvlvdvista,
       0,
       pvlvdvista,
       0,
       sysdate,
       wnumparcelas,
       1,
       0,
       v_fllibfat,
       0,
       0,
       wobs,
       pcoduser,
       trunc(v_vltotal / wnumparcelas, 2),
       'LOJA VIRTUAL - PROC_GRAVA_PEDIDO_SITE_TMP,' ||
       to_char(sysdate, 'dd/mm/yyyy hh24:mi'),
       0,
       'N',
       0,
       0,
       0,
       'C',
       '0',
       0,
       0,
       0,
       0,
       pcodfil,
       'N',
       0,
       0,
       0,
       0,
       pcodfonte,
       0,
       pvltotitens,
       --campos para o site
       pnumcontra,
       pformapagto,
       padmcartao,
       wdtentrega,
       pnumlistacasam,
       wprontuario,
       wcodplancart,
       wqtdparccart,
       'N',
       pcondpgto,
       pvlTaxaJuros,
       vCodPedAgrupado,
       vRetirarLoja,
       v_aliquota,
       v_vlrguia,
       pVlicmret,
       p_venc_boleto);
    
    v_sql := ' begin proc_sincroniza_pedido(' || pnumpedven || '); end; ';
    
    insert into web_nuv_pendencias
      ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
    values
      ( seq_nuv_pendencias.nextval, sysdate, 'PROC_GRAVA_PEDIDO_SITE_TMP', pnumpedven, v_sql, 'N', null );
    
    -- se o cliente optou por retirar o pedido na loja, chama procedure que realiza o processo
    if vRetirarLoja = 'S' then
      PROC_ENTREGAR_PEDIDO_LOJA(pnumpedven, pFilialRetirar);
    end if;
    
    if pcodfil = 400 then
      v_sql := ' insert into log_prog_alt_pedidos
                   ( pedido, programa, tabela, data, valor )
                 values
                   ( ' || pnumpedven || ', ''PROC_GRAVA_PEDIDO_SITE_TMP'', ''MOV_PEDIDO'', systimestamp, ' || nvl(padmcartao,0) || ')';
      
      insert into web_nuv_pendencias
        ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
      values
        ( seq_nuv_pendencias.nextval, sysdate, 'PROC_GRAVA_PEDIDO_SITE_TMP', pnumpedven, v_sql, 'N', null );
    end if;
  exception
    when others then
      raise_application_error(-20903, 'Erro gravando o Pedido: ' || sqlerrm);
  end;
  
  pmens := pmens || ' Pedido ' || pnumpedven;
  
  declare
    v_flprodenc char(1);
    wbloco      cad_prodloc.bloco%type;
    wrua        cad_prodloc.rua%type;
    v_natjur    cad_cliente.natjur%type;
  begin
    select natjur into v_natjur from cad_cliente where codcli = pcodcli;
    
    -- Busca estado emissor para validacao de ICMS
    select estado,
           decode(estado,
                  'RS',
                  450,
                  'SC',
                  820,
                  'PR',
                  820,
                  'SP',
                  899,
                  'MG',
                  899,
                  450)
      into westorig, v_codfildist
      from cad_filial
     where codfil = wdep;
    
    if nvl(v_natjur, 'F') = 'J' then
      westdest := v_uf_e;
    else
      westdest := westorig;
    end if;
    
    -- Loop para gravar os itens do pedido
    pmens := pmens || ' NumItens ' || pcoditprod.count;
    
    for i in pcoditprod.first .. pcoditprod.last loop
      waliqicms   := 0;
      wcubagmax   := 0;
      wunidade    := 'PC';
      windmedger  := 0;
      wcmup       := 0;
      wcodsitprod := 'NO';
      wqtdvolume  := 0;
      wpeso       := 0;
      
      if nvl(ptpitem(i), 'PE') = 'PE' then
        pmens := pmens || ' CodItProd ' || pcoditprod(i);
        
        begin
          -- Busca o ICMS
          select imp.aliquota,
                 p.cubagmax,
                 p.unidade,
                 v.indmedger,
                 v.cmup,
                 pre.codsitprod,
                 p.qtdvolume,
                 p.pesounit
            into waliqicms,
                 wcubagmax,
                 wunidade,
                 windmedger,
                 wcmup,
                 wcodsitprod,
                 wqtdvolume,
                 wpeso
            from cad_preco     pre,
                 ven_prodfil   v,
                 cad_imptribut imp,
                 cad_prod      p,
                 cad_itprod    it
           where v.codprod = p.codprod
             and v.codfil = 835
             and p.codprod = it.codprod
             and it.coditprod = to_number(pcoditprod(i))
             and imp.tpimp = 'I'
             and imp.codgrptpnota = 8
             and imp.codimp = p.codicms
             and imp.estorig = westorig
             and imp.estdest = westdest
             and pre.coditprod = it.coditprod
             and pre.codfil = 835
             and pre.codembal = 0;
        exception
          when no_data_found then
            declare
              v_digitprod cad_itprod.digitprod%type;
            begin
              select digitprod
                into v_digitprod
                from cad_itprod
               where coditprod = to_number(pcoditprod(i));
              send_mail('site-erros@colombo.com.br',
                        'site-erros@colombo.com.br',
                        'ERRO - Item sem ICMS cadastrado',
                        'Cadastrar o ICMS para o item ' || pcoditprod(i) || '-' ||
                        v_digitprod || ' de ' || westorig || ' para ' ||
                        westdest || '. Tipo de nota 52.');
            exception
              when others then
                null;
            end;
            
            select imp.aliquota,
                   p.cubagmax,
                   p.unidade,
                   v.indmedger,
                   v.cmup,
                   pre.codsitprod,
                   p.qtdvolume,
                   p.pesounit
              into waliqicms,
                   wcubagmax,
                   wunidade,
                   windmedger,
                   wcmup,
                   wcodsitprod,
                   wqtdvolume,
                   wpeso
              from cad_preco     pre,
                   ven_prodfil   v,
                   cad_imptribut imp,
                   cad_prod      p,
                   cad_itprod    it
             where v.codprod = p.codprod
               and v.codfil = 835
               and p.codprod = it.codprod
               and it.coditprod = to_number(pcoditprod(i))
               and imp.tpimp = 'I'
               and imp.codgrptpnota = 8
               and imp.codimp = p.codicms
               and imp.estorig = westorig
               and imp.estdest = decode(westorig,
                                        'RS',
                                        'SP',
                                        'SC',
                                        'SP',
                                        'PR',
                                        'SP',
                                        'SP',
                                        'RS',
                                        westorig)
               and pre.coditprod = it.coditprod
               and pre.codfil = 835
               and pre.codembal = 0;
        end;
        
        -------------------------------
        -- busca o custo mÈdio do cd.
        -------------------------------
        v_cmup_cd := 0;
        begin
          select cmup
            into v_cmup_cd
            from ven_prodfil_cd_ax
           where codfil = v_codfildist
             and codprod =
                 (select codprod
                    from cad_itprod
                   where coditprod = to_number(pcoditprod(i)));
        exception
          when others then
            v_cmup_cd := 0;
        end;
        
        v_preco_reposicao := 0;
        begin
          select preco_reposicao
            into v_preco_reposicao
            from parametros_precos
           where itpr_coditprod = to_number(pcoditprod(i))
             and estado = westorig;
        exception
          when no_data_found then
            v_preco_reposicao := 0;
        end;
        
        ---- Busca a familia do produto
        begin
          select codfam
            into v_codfam
            from cad_itprod
           where coditprod = pcoditprod(i);
        exception
          when others then
            null;
        end;
        
        if nvl(v_cmup_cd, 0) > 0 or nvl(v_preco_reposicao, 0) > 0 then
          begin
            select regra_cmv_margem
              into v_regra_margem
              from cad_familia
             where codfam = v_codfam;
          exception
            when others then
              null;
          end;
        
          if nvl(v_regra_margem, 0) = 1 then
            wcmup := v_preco_reposicao;
          elsif nvl(v_regra_margem, 0) = 2 then
            wcmup := v_cmup_cd;
          else
            wcmup := util.test(nvl(v_preco_reposicao, 0) >
                               nvl(v_cmup_cd, 0),
                               nvl(v_preco_reposicao, 0),
                               nvl(v_cmup_cd, 0));
          end if;
        end if;
        
        begin
          select t.aliquota, t.ctf
            into v_aliqred, v_ctf
            from cad_imptribut t, cad_prod p, cad_itprod i
           where i.codprod = p.codprod
             and p.codicmred = t.codimp
             and i.coditprod = to_number(pcoditprod(i))
             and t.codgrptpnota = 8
             and t.tpimp = 'R'
             and t.estorig = westorig
             and t.estdest = westdest;
        exception
          when others then
            v_aliqred := 0;
            v_ctf     := 0;
        end;
        
        -- Busca aliquota de substituiÁ¿o
        begin
          select t.aliquota -- gravar na mov_itped aliqicmsub, respectivamente
            into waliqsub
            from cad_imptribut t, cad_prod p, cad_itprod i
           where i.codprod = p.codprod
             and p.codicmsub = t.codimp
             and i.coditprod = to_number(pcoditprod(i))
             and t.codgrptpnota = 8
             and t.tpimp = 'S'
             and t.estorig = westorig
             and t.estdest = westdest;
        exception
          when no_data_found then
            waliqsub := 0;
          when others then
            waliqsub := 0;
        end;
        
        -- Busca aliquota de icms do estado de destino somente se h· aliquota de substituiÁ¿o
        if waliqsub > 0 then
          if westdest in ('PR', 'SP', 'MG') then
            if westdest = 'PR' and westorig != 'PR' then
              begin
                select 'S'
                  into wcolchao
                  from cad_prod p, cad_itprod i
                 where i.codprod = p.codprod
                   and i.coditprod = to_number(pcoditprod(i))
                   and p.codicms = 44
                   and p.codicmsub = 20;
              exception
                when others then
                  wcolchao := 'N';
              end;
              --
              if wcolchao = 'S' then
                waliqsubuf := 12;
              else
                waliqsubuf := 18;
              end if;
            else
              waliqsubuf := 18;
            end if;
          else
            waliqsubuf := 17;
          end if;
        else
          waliqsubuf := 0;
        end if;
        
        -- Calcula os valores dos itens
        if nvl(pprecounit(i), 0) > 0 then
          -- o dpi deve ser sobre o valor de lista, ou seja, preço unitário + desconto
          wdpi := pvldesconto(i) / (pprecounit(i) + pvldesconto(i)) * 100;
        else
          wdpi := pvldesconto(i) * 100;
        end if;
        
        wvlitem  := to_number(pprecounit(i)) + to_number(pvldesconto(i));
        wtotitem := pprecounit(i) * pqtcomp(i);
        wtotdesc := pvldesconto(i) * pqtcomp(i);
        
        if arr_tpestitem(i) is not null then
          v_flprodenc := 'S';
          if arr_tpestitem(i) in ('R', 'L') then
            v_fllibfat := 'N';
            -- se for produto encomenda, o flvdantec deve ser E - solicitacao Silvana
          elsif arr_tpestitem(i) = 'E' then
            v_fllibfat  := 'N';
            v_flprodenc := 'E';
          else
            v_fllibfat := 'S';
          end if;
        else
          v_flprodenc := 'N';
        end if;
        
        select rua, bloco
        into   wrua, wbloco
        from   cad_prodloc
        where  codfil = wdep
        and    tpdepos = 'D'
        and    coditprod = to_number(pcoditprod(i));
        
        -- insere log antes de inserir o item do pedido
        v_sql := ' insert into web_log_mov_itped
                     ( codigo, numpedven, coditprod, aliqicm
                     , host, module
                     , os_user, session_user
                     , terminal, current_schema
                     )
                   values
                     ( seq_log_mov_itped.nextval, ' || pnumpedven || ', ' || to_number(pcoditprod(i)) || ', ' || waliqicms || '
                     , sys_context(''USERENV'',''HOST''), sys_context(''USERENV'',''MODULE'')
                     , sys_context(''USERENV'',''OS_USER''), sys_context(''USERENV'',''SESSION_USER'')
                     , sys_context(''USERENV'',''TERMINAL''), sys_context(''USERENV'',''CURRENT_SCHEMA'')
                   ) ';
        
        insert into web_nuv_pendencias
          ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
        values
          ( seq_nuv_pendencias.nextval, sysdate, 'PROC_GRAVA_PEDIDO_SITE', pnumpedven, v_sql, 'N', null );
        
        -- Grava os itens do pedido
        begin
          if wcodsitprod not in ('EC') and to_number(arr_pqtedisp(i)) <= 0 then
            send_mail('site-erros@colombo.com.br',
                      'site-erros@colombo.com.br',
                      'PEDIDO FECHADO COM ESTOQUE ZERO OU NEGATIVO',
                      'PEDIDO FECHADO: ' || pnumpedven || ' - VENDEDOR: ' || v_codvendr || ' - ESTOQUE: ' ||
                      arr_pqtedisp(i) || ' - CODSITPROD: ' || wcodsitprod);
          end if;
          
          insert into mov_itped (
            codfil, tipoped, numpedven, coditprod, item, codcli, qtcomp,
            precounit, aliqicm, aliqicmsub, aliqicmred, local, tpdepos,
            filorig, qtreceb, cubagem, unembal, bloco, codembal, rua,
            dpi, peso, status, tpnota, medger, dtpedido,
            vlfrete, precounitliq, cmup, sitcarga, codsitprod,
            aliqicmsubuf, flvdantec, vldescitem, qtemb, qtvolume,
            precoorig, ctf, vltotitem, vljurosfin, fllibfat,
            situacao, unidade, condpgto, flvdantecant, qtestoque
          ) values (
            pcodfil, 0, pnumpedven, to_number(pcoditprod(i)), i, pcodcli, to_number(pqtcomp(i)),
            wvlitem, waliqicms, waliqsub, v_aliqred, 1, 'D',
            wdep, 0, wcubagmax, wunidade, wbloco, 0, wrua,
            wdpi, wpeso, wstatus, 52, windmedger, wdtpedido,
            arr_rat_frete(i) / 100, to_number(pprecounit(i)), wcmup, 0, wcodsitprod,
            waliqsubuf, v_flprodenc, wtotdesc, 1, wqtdvolume,
            wvlitem, v_ctf, wtotitem, to_number(pitemvljurosfin(i)), v_fllibfat,
            5, wunidade, pcondpgto, v_flprodenc, arr_pqtedisp(i)
          );
          
          v_coddesconto := to_number(pdescontoweb(i));
          
          if v_coddesconto > 0 then
            proc_quantidade_vezes_desconto(v_coddesconto);
          end if;
          
          select codprod
          into   v_codprod
          from   web_itprod
          where  coditprod = to_number(pcoditprod(i));
          
          -- busca o código do brinde, se houver
          begin
            if (to_number(pIsBrinde(i)) > 0) then
              v_cod_brinde := to_number(pIsBrinde(i));
            else
              v_cod_brinde := null;
            end if;
          exception
            when invalid_number then
              v_cod_brinde := null;
          end;
          
          begin
            select portal_id
            into   v_portal
            from   web_integr_portal
            where  cod = pPortal;
            
            select promocao
            into   v_camppreco
            from   table(web_preco_ativo(v_codprod, null, v_portal));
          exception
            when others then
              select promocao
              into   v_camppreco
              from   table(web_preco_ativo(v_codprod));
          end;
          
          insert into mov_itped_web
            ( codfil
            , tipoped
            , numpedven
            , coditprod
            , coddesconto
            , campanha_preco
            , cod_brinde
            )
          values
            ( pcodfil
            , 0
            , pnumpedven
            , to_number(pcoditprod(i))
            , decode(v_coddesconto, 0, null, v_coddesconto)
            , v_camppreco
            , v_cod_brinde
          ) ;
          
          prc_pedido_valida_promocao(v_cod_brinde, v_codprod);
          
          -- gera estatísticas de venda para portais, e diferente de frete
          if nvl(pPortal,0) > 0 and to_number(pcoditprod(i)) <> 219698 then
            -- busca o produto
            select i.codprod, f.codlinha
            into   v_codprod, v_codlinha
            from   web_itprod i, web_prod p, web_grupo g, web_familia f
            where  coditprod  = to_number(pcoditprod(i))
            and    i.codprod  = p.codprod
            and    p.codgrupo = g.codgrupo
            and    g.codfam   = f.codfam;
            
            begin
              if to_number(pIsBrinde(i)) > 0 then
                select *
                into   v_mais_vendido_portal
                from   web_mais_vendidos_integr
                where  data_compra = trunc(sysdate)
                and    codintegr   = pPortal
                and    codprod     = v_codprod
                and    cod_brinde  = to_number(pIsBrinde(i));
              else
                select *
                into   v_mais_vendido_portal
                from   web_mais_vendidos_integr
                where  data_compra = trunc(sysdate)
                and    codintegr   = pPortal
                and    codprod     = v_codprod
                and    cod_brinde is null;
              end if;
              
              v_cod_mais_vendido := v_mais_vendido_portal.codigo;
              
              update web_mais_vendidos_integr
              set    quantidade = nvl(quantidade,0) + to_number(pqtcomp(i))
              ,      valor      = nvl(valor,0)      + wtotitem
              where  codigo     = v_mais_vendido_portal.codigo;
            exception
              when no_data_found then
                select nvl(max(codigo),0) + 1
                into   v_cod_mais_vendido
                from   web_mais_vendidos_integr;
                
                insert into web_mais_vendidos_integr
                  (codigo,
                   codprod,
                   codlinha,
                   codintegr,
                   data_compra,
                   quantidade,
                   valor,
                   cod_brinde)
                values
                  (v_cod_mais_vendido,
                   v_codprod,
                   v_codlinha,
                   pPortal,
                   trunc(sysdate),
                   to_number(pqtcomp(i)),
                   wtotitem,
                   decode(to_number(pIsBrinde(i)),
                          0,
                          null,
                          to_number(pIsBrinde(i))));
            end;
            
            -- salva o nro do pedido para tabela de relatorios
            insert into web_mais_vendidos_int_pedidos
              ( codigo
              , numpedven
              , mais_vendidos_integr
              )
            values
              ( ( select nvl(max(codigo), 0) + 1 from web_mais_vendidos_int_pedidos )
              , pnumpedven
              , v_cod_mais_vendido
            ) ;
          end if;
          
          -- grava log de estoque para os itens do pedido
          /*
          prc_grava_pedido_log_estoque
          ( pnumpedven
          , to_number(pcoditprod(i))
          , wdep
          , v_flprodenc
          ) ;
          */
        exception
          when others then
            raise_application_error(-20903, 'Erro gravando o Item ' || pcoditprod(i) || ': ' || sqlerrm);
        end;
        
        -- Baixa os itens da lista de casamento
        if pnumlistacasam is not null then
          insert into website.pedido_nota_noivas
            ( numero_da_lista, codfil, numdoc, serie, flg_doc
            , dtnota, coditprod, qtde, status, codvendr, usuario
            ) 
          values
            ( pnumlistacasam, pcodfil, pnumpedven, 'PE', 'PE'
            , wdtpedido, to_number(pcoditprod(i)), to_number(nvl(pqtcomp(i),'0')), 0, v_codvendr, 'SITE'
          ) ;
          
          update website.produtos_da_lista
          set    qtde_comprada   = nvl(qtde_comprada,0) + to_number(nvl(pqtcomp(i),'0'))
          where  numero_da_lista = pnumlistacasam
          and    coditprod       = to_number(pcoditprod(i));
        end if;
      else
        wtemgarantia := 'S';
      end if;
      
    end loop;
    
    pmens := pmens || ' Gravou os itens; ';
    
  end;
  
  -- Grava os dados das prestacoes
  prc_gravaparcelas
  ( pcodfil, pnumpedven, wprontuario, pformapagto, pcondpgto
  , pvlentrada, wvlrjurosfin, ppjuros, pvlrparcela, pdtvencto
  , padmcartao, pnumcartao, pcodseg, pdtvctocartao, pnomecartao
  , pnumCartaoCripto
  ) ;
  
  pmens := pmens || ' Gravou Parcelas de ' || pvlrparcela(1) || '; ';
  
  -- Contabilizacao para Cartao de Credito e Boleto
  v_sql := ' insert into ctb_virtual
               ( codfil, datctb, ccusto, codcta, hist, complhist, flgdc, vlrconta )
             values
               ( ' || pcodfil || ', sysdate, null, ''10'', ''53''
               , ''' || substr(to_char(pnumpedven) || ';' || pnomecartao,1,50) || '''
               , ''D'', ' || replace(to_char(trunc(v_vltotal,2),'999999999D99'),',','.') || '
             ) ';
  
  insert into web_nuv_pendencias
    ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
  values
    ( seq_nuv_pendencias.nextval, sysdate, 'PROC_GRAVA_PEDIDO_SITE_TMP', pnumpedven, v_sql, 'N', null );
  
  v_sql := ' insert into ctb_virtual
               ( codfil, datctb, ccusto, codcta, hist, complhist, flgdc, vlrconta )
             values
               ( ' || pcodfil || ', sysdate, null, ''757'', ''54''
               , ''' || substr(to_char(pnumpedven) || ';' || pnomecartao,1,50) || '''
               , ''D'', ' || replace(to_char(trunc(v_vltotal,2),'999999999D99'),',','.') || '
             ) ';
  
  insert into web_nuv_pendencias
    ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
  values
    ( seq_nuv_pendencias.nextval, sysdate, 'PROC_GRAVA_PEDIDO_SITE_TMP', pnumpedven, v_sql, 'N', null );
  
  pmens := pmens || ' Gravou a Contabilizacao; ';
  
  -- grava liberacao de pedidos
  -- somente para pedidos realizados com cartao de credito
  if pformapagto = 1 then
    v_sql := ' begin lvirtual.prc_grava_pedidos_liberacoes(' || pnumpedven || ', ''' || pdesmembrado || '''); end; ';
    
    insert into web_nuv_pendencias
      ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
    values
      ( seq_nuv_pendencias.nextval, sysdate, 'PROC_GRAVA_PEDIDO_SITE_TMP', pnumpedven, v_sql, 'N', null );
  end if;
  
  -- GRAVA A GARANTIA COMPLEMENTAR E TROCA GARANTIDA
  -- Grava os dados na mov_pedido para poder liberar pelo Gemco intregrado com TEF...
  -- Para garantia de moveis, utilizar a conceito de faixa de valores... (deixamos para segunda fase)
  if wtemgarantia = 'S' then
    
    -- Se encontrou alguma garantia
    pmens := pmens || ' Garantia:' || wtemgarantia || '; ';
    
    -- Loop nos itens
    for i in pcoditprod.first .. pcoditprod.last loop
      -- Testa se o item atual eh garantia
      if ptpitem(i) in ('GA', 'TG', 'GM') then
        begin
          if ptpitem(i) = 'GA' then
            wtpnotagar := 393; --459
          elsif ptpitem(i) = 'TG' then
            wtpnotagar := 414; --460
          elsif ptpitem(i) = 'GM' then
            wtpnotagar := 429; --458
          end if;
          
          -- Calcula o descont do item de garantia
          begin
            wdpi := 0;
            if nvl(pprecounit(i), 0) > 0 then
              wdpi := pvldesconto(i) / pprecounit(i) * 100;
            else
              wdpi := pvldesconto(i) * 100;
            end if;
          exception
            when others then
              null;
          end;
          
          wtotitem := pprecounit(i) * pqtcomp(i);
          wtotdesc := pvldesconto(i) * pqtcomp(i);
          
          -- Verifica o valor a pagar
          begin
            select p.vlr_apagar
            into   wvlgarantpror
            from   preco_garantias p
            where  p.seq_garantia  = to_number(pseqgarantia(i));
          exception
            when others then
              null;
          end;
          
          -- Grava a capa da garantia
          -- Grava as mesmas condicoes de pagamento do pedido
          select seqped.nextval 
          into   wnumpedvengar
          from   dual;
          
          begin
            insert into mov_pedido
              (codfil,
               tipoped,
               numpedven,
               codvendr,
               tpped,
               filorig,
               local,
               condpgto,
               condpgtofil,
               codcli,
               codclipres,
               codtransp,
               dtpedido,
               dtentrega,
               endcob,
               endent,
               endclipres,
               praca,
               obs,
               vlfrete,
               vlmercad,
               sitcarga,
               status,
               tpnota,
               dtlibcre,
               flestat,
               flfatura,
               vltotal,
               pjuros,
               hrpedido,
               codfilsolic,
               tpfrete,
               fllibfat,
               situatef,
               redutorbaseicms,
               flos,
               numcontra,
               col_formapgto,
               col_admcartao,
               vljurosfin,
               col_dtentregaant,
               vloutras,
               col_seq_garantia,
               vlentrada,
               col_litiner,
               cod_prontuario,
               qtprc,
               cod_plan_cart,
               qtd_parc_cart)
            values
              (pcodfil,
               0,
               wnumpedvengar,
               v_codvendr,
               'E',
               pcodfil,
               1,
               pcondpgto,
               pcondpgto,
               pcodcli,
               0,
               0,
               wdtpedido,
               wdtentrega,
               0,
               pendent,
               0,
               wpraca,
               wobs,
               0,
               wtotitem,
               0,
               wstatus,
               wtpnotagar,
               wdtpedido,
               'S',
               'P',
               wtotitem,
               ppjuros,
               sysdate,
               pcodfil,
               1,
               'N',
               0,
               0,
               'N',
               pnumcontra,
               pformapagto,
               padmcartao,
               trunc(to_number(pitemvljurosfin(i)), 2),
               wdtentrega,
               wvlgarantpror,
               to_number(pseqgarantia(i)),
               0,
               null,
               wprontuario,
               wnumparcelas,
               wcodplancart,
               wqtdparccart);
            
            if pcodfil = 400 then
              v_sql := ' insert into log_prog_alt_pedidos
                           ( pedido, programa, tabela, data, valor )
                         values
                           ( ' || wnumpedvengar || ', ''PROC_GRAVA_PEDIDO_SITE_TMP'', ''MOV_PEDIDO'', systimestamp, ' || nvl(padmcartao,0) || ')';
              
              insert into web_nuv_pendencias
                ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
              values
                ( seq_nuv_pendencias.nextval, sysdate, 'PROC_GRAVA_PEDIDO_SITE_TMP', pnumpedven, v_sql, 'N', null );
            end if;
          exception
            when others then
              raise_application_error(-20903, 'Erro gravando a Nota de Garantia: ' || sqlerrm);
          end;
          
          pmens := pmens || ' Capa Garantia:' || wnumpedvengar || '; ';
          
          -- Grava o item da garantia
          begin
            insert into mov_itped
              (codfil,
               tipoped,
               numpedven,
               coditprod,
               item,
               codcli,
               qtcomp,
               precounit,
               aliqicm,
               aliqicmsub,
               aliqicmred,
               tpdepos,
               filorig,
               situacao,
               qtreceb,
               cubagem,
               unidade,
               codembal,
               dpi,
               peso,
               status,
               tpnota,
               medger,
               dtpedido,
               condpgto,
               precounitliq,
               cmup,
               sitcarga,
               codsitprod,
               aliqicmsubuf,
               qtemb,
               qtvolume,
               precoorig,
               vldescitem,
               vltotitem,
               vljurosfin)
            values
              (pcodfil,
               0,
               wnumpedvengar,
               to_number(pcoditprod(i)),
               i,
               pcodcli,
               to_number(pqtcomp(i)),
               to_number(pprecounit(i)),
               0,
               0,
               0,
               'D',
               pcodfil,
               5,
               0,
               wcubagmax,
               wunidade,
               0,
               wdpi,
               1,
               wstatus,
               wtpnotagar,
               0,
               wdtpedido,
               pcondpgto,
               to_number(pprecounit(i)),
               0,
               0,
               wcodsitprod,
               0,
               1,
               wqtdvolume,
               to_number(pprecounit(i)) + to_number(pvldesconto(i)),
               wtotdesc,
               wtotitem,
               to_number(pitemvljurosfin(i)));
          exception
            when others then
              raise_application_error(-20903, 'Erro gravando a Garantia: ' || sqlerrm);
          end;
          
          pmens := pmens || ' Item Garantia:' || pcoditprod(i) || '; ';
        exception
          when others then
            pmens := pmens || ' Erro Geral Garantia:' || sqlerrm || '; ';
        end;
        
      end if;
    end loop;
    
    v_sql := ' begin proc_sincroniza_pedido(' || wnumpedvengar || '); end; ';
    
    insert into web_nuv_pendencias
      ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
    values
      ( seq_nuv_pendencias.nextval, sysdate, 'PROC_GRAVA_PEDIDO_SITE_TMP', pnumpedven, v_sql, 'N', null );
  end if;
  
  -- RETORNO
  pmens := pmens || ' FIM';
  
exception
  when others then

declare
  v_mensagem clob;
begin
  v_mensagem := '
declare
          
  pcoditprod         owa_util.ident_arr;
  pseqgarantia       owa_util.ident_arr;
  ptpitem            owa_util.ident_arr;
  pqtcomp            owa_util.ident_arr;
  pprecounit         owa_util.ident_arr;
  pvldesconto        owa_util.ident_arr;
  pdescontoweb       owa_util.ident_arr;
  pitemvljurosfin    owa_util.ident_arr;
          
  pdtvencto          owa_util.ident_arr;
  pvlrparcela        owa_util.ident_arr;
          
  pisbrinde          owa_util.ident_arr;
          
  v1                 varchar2(200);
  v2                 varchar2(200);
          
begin 

';
  
  for i in pcoditprod.first..pcoditprod.last loop
    v_mensagem := v_mensagem || '  pcoditprod(' || i || ')      := ' || pcoditprod(i) || ';' || chr(13);
    v_mensagem := v_mensagem || '  pseqgarantia(' || i || ')    := ' || nvl(pseqgarantia(i),'null') || ';' || chr(13);
    v_mensagem := v_mensagem || '  ptpitem(' || i || ')         := ''' || ptpitem(i) || ''';' || chr(13);
    v_mensagem := v_mensagem || '  pqtcomp(' || i || ')         := ' || nvl(pqtcomp(i),0) || ';' || chr(13);
    v_mensagem := v_mensagem || '  pprecounit(' || i || ')      := ' || nvl(replace(pprecounit(i),',','.'),0) || ';' || chr(13);
    v_mensagem := v_mensagem || '  pvldesconto(' || i || ')     := ' || nvl(replace(pvldesconto(i),',','.'),0) || ';' || chr(13);
    v_mensagem := v_mensagem || '  pdescontoweb(' || i || ')    := ' || nvl(replace(pdescontoweb(i),',','.'),0) || ';' || chr(13);
    v_mensagem := v_mensagem || '  pitemvljurosfin(' || i || ') := ' || nvl(replace(pitemvljurosfin(i),',','.'),0) || ';' || chr(13);
  end loop;
  
  for i in pdtvencto.first..pdtvencto.last loop
    v_mensagem := v_mensagem || '  pdtvencto(' || i || ')       := to_date(''' || pdtvencto(i) || ''',''dd/mm/yyyy'');' || chr(13);
    v_mensagem := v_mensagem || '  pvlrparcela(' || i || ')     := ' || nvl(replace(pvlrparcela(i),',','.'),0) || ';' || chr(13);
  end loop;
  
  for i in pisbrinde.first..pisbrinde.last loop
    v_mensagem := v_mensagem || '  pisbrinde(' || i || ')       := ' || nvl(pisbrinde(i),0) || ';' || chr(13);
  end loop;
  
  v_mensagem := v_mensagem || ' 
  website.proc_grava_pedido_site_tmp
  ( pcodfil          => ''' || pcodfil || '''
  , pprontuario      => ''' || pprontuario || '''
  , pvendedor        => ''' || pvendedor || '''
  , pcodcli          => ''' || pcodcli || '''
  , pendent          => ''' || pendent || '''
  , pdeposito        => ''' || pdeposito || '''
  , pdtfaturamento   => to_date(''' || to_char(pdtfaturamento,'dd/mm/yyyy') || ''',''dd/mm/yyyy'')
  , pcodfonte        => ''' || pcodfonte || '''
  , pnumcontra       => ''' || pnumcontra || '''
  , pnumlistacasam   => ''' || pnumlistacasam || '''
  , pobs             => ''' || substr(pobs,1,100) || '''
  , pvlentrada       => ''' || pvlentrada || '''
  , pvlfrete         => ''' || pvlfrete || '''
  , pvlguia          => ''' || pvlguia || '''
  , pvlaliquota      => ''' || pvlaliquota || '''
  , pdiasentregamin  => ''' || pdiasentregamin || '''
  , pdiasentregamax  => ''' || pdiasentregamax || '''
  , ptransportadora  => ''' || ptransportadora || '''
  , pvltotitens      => ''' || pvltotitens || '''
  , pvljurosfin      => ''' || pvljurosfin || '''
  , pvltaxajuros     => ''' || pvltaxajuros || '''
  , pvltotal         => ''' || pvltotal || '''
  , pformapagto      => ''' || pformapagto || '''
  , pcondpgto        => ''' || pcondpgto || '''
  , ppjuros          => ''' || ppjuros || '''
  , padmcartao       => ''' || padmcartao || '''
  , pnumcartao       => ''' || pnumcartao || '''
  , pnumcartaocripto => ''' || pnumcartaocripto || '''
  , pcodseg          => ''' || pcodseg || '''
  , pnomecartao      => ''' || pnomecartao || '''
  , pdtvctocartao    => to_date(''' || to_char(pdtvctocartao,'dd/mm/yyyy') || ''',''dd/mm/yyyy'')
  , pcoditprod       => pcoditprod
  , pseqgarantia     => pseqgarantia
  , ptpitem          => ptpitem
  , pqtcomp          => pqtcomp
  , pprecounit       => pprecounit
  , pvldesconto      => pvldesconto
  , pdescontoweb     => pdescontoweb
  , pitemvljurosfin  => pitemvljurosfin
  , pdtvencto        => pdtvencto
  , pvlrparcela      => pvlrparcela
  , pbancodebito     => ''' || pbancodebito || '''
  , pcodemailmkt     => ''' || pcodemailmkt || '''
  , plogpedido       => ''' || plogpedido || '''
  , pnumpedven       => v1
  , pmens            => v2
  , pcodpedagrupado  => ''' || pcodpedagrupado || '''
  , pdesmembrado     => ''' || pdesmembrado || '''
  , pfilialretirar   => ''' || pfilialretirar || '''
  , pperfil          => ''' || pperfil || '''
  , porigem          => ''' || porigem || '''
  , pportal          => ''' || pportal || '''
  , pisbrinde        => pisbrinde
  , pvlicmret        => ''' || pvlicmret || '''
  , p_data_agendamento_entrega  => to_date(''' || to_char(p_data_agendamento_entrega,'dd/mm/yyyy') || ''',''dd/mm/yyyy'')
  , p_turno_agendamento_entrega => ''' || p_turno_agendamento_entrega || '''
  , p_jsession                  => ''' || p_jsession || '''
  , p_refaturamento             => ''' || p_refaturamento || '''
  , p_frete_tele                => ''' || p_frete_tele || '''
  , p_numcupom                  => ''' || p_numcupom || '''
  , p_tip_desc                  => ''' || p_tip_desc || '''
  , p_per_desc                  => ''' || p_per_desc || '''
  , p_vlr_desc                  => ''' || p_vlr_desc || '''
  , pvldesccapa                 => ''' || pvldesccapa || '''
  , p_venc_boleto               => to_date(''' || to_char(p_venc_boleto,'dd/mm/yyyy') || ''',''dd/mm/yyyy'')
  ) ;
  
  dbms_output.put_line(v1);
  dbms_output.put_line(v2);
  
end;';
  
  send_mail('site-erros@colombo.com.br','site-erros@colombo.com.br','PROC_GRAVA_PEDIDO_SITE_TMP','Erro: ' || sqlerrm || ' na linha: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' Debug: ' || v_mensagem);
end;
  
  pmens := pmens || ' ERRO: ' || sqlerrm || ' na linha: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
  raise_application_error(-20903, pmens);
  
end proc_grava_pedido_site_tmp;
/
