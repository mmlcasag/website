create or replace procedure website.proc_pedido_site_tmp( -- ENDERECO DE ENTREGA
                       pcodclilv in number,    -- Codigo do cliente
                       pcodendlv in number,    -- Codigo do endereco de entrega
                       pdtfaturamento in date, -- Data para faturar o pedido
                       -- PEDIDO
                       pcodfil in number,           -- Filial da venda - default 400
                       pprontuario in number,       -- Prontuario do pedido
                       pvendedor   in number,       -- Prontuario da venda
                       pdeposito   in number,       -- deposito de venda
                       pfontemidia in varchar2,     -- Codigo da fonte da midia do pedido
                       pnumlistacasam in number,    -- Numero da lista de casamento
                       pobs in varchar2,            -- Observacoes de entrega do pedido
                       pvlfrete in number,          -- Valor total do frete (a ser lancado como item)
                       pvlguia in number,           -- Valor total da guia do frete
                       pvlaliquota in number,       -- Valor total da aliquota do frete
                       pdiasentregamin in number,   -- Numero minimo de dias para a entrega
                       pdiasentregamax in number,   -- Numero maximo de dias para a entrega
                       ptransportadora in varchar2, -- Empresa que fara a entrega da mercadoria, S:Correio, X:Sedex, N:Itapemirim, P:Propria
                       pvlmercad in number,      -- Valor total das mercadorias adquiridas (preco unit x qtcomp)
                       pvljurosfin in number,    -- Valor total do juro a ser gravado na capa da nota
                       pvlTaxaJuros in number,   -- Taxa de juros (média ponderada)
                       pvltotal in number,       -- Valor total do pedido (com juros, descontos e frete)
                       pformapagto in number,    -- Forma de pagamento (cartao, boleto)
                       -- DADOS DO CARTAO
                       padmcartao in number,    -- Codigo da administradora do cartao
                       pnumcartao in varchar2,  -- Numero do cartao de credito
                       pNumCartaoCripto in varchar2,
                       pcodseg in number,       -- Codigo de seguranca
                       pnomecartao in varchar2, -- Nome do cliente no cartao
                       pdtvctocartao in date,   -- Data de vencimento do cartao
                       -- ITENS (arrays em string separados por #)
                       pcoditprod in varchar2,   -- Codigo dos itens
                       pseqgarantia in varchar2, -- Sequencia da capa da garantia
                       ptpitem in varchar2,      -- Identifica se o item e de pedido (PE) ou garantia (G:GC, T:TG, M:GM)
                       pqtcomp in varchar2,      -- Quantidade comprada de cada item
                       pprecounit in varchar2,   -- Preco unitario de cada
                       pvldesconto in varchar2,  -- Valor do Desconto por item
                       pdescontoweb in varchar2,  -- Desconto por item - WEB_DESCONTO
                       pItemVlJuros in varchar2, -- valor de juros por item
                       -- PARCELAS (arrays em string separados por #)
                       pdtvcto in varchar2,     -- Vencimento da parcela
                       pvlrparcela in varchar2, -- Valor da parcela
                       pBancoDebito in number,
                       pCodEmailMkt in number,
                       -- log venda
                       pLogVenda in varchar,
                       pRefaturamento in varchar default 'N',
                       -- VARIAVEIS DE RETORNO
                       pnumpedven out number, -- Numero do pedido no Gemco,
                       pmens out varchar2,    -- Mensagem de retorno
                       -- VARIAVEIS PARA OS LIVROS NO SITE
                       pCodPedAgrupado in number default null,
                       pDesmembrado in varchar2 default null,
                       pFilialRetirar in integer default null,
                       pPerfil in number default null,
                       pOrigem IN VARCHAR2 DEFAULT NULL,
                       pPortal IN NUMBER DEFAULT NULL,
                       pIsBrinde IN VARCHAR2 DEFAULT NULL,
                       pVlicmret IN NUMBER DEFAULT NULL,
                       --informacoes de agendamento
                       p_data_agendamento_entrega in date default null,
                       p_turno_agendamento_entrega in varchar default null,
                       p_jsession in varchar2 default null,
                       -- parâmetros do televendas
                       p_frete_tele in number default null,
                       -- central de descontos
                       p_numcupom in varchar2 default null,
                       p_tip_desc in varchar2 default null,
                       p_per_desc in number default null,
                       p_vlr_desc in number default null,
                       pvldesccapa in number default 0,
                       p_venc_boleto in date default null
                       ) is

  -- Procedure intermediaria entre o Java do Site e a Integracao corporativa
  -- Analista: Scheila Ariotti
  -- Desenvolvido em fev/2005

  v_endereco_r       web_usuarios_end%rowtype;
  v_endereco_e       web_usuarios_end%rowtype;
  v_usuario          web_usuarios%rowtype;
  v_numcontra        number;
  v_vlentrada        number;
  pcondpgto          varchar2(3);
  ppjuros            number;

  -- Itens e Parcelas
  arr_coditprod      owa_util.ident_arr;
  arr_seqgarant      owa_util.ident_arr;
  arr_qtdcomp        owa_util.ident_arr;
  arr_precounit      owa_util.ident_arr;
  arr_desconto       owa_util.ident_arr;
  arr_tpitem         owa_util.ident_arr;
  arr_vlrparcela     owa_util.ident_arr;
  arr_dtvencto       owa_util.ident_arr;
  arr_desconto_web   owa_util.ident_arr;
  arr_juros_item     owa_util.ident_arr;
  arr_is_brindes     owa_util.ident_arr;
  arr_cod_brindes    owa_util.ident_arr;
  arr_val_brindes    owa_util.ident_arr;
  arr_qtd_brindes    owa_util.ident_arr;

  -- cotnrole thiago 30/08
  v_coditem          web_itprod.coditprod%type;
  v_precoItem        number;
  v_codprod          web_itprod.codprod%type;
  v_precoPromo       NUMBER;
  v_DescontoItem     number;
  wcodcli            number;
  wendent            number;
  v_inscr            web_usuarios.numdoc%type;
  v_numdoc           web_usuarios.numdoc%type;
  v_mens             varchar2(32000);

begin
  
  -- CPFs invalidos
  if v_usuario.numcpf in ('11111111111','99999999999') then
    return;
  end if;

  -- Transforma os itens em array
  declare
    ind number;
    v_number varchar2(50);
  begin
    ind := 0;
    loop
      v_number := util.cut(pcoditprod, '#', ind);
      exit when v_number is null;

      arr_coditprod(arr_coditprod.count+1) := v_number;
      v_coditem := v_number;
      arr_seqgarant(arr_seqgarant.count+1) := util.cut(pseqgarantia, '#', ind);
      arr_tpitem(arr_tpitem.count+1) := util.cut(ptpitem, '#', ind);

      begin
          V_NUMBER := UTIL.CUT(PITEMVLJUROS, '#', IND);
          if(str2num(v_number) < 0) then
            raise_application_error(-20903, 'Erro na valor do juro - juro negativo '||ind||' - '||v_number);
          end if;
      arr_juros_item(arr_juros_item.count+1) := str2num(v_number);
      exception
        when others then
          raise_application_error(-20903, 'Erro no juros do item '||ind||' - '||v_number);
      end;

      begin
        v_number := util.cut(pqtcomp, '#', ind);
        arr_qtdcomp(arr_qtdcomp.count+1) := str2num(v_number);
      exception
        when others then
          raise_application_error(-20903, 'Erro na quantidade do item '||ind||' - '||v_number);
      end;

      begin
        v_number := util.cut(pprecounit, '#', ind);
        arr_precounit(arr_precounit.count+1) := str2num(v_number);
        v_precoitem := str2num(v_number);
      exception
        when others then
          raise_application_error(-20903, 'Erro no preco do item '||ind||' - '||v_number);
      end;

      begin
        v_number := util.cut(pvldesconto, '#', ind);
        arr_desconto(arr_desconto.count+1) := str2num(v_number);
        v_DescontoItem := str2num(v_number);
      exception
        when others then
          raise_application_error(-20903, 'Erro no desconto do item '||ind||' - '||v_number);
      end;

      begin
        v_number := util.cut(pdescontoweb, '#', ind);
        arr_desconto_web(arr_desconto_web.count+1) := str2num(v_number);
      exception
        when others then
          raise_application_error(-20903, 'Erro no desconto do item '||ind||' - '||v_number);
      END;

      BEGIN
        IF(pIsBrinde IS NULL) THEN -- (Segurança para virada do projeto) se brindes for null, coloca 0 para evitar dar erro e evitar que tenhamos problemas com o JAVA
          arr_is_brindes(arr_is_brindes.count+1) := 0;
        else
          v_number := util.cut(pIsBrinde, '#', ind);
          arr_is_brindes(arr_is_brindes.count+1) := str2num(v_number);
        end if;
      exception
        WHEN others THEN
          raise_application_error(-20903, 'Erro no codigo do brinde '||ind||' - '||v_number);
      END;

      if pprontuario = 99999 then
         -- busca o codigo do produto
         select codprod
         into   v_codprod
         from   web_itprod i
         where  i.coditprod = v_coditem;

         -- busca o preco promocional do produto
         v_precoPromo := 0;
         begin
           select preco
           into   v_precoPromo
           from   table(web_preco_ativo(v_codprod));
         exception
           when others then
              v_precoPromo := v_precoItem;
         end;

         -- se nao houver preco de promocao, considera o preco do item
         if v_precoPromo = 0 then
           v_precoPromo := v_precoItem;
         end if;
      end if;

      ind := ind + 1;
      pmens := pmens || ' item: ' || ind || ' - ' ||
               arr_coditprod(arr_coditprod.count) || ' - ' || arr_qtdcomp(arr_qtdcomp.count) || ' - ' ||
               arr_precounit(arr_precounit.count) ||' - ' || arr_desconto(arr_desconto.count) || ' - ' ||
               arr_desconto_web(arr_desconto_web.count);
    end loop;

    if arr_coditprod.count <> arr_seqgarant.count or
       arr_coditprod.count <> arr_tpitem.count or
       arr_coditprod.count <> arr_qtdcomp.count or
       arr_coditprod.count <> arr_precounit.count or
       arr_coditprod.count <> arr_desconto.count or
       arr_coditprod.count <> arr_desconto_web.count or
       arr_coditprod.count <> arr_juros_item.count then
      raise_application_error(-20903, 'Arrays de dados dos itens diferentes');
    end if;

    if arr_coditprod.count = 0 then
      raise_application_error(-20903, 'Array de itens em branco');
    end if;

    if pformapagto = 6 and pbancoDebito is null then
      raise_application_error(-20903, 'banco não informado');
    end if;

    ind := 0;
    loop
      v_number := util.cut(pvlrparcela, '#', ind);
      exit when v_number is null;

      begin
        if str2num(v_number) >= 0 then
          arr_vlrparcela(arr_vlrparcela.count+1) := str2num(v_number);
          arr_dtvencto(arr_dtvencto.count+1) := util.cut(pdtvcto, '#', ind);

          if ind = 0 and to_date(arr_dtvencto(arr_dtvencto.count),'dd/mm/yyyy') <= trunc(sysdate)-7 then
            v_vlentrada := arr_vlrparcela(arr_vlrparcela.count);
          end if;

          pmens := pmens || ' parcela: ' || ind || ' - ' || arr_vlrparcela(arr_vlrparcela.count) || ' - ' || arr_dtvencto(arr_dtvencto.count);
        end if;
      exception
        when others then
          raise_application_error(-20903, 'Erro no valor da parcela '||ind||' - '||v_number);
      end;

      ind := ind + 1;
    end loop;

    if arr_vlrparcela.count <> arr_dtvencto.count then
      raise_application_error(-20903, 'Qtd de parcelas diferente da qtd de vencimentos');
    end if;

    if arr_vlrparcela.count = 0 then
      raise_application_error(-20903, 'Array de parcelas em branco');
    end if;
  end;

  -- Se nao tem itens para a execucao
  if instr(pcoditprod, '#') = 0 or instr(pcoditprod, '#') is null then
    raise_application_error(-20903, 'O Pedido nao possui itens.');
  end if;

  -- Busca sequencia do numero do pedido (numcontra)
  declare
    v_count number := 0;
    v_seq   number := 1;
  begin
    while v_seq > 0 and v_count < 10 loop
      -- seleciona um contrato disponivel em tabela
      begin
        select seq_numcontra_disponivel.nextval
        into   v_numcontra
        from   dual;

        select numcontra
        into   v_numcontra
        from   web_numcontra_disponivel
        where  codigo = v_numcontra;
      exception
        when no_data_found then
          -- senão estiver disponível, então busca da sequence
          select seq_numped_lv.nextval
          into   v_numcontra
          from   dual;
      end;

      select count(*)
      into   v_seq
      from   mov_pedido
      where  codfil    = pcodfil
      and    numcontra = v_numcontra
      and    status   != 9;

      v_count := v_count + 1;
    end loop;

    if v_seq > 0 then
      select seq_numped_lv.nextval
      into   v_numcontra
      from   dual;
    end if;
  end;

  -- Busca os dados do cliente na tabela do site
  begin
    select *
    into   v_usuario
    from   web_usuarios
    where  codclilv = pcodclilv;
  exception
    when others then
      raise_application_error(-20903, 'cliente nao encontrato ' || pcodclilv);
  end;

  -- Endereco residencial
  begin
    select *
    into   v_endereco_r
    from   web_usuarios_end
    where  codclilv = pcodclilv
    and    codendlv = 0;
  exception
    when others then
      raise_application_error(-20903, 'endereco residencial ' || pcodendlv || ' nao localizado para o cliente ' || pcodclilv);
  end;

  -- Endereco de entrega
  begin
    select *
    into   v_endereco_e
    from   web_usuarios_end
    where  codclilv = pcodclilv
    and    codendlv = pcodendlv;
  exception
    when others then
      raise_application_error(-20903, 'endereco de entrega ' || pcodendlv || ' nao localizado para o cliente ' || pcodclilv);
  end;

  -- Define variaveis para a integracao
  if v_usuario.natjur = 'J' then
    v_inscr  := v_usuario.numdoc;
    v_numdoc := null;
  else
    v_numdoc := v_usuario.numdoc;
    v_inscr := null;
  end if;

  -- Define o plano de pagamento e taxa de juros para gravar na capa do pedido
  select decode(pformapagto,1,'CE',2,'AV',5,'S5',7,'66',10,'FJ','AV')
  into   pcondpgto
  from   dual;

  begin
    ppjuros := round(pvljurosfin / pvltotal,4);
  exception
    when zero_divide then
      ppjuros := pvljurosfin;
  end;

  -- GRAVA CLIENTE E O ENDERECO DE ENTREGA
  website.proc_cliente(
         pcodfil,
         pprontuario,
         v_usuario.codcli_gemco,
         v_usuario.numcpf,
         v_usuario.natjur,
         v_usuario.nome,
         v_usuario.dtnasc,
         v_usuario.dtcadast,
         v_inscr,
         v_numdoc,
         v_usuario.emissor,
         v_usuario.nomemae,
         v_usuario.nomepai,
         v_usuario.nomeconj,
         v_usuario.empresa,
         v_usuario.codcargo,
         v_usuario.codestcivil,
         v_usuario.sexo,
         v_usuario.renda,
         v_usuario.tiporesid,
         v_usuario.temporesid,
         -- ENDERECO RESIDENCIAL
         v_endereco_r.endereco,
         v_endereco_r.numero,
         v_endereco_r.referencia,
         v_endereco_r.bairro,
         v_endereco_r.cidade,
         v_endereco_r.uf,
         v_endereco_r.cep,
         v_endereco_r.complemento,
         v_endereco_r.dddresid,
         v_endereco_r.foneresid,
         v_endereco_r.ramalresid,
         v_endereco_r.dddcoml,
         v_endereco_r.fonecoml,
         v_endereco_r.ramalcoml,
         v_endereco_r.dddcelul,
         v_endereco_r.fonecelul,
         v_usuario.email,
         -- ENDERECO DE ENTREGA
         v_endereco_e.endereco,
         v_endereco_e.numero,
         v_endereco_e.bairro,
         v_endereco_e.referencia,
         v_endereco_e.cidade,
         v_endereco_e.uf,
         v_endereco_e.cep,
         v_endereco_e.complemento,
         v_endereco_e.dddresid,
         v_endereco_e.foneresid,
         v_endereco_e.ramalresid,
         v_endereco_e.dddcoml,
         v_endereco_e.fonecoml,
         v_endereco_e.ramalcoml,
         v_endereco_e.dddcelul,
         v_endereco_e.fonecelul,
         wcodcli,
         wendent);

  pmens := pmens || v_mens;

  -- Atualiza o codigo do cliente no site
  update web_usuarios
  set    codcli_gemco = wcodcli
  where  codclilv     = pcodclilv;

  if pdeposito <> 0 then
    if pdeposito <> f_deposito(v_endereco_e.cep) then
      raise_application_error(-20666, 'ERRO :: Depósito diferente do esperado :: Clique em "Sair" e selecione o cliente novamente para carregar os dados corretamente');
    end if;
  end if;

  -- GRAVA CLIENTE E O ENDERECO DE ENTREGA
  website.proc_grava_pedido_site(
         -- PEDIDO
         pcodfil,
         pprontuario,
         pvendedor,
         wcodcli,
         wendent,
         pdeposito,
         pdtfaturamento,
         pfontemidia,
         v_numcontra,
         pnumlistacasam,
         pobs,
         v_vlentrada,
         pvlfrete,
         pvlguia,
         pvlaliquota,
         pdiasentregamin,
         pdiasentregamax,
         ptransportadora,
         pvlmercad,
         pvljurosfin,
         pvlTaxaJuros,
         pvltotal,
         pformapagto,
         pcondpgto,
         ppjuros,
         -- DADOS DO CARTAO
         padmcartao,
         f_encripta(pnumcartao),
         pnumcartaoCripto,
         pcodseg,
         pnomecartao,
         pdtvctocartao,
         -- ITENS
         arr_coditprod,
         arr_seqgarant,
         arr_tpitem,
         arr_qtdcomp,
         arr_precounit,
         arr_desconto,
         arr_desconto_web,
         arr_juros_item,
         -- PARCELAS
         arr_dtvencto,
         arr_vlrparcela,
         pBancoDebito,
         pCodEmailMkt,
         -- log de venda
         pLogVenda,
         -- VARIAVEIS DE RETORNO
         pnumpedven,
         v_mens,
         -- VARIAVEIS PARA OS LIVROS NO SITE
         pCodPedAgrupado,
         pDesmembrado,
         pFilialRetirar,
         -- VARIAVEIS
         pPerfil,
         pOrigem,
         pPortal,
         arr_is_brindes,
         pVlicmret,
         -- variaveis de agendamento
         p_data_agendamento_entrega,
         p_turno_agendamento_entrega,
         p_jsession,
         pRefaturamento,
         -- parâmetros do televendas
         p_frete_tele,
         -- central de descontos
         p_numcupom,
         p_tip_desc,
         p_per_desc,
         p_vlr_desc,
         pvldesccapa,
         p_venc_boleto
         );

  pmens := pmens || v_mens;

  commit;
exception
  when others then
    rollback;
    
declare
  v_mensagem clob;
begin
  v_mensagem := '
declare
  
  v1 varchar2(200);
  v2 varchar2(200);
  
begin
  
  website.proc_pedido_site_tmp
  ( pcodclilv        => ''' || pcodclilv || '''
  , pcodendlv        => ''' || pcodendlv || '''
  , pdtfaturamento   => to_date(''' || to_char(pdtfaturamento,'dd/mm/yyyy') || ''',''dd/mm/yyyy'')
  , pcodfil          => ''' || pcodfil || '''
  , pprontuario      => ''' || pprontuario || '''
  , pvendedor        => ''' || pvendedor || '''
  , pdeposito        => ''' || pdeposito || '''
  , pfontemidia      => ''' || pfontemidia || '''
  , pnumlistacasam   => ''' || pnumlistacasam || '''
  , pobs             => ''' || substr(pobs,1,100) || '''
  , pvlfrete         => ''' || replace(pvlfrete,',','.') || '''
  , pvlguia          => ''' || replace(pvlguia,',','.') || '''
  , pvlaliquota      => ''' || replace(pvlaliquota,',','.') || '''
  , pdiasentregamin  => ''' || pdiasentregamin || '''
  , pdiasentregamax  => ''' || pdiasentregamax || '''
  , ptransportadora  => ''' || ptransportadora || '''
  , pvlmercad        => ''' || replace(pvlmercad,',','.') || '''
  , pvljurosfin      => ''' || replace(pvljurosfin,',','.') || '''
  , pvltaxajuros     => ''' || replace(pvltaxajuros,',','.') || '''
  , pvltotal         => ''' || replace(pvltotal,',','.') || '''
  , pformapagto      => ''' || pformapagto || '''
  , padmcartao       => ''' || padmcartao || '''
  , pnumcartao       => ''' || pnumcartao || '''
  , pnumcartaocripto => ''' || pnumcartaocripto || '''
  , pcodseg          => ''' || pcodseg || '''
  , pnomecartao      => ''' || pnomecartao || '''
  , pdtvctocartao    => to_date(''' || to_char(pdtvctocartao,'dd/mm/yyyy') || ''',''dd/mm/yyyy'')
  , pcoditprod       => ''' || pcoditprod || '''
  , pseqgarantia     => ''' || pseqgarantia || '''
  , ptpitem          => ''' || ptpitem || '''
  , pqtcomp          => ''' || pqtcomp || '''
  , pprecounit       => ''' || pprecounit || '''
  , pvldesconto      => ''' || pvldesconto || '''
  , pdescontoweb     => ''' || pdescontoweb || '''
  , pitemvljuros     => ''' || pitemvljuros || '''
  , pdtvcto          => ''' || pdtvcto || '''
  , pvlrparcela      => ''' || pvlrparcela || '''
  , pbancodebito     => ''' || pbancodebito || '''
  , pcodemailmkt     => ''' || pcodemailmkt || '''
  , plogvenda        => ''' || plogvenda || '''
  , prefaturamento   => ''' || prefaturamento || '''
  , pnumpedven       => v1
  , pmens            => v2
  , pcodpedagrupado  => ''' || pcodpedagrupado || '''
  , pdesmembrado     => ''' || pdesmembrado || '''
  , pfilialretirar   => ''' || pfilialretirar || '''
  , pperfil          => ''' || pperfil || '''
  , porigem          => ''' || porigem || '''
  , pportal          => ''' || pportal || '''
  , pisbrinde        => ''' || pisbrinde || '''
  , pvlicmret        => ''' || replace(pvlicmret,',','.') || '''
  , p_data_agendamento_entrega  => to_date(''' || to_char(p_data_agendamento_entrega,'dd/mm/yyyy') || ''',''dd/mm/yyyy'')
  , p_turno_agendamento_entrega => ''' || p_turno_agendamento_entrega || '''
  , p_jsession       => ''' || p_jsession || '''
  , p_frete_tele     => ''' || replace(p_frete_tele,',','.') || '''
  , p_numcupom       => ''' || p_numcupom || '''
  , p_tip_desc       => ''' || p_tip_desc || '''
  , p_per_desc       => ''' || replace(p_per_desc,',','.') || '''
  , p_vlr_desc       => ''' || replace(p_vlr_desc,',','.') || '''
  , pvldesccapa      => ''' || replace(pvldesccapa,',','.') || '''
  , p_venc_boleto    => to_date(''' || to_char(p_venc_boleto,'dd/mm/yyyy') || ''',''dd/mm/yyyy'')
  ) ;
  
  dbms_output.put_line(v1);
  dbms_output.put_line(v2);
  
end;';
  
  send_mail('site-erros@colombo.com.br','site-erros@colombo.com.br','PROC_PEDIDO_SITE_TMP','Erro: ' || chr(13) || chr(13) || sqlerrm || ' - Backtrace: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || chr(13) || 'Debug: ' || chr(13) || chr(13) || chr(13) || v_mensagem);
end;
    
    pmens := 'Erro na PROC_PEDIDO_SITE_TMP ' || pmens || ' ' || sqlerrm || ' - Backtrace: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
    raise_application_error(-20903, pmens);
end proc_pedido_site_tmp;
/
