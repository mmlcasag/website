CREATE OR REPLACE PROCEDURE "PROC_CALCULA_FRETE"
( p_numero_cep       in number
, p_cod_filial       in number
, p_cod_item         in owa_util.ident_arr
, p_qtdade           in owa_util.ident_arr
, p_valor_nota       in number
, p_valor_frete      out number
, p_dias_min         out number
, p_dias_max         out number
, p_transportadora   out number
, p_aliquota         out number
, p_vlrguia          out number
, p_listacasamento   in number  default null
, p_deposito         in number  default null
, p_retira_filial    in number  default null
, p_debug            in boolean default false
, p_calcula_aliquota in boolean default true
, p_arr_vlfrete      out owa_util.ident_arr
, p_arr_diasmin      out owa_util.ident_arr
, p_arr_diasmax      out owa_util.ident_arr
, p_arr_transp       out owa_util.ident_arr
, p_arr_filiais      out owa_util.ident_arr
, p_vlr_ret_loja     out number             -- valor do frete se retira em loja
, p_vlrtelevendas    in number default null -- valor do frete negociado no televendas
, p_perfil           in number default 1    -- perfil do vendedor web (aplicação) para retira em loja
) is

  cursor curtransp ( p_uf in varchar2 ) is
  select transportadora
  from   transportadora_uf
  where  uf = p_uf;

  cursor cur_entrega_expressa ( p_uf in varchar2 , p_cep in number ) is
  select ee.id, ee.codtransp, tr.descricao, ee.uf, ee.cepini, ee.cepfim
  from   web_entrega_expressa ee, fretes_transportadora tr
  where  tr.codigo = ee.codtransp
  and    ee.uf     = p_uf
  and    ee.cepini is not null
  and    ee.cepfim is not null
  and    p_cep  between ee.cepini and ee.cepfim
  union
  select ee.id, ee.codtransp, tr.descricao, ee.uf, ee.cepini, ee.cepfim
  from   web_entrega_expressa ee, fretes_transportadora tr
  where  tr.codigo = ee.codtransp
  and    ee.uf     = p_uf
  and    ee.cepini is null
  and    ee.cepfim is null;

  t_cp                correio_parametros%rowtype;
  t_lp                lojas_parametros%rowtype;
  t_tp                transportadora_parametros%rowtype;

  n_cont              number := 0;
  v_aux               number := 0;
  v_aux1              number := 0;
  v_aux2              number := 0;
  v_aux3              number := 0;
  v_aux4              number := 0;
  v_aux5              number := 0;
  v_aux6              number := 0;
  v_cubagem           number := 0;
  v_cubg_item         number := 0;
  v_peso_item         number := 0;
  v_cubg_total        number := 0;
  v_peso_total        number := 0;
  v_cubg_cobrar       number := 0;
  v_peso_cobrar       number := 0;

  v_vai_correio       boolean := true;
  v_tem_promocao      boolean := true;
  v_tem_loja          boolean := false;
  v_vai_frota         boolean := false;
  v_vai_freteiro      boolean := false;
  v_tem_lojasec       boolean := false;
  v_vai_frotasec      boolean := false;
  v_vai_freteirosec   boolean := false;
  v_frete_gratis      boolean := false;
  v_anula_flag        boolean := false;
  v_anula_fgratis     boolean := false;
  v_restricao         boolean := false;

  arr_transp          util.ident_arr;
  arr_filiais         util.ident_arr;

  v_uf                cad_cep.uf%type;
  v_cidade            cad_cep.local%type;
  v_codcid            cad_cidade.codlocal%type;
  v_tipo              cad_cidade.col_itapemirim_tipo%type;
  v_tipocidade        cad_cidade.tipo%type;
  v_fg                transportadora_uf.frete_gratis%type;
  v_descricao         fretes_transportadora.descricao%type;
  v_codfil            cad_filial.codfil%type;
  v_peso              cad_prod.pesounit%type;
  v_altura            cad_prod.altura%type;
  v_largura           cad_prod.largura%type;
  v_comprimento       cad_prod.comp%type;
  v_linha             web_familia.codlinha%type;
  v_familia           web_grupo.codfam%TYPE;
  v_grupo             web_prod.codgrupo%type;

  v_deposito          number;
  v_valor_frete       number;
  v_dias_min          number;
  v_dias_max          number;

  v_vlrlimite         web_imptribut_frete.vlrlimite%type;
  v_estorig           web_imptribut_frete.estorig%type;
  v_tem_desconto      varchar2(1);
  v_prc_desconto      number;
  v_men_desconto      number := 0;
  v_vlfrete_fixo      number := 0;
  v_men_fretefixo     number := 0;

  v_dtentrega1        date;
  v_dtentrega2        date;

  v_numero_cep        cad_filial.cep%type;
  v_codcidsec         cad_cidade.codlocal%type;
  v_cidadesec         cad_filial.cidade%type;

  v_retorno           varchar2(200);
  v_mensagem          varchar2(200);
  bloqueio_entrega    exception;

  c1                  util.ref_cursor;
  v_sql               varchar2(4000);
  v_ret_perfil        char := 'N';
begin

  -------------------------------------------------------------------------------------

  p_valor_frete    := 999999;
  p_transportadora := 0;
  p_dias_min       := 0;
  p_dias_max       := 0;

  -- BUSCA PARÂMETROS DAS LOJAS --
  select * into t_lp from lojas_parametros;
  select * into t_cp from correio_parametros;
  select * into t_tp from transportadora_parametros;

  -- INICIALIZA FLAG V_FRETE_GRATIS
  if p_cod_filial = 400 then
    v_frete_gratis := true;
  else
    v_frete_gratis := false;
  end if;

  v_numero_cep := p_numero_cep;

  -------------------------------------------------------------------------------------

  -- VERIFICA O DEPÓSITO A PARTIR DO NÚMERO DO CEP
  if nvl(p_deposito,0) = 0  then
    v_deposito := f_deposito(v_numero_cep);
  else
    v_deposito := p_deposito;
  end if;

  -------------------------------------------------------------------------------------

  -- BUSCA CIDADE E UF DO COMPRADOR ATRAVÉS DO CEP --

  -- VERIFICA TIPO DE CIDADE
  begin
    select nvl(tipo,'M')
    into   v_tipocidade
    from   cad_cidade
    where  cep = v_numero_cep;
  exception
    when others then
      v_tipocidade := 'M';
  end;

  -- TRATAMENTO PARA MUNICÍPIOS
  if nvl(v_tipocidade,'M') = 'M' then
    begin
      select a.codlocal, trim(b.local), trim(b.uf)
      ,      nvl(a.col_itapemirim_tipo,'I')
      into   v_codcid, v_cidade, v_uf, v_tipo
      from   cad_cidade a, cad_cep b
      where  trim(b.local) = trim(a.local)
      and    trim(b.uf)    = trim(a.uf)
      and    b.cep         = v_numero_cep
      and    rownum        = 1;
    exception
      when others then
        raise_application_error(-20001, 'O CEP informado é inválido ou não existe na base de dados.');
    end;

  -- TRATAMENTO PARA DISTRITOS, ETC...
  else
    begin
      select a.codlocal, trim(b.local), trim(b.uf)
      ,      nvl(a.col_itapemirim_tipo,'I')
      into   v_codcid, v_cidade, v_uf, v_tipo
      from   cad_cidade a, cad_cep b
      where  trim(b.local) = trim(a.local)
      and    trim(b.uf)    = trim(a.uf)
      and    a.codlocal    = ( select c.codlocal_pai from cad_cidade c where c.cep = v_numero_cep )
      and    rownum        = 1;
    exception
      when others then
        raise_application_error(-20001, 'O CEP informado é inválido ou não existe na base de dados.'||v_numero_cep);
    end;
  end if;

  -------------------------------------------------------------------------------------

  -- VERIFICA FORMAS DE ENTREGA NA CIDADE DO COMPRADOR --
  select count(f.codfil)
  ,      sum(decode(nvl(f.col_veic_entrega,'N'), 'S', 1, 0))
  ,      sum(decode(nvl(f.col_freteiro,'N')    , 'S', 1, 0))
  into   v_aux1, v_aux2, v_aux3
  from   cad_filial f
  where  nvl(f.status,0)   <> 9
  and    nvl(f.codregiao,0)<> 99
  and    f.col_codcidade    = v_codcid
  and    nvl(f.col_tpfil,'D') = 'L'
  and    nvl(f.col_nvlpreco,0) != 999; -- Lojas Cybelar

  -- SELECT RETORNA NUMBER, AQUI PASSA PARA BOOLEAN
  if nvl(v_aux1,0) > 0 then
    v_tem_loja := true;
  end if;

  -- SELECT RETORNA NUMBER, AQUI PASSA PARA BOOLEAN
  if nvl(v_aux2,0) > 0 then
    v_vai_frota := true;
  end if;

  -- SELECT RETORNA NUMBER, AQUI PASSA PARA BOOLEAN
  if nvl(v_aux3,0) > 0 then
    v_vai_freteiro := true;
  end if;

  -- SE NÃO HÁ LOJA NA CIDADE, LOGO NÃO HÁ FRETEIRO NEM FROTA PRÓPRIA
  if not v_tem_loja then
    v_vai_frota := false;
    v_vai_freteiro := false;
  end if;

  v_codcidsec := '';
  v_cidadesec := '';
  if not v_vai_freteiro and not v_vai_frota then
    -- SE NÃO HÁ LOJA NA CIDADE, VERIFICA SE A FRETEIRO DE OUTRA CIDADE (Tabela: CIDADES_FRETEIROS)
    begin
      select fil.col_codcidade, fil.cidade
      into   v_codcidsec, v_cidadesec
      from   cad_filial fil, cidades_freteiros cf, cad_cidade cid, cad_cep cep
      where  cep.cep            = p_numero_cep
      and    trim(cid.local)    = trim(cep.local)
      and    trim(cid.uf)       = trim(cep.uf)
      and    cf.cod_local       = cid.codlocal
      and    cf.status          = 0
      and    fil.codfil         = cf.codfil;
    exception
      when no_data_found then
        v_codcidsec := '';
        v_cidadesec := '';
    end;

    -- SELECT RETORNA NUMBER, AQUI PASSA PARA BOOLEAN
    if nvl(v_aux4,0) > 0 then
      v_tem_lojasec := true;
    end if;

    -- SELECT RETORNA NUMBER, AQUI PASSA PARA BOOLEAN
    if nvl(v_aux5,0) > 0 then
      v_vai_frotasec := true;
    end if;

    -- SELECT RETORNA NUMBER, AQUI PASSA PARA BOOLEAN
    if nvl(v_aux6,0) > 0 then
      v_vai_freteirosec := true;
    end if;

    -- SE NÃO HÁ LOJA NA CIDADE, LOGO NÃO HÁ FRETEIRO NEM FROTA PRÓPRIA
    if not v_tem_loja then
      v_vai_frotasec := false;
      v_vai_freteirosec := false;
    end if;

    -- VERIFICA FORMAS DE ENTREGA NA CIDADE SECUNDÁRIA --
    select count(f.codfil)
    ,      sum(decode(nvl(f.col_veic_entrega,'N'), 'S', 1, 0))
    ,      sum(decode(nvl(f.col_freteiro,'N')    , 'S', 1, 0))
    into   v_aux4, v_aux5, v_aux6
    from   cad_filial f
    where  nvl(f.status,0)   <> 9
    and    nvl(f.codregiao,0)<> 99
    and    f.col_codcidade    = v_codcidsec
    and    nvl(f.col_tpfil,'D') = 'L'
    and    nvl(f.col_nvlpreco,0) != 999; -- Lojas Cybelar

    -- SELECT RETORNA NUMBER, AQUI PASSA PARA BOOLEAN
    if nvl(v_aux4,0) > 0 then
      v_tem_lojasec := true;
    end if;

    -- SELECT RETORNA NUMBER, AQUI PASSA PARA BOOLEAN
    if nvl(v_aux5,0) > 0 then
      v_vai_frotasec := true;
    end if;

    -- SELECT RETORNA NUMBER, AQUI PASSA PARA BOOLEAN
    if nvl(v_aux6,0) > 0 then
      v_vai_freteirosec := true;
    end if;
  end if;

  -------------------------------------------------------------------

  if p_debug then
    htp.bold('Informações Principais'); htp.br;
    htp.br;

    htp.p('Filial de Venda: ' || lpad(p_cod_filial,3,'0')); htp.br;
    htp.p('Depósito de Entrega: ' || v_deposito); htp.br;
    htp.p('Cidade do Comprador: ' || v_codcid || ' - ' || v_cidade || ' / ' || v_uf || ' / ' || v_tipo || ' / ' || v_tipocidade); htp.br;

    if v_tem_loja then
      htp.p('--> Tem loja na cidade'); htp.br;
    else
      htp.p('--> Não tem loja na cidade'); htp.br;
    end if;

    if v_vai_frota then
      htp.p('--> Tem frota própria na cidade'); htp.br;
    else
      htp.p('--> Não tem frota própria na cidade'); htp.br;
    end if;

    if v_vai_freteiro then
      htp.p('--> Tem freteiro na cidade'); htp.br;
    else
      htp.p('--> Não tem freteiro na cidade'); htp.br;
    end if;

    htp.br;

    if v_frete_gratis then
      htp.p('Modalidade de frete grátis ativada pois filial é loja 400'); htp.br;
    else
      htp.p('Modalidade de frete grátis desativada pois filial não é loja 400'); htp.br;
    end if;
  end if;

  -- VERIFICA FRETE GRÁTIS, SETANDO COMO FALSE SE VALOR DA NOTA FOR MENOR QUE PARÂMETROS CONFIGURADOS --
  if v_tem_loja then
    if p_valor_nota < t_tp.vlfrete_comloja then
      v_frete_gratis := false;
      if p_debug then
        htp.p('Modalidade de frete grátis desativada pois valor da nota é inferior a R$ ' || util.to_curr(t_tp.vlfrete_comloja)); htp.br;
      end if;
    end if;
  else
    if p_valor_nota < t_tp.vlfrete_semloja then
      v_frete_gratis := false;
      if p_debug then
        htp.p('Modalidade de frete grátis desativada pois valor da nota é inferior a R$ ' || util.to_curr(t_tp.vlfrete_semloja)); htp.br;
      end if;
    end if;
  end if;

  if p_debug then
    if v_codcidsec is not null then
      htp.br; htp.br;
      htp.bold('Informações Secundárias:'); htp.br; htp.br;
      htp.p('Atendido pelo Freteiro da Cidade: '||v_codcidsec|| ' - '||v_cidadesec);
      htp.br;
      --
      if v_tem_lojasec then
         htp.p('--> Tem loja na cidade'); htp.br;
      else
         htp.p('--> Não tem loja na cidade'); htp.br;
      end if;

      if v_vai_frotasec then
         htp.p('--> Tem frota própria na cidade'); htp.br;
      else
         htp.p('--> Não tem frota própria na cidade'); htp.br;
      end if;

      if v_vai_freteirosec then
         htp.p('--> Tem freteiro na cidade'); htp.br;
      else
         htp.p('--> Não tem freteiro na cidade'); htp.br;
      end if;
      htp.br;
    end if;
  end if;

  if p_debug then
    htp.br;
    htp.bold('Produtos');
    htp.br;
    htp.br;
  end if;

  -------------------------------------------------------------------------------------

  -- VARRE OS ITENS
  for i in p_cod_item.first..p_cod_item.last loop

    if p_debug then
      htp.p('Produto: ' || p_cod_item(i) || ' - ' || get_codproddf(p_cod_item(i)) || ' - ' || f_ret_descricao(p_cod_item(i))); htp.br;
      htp.p('Quantidade: ' || p_qtdade(i)); htp.br;
    end if;

    -- BUSCA DADOS DOS PRODUTOS --
    begin
      select p.pesounit, p.altura, p.largura, p.comp, i.codlinha, i.codfam, i.codgrupo
      into   v_peso, v_altura, v_largura, v_comprimento, v_linha, v_familia, v_grupo
      from   cad_itprod i, cad_prod p
      where  p.codprod = i.codprod
      and    i.coditprod = to_number(p_cod_item(i));
    exception
      when others then
        raise_application_error(-20001, 'Item ' || p_cod_item(i) || ' inválido ou não cadastrado!');
    end;

    -- CALCULA PESO E CUBAGEM DO PRODUTO
    v_peso_item := nvl(f_ret_peso_item(to_number(p_cod_item(i))),0) * nvl(to_number(p_qtdade(i)),1);
    v_cubg_item := nvl(f_ret_cubagem_item(to_number(p_cod_item(i))),0) * nvl(to_number(p_qtdade(i)),1);

    -- TOTALIZADORES
    v_peso_total := v_peso_total + v_peso_item;
    v_cubg_total := v_cubg_total + v_cubg_item;

    -- CASO MEDIDAS DOS PRODUTOS FOREM MAIOR QUE AS PERMITIDAS PELOS CORREIOS, NÃO MANDA POR CORREIO --
    if (v_altura      > t_cp.altura_maxima)
    or (v_largura     > t_cp.largura_maxima)
    or (v_comprimento > t_cp.comprimento_maximo) then
      v_vai_correio := false;
      if p_debug then
        htp.p('--> Restrição de única medida - Frete não poderá ser entregue pelos correios'); htp.br;
      end if;
    else
      if p_debug then
        htp.p('--> Sem restrições de medida para entrega pelos correios'); htp.br;
      end if;
    end if;

    -- CASO MEDIDAS DOS PRODUTOS FOREM MAIOR QUE AS PERMITIDAS PELOS CORREIOS, NÃO MANDA POR CORREIO --
    if v_altura + v_largura + v_comprimento > 160 then
      v_vai_correio := false;
      if p_debug then
        htp.p('--> Restrição de medidas somadas - Frete não poderá ser entregue pelos correios'); htp.br;
      end if;
    else
      if p_debug then
        htp.p('--> Sem restrições de medidas somadas para entrega pelos correios'); htp.br;
      end if;
    end if;

    -- CASO PESO DOS PRODUTOS FOR MAIOR QUE PERMITIDO PELOS CORREIOS, NÃO MANDA POR CORREIO --
    if v_peso_total > t_cp.peso_maximo then
      v_vai_correio := false;
      if p_debug then
        htp.p('--> Restrição de peso - Frete não poderá ser entregue pelos correios'); htp.br;
        htp.br;
      end if;
    else
      if p_debug then
        htp.p('--> Sem restrições de peso para entrega pelos correios'); htp.br;
        htp.br;
      end if;
    end if;

  end loop;

  v_cubagem := round(nvl(v_cubg_total,0) * 300,2);

  if p_debug then
    htp.p('Peso Total Calculado: ' || v_peso_total || ' kg.'); htp.br;
    htp.p('Cubagem Total Calculada: ' || v_cubagem || ' cm³'); htp.br;
    htp.br;
  end if;

  -------------------------------------------------------------------------------------

  -- MONTA ARRAY DE POSSIBILIDADES
  -- AGORA FROTA PROPRIA CONCORRE JUNTO COM OUTRAS OPÇÕES
  v_aux := 0;
  for i in curtransp (v_uf) loop
    -- TRATAMENTO ESPECIAL PARA FRETEIRO E CORREIOS
    if i.transportadora in (t_lp.cod_freteiro, t_lp.cod_frota, t_lp.cod_correio) then
      -- APENAS ADICIONA FROTA PROPRIA SE FLAG ESTIVER ATIVADA
      if i.transportadora = t_lp.cod_frota and v_vai_frota then
        v_aux := v_aux + 1;
        arr_transp(v_aux) := i.transportadora;
      -- APENAS ADICIONA FRETEIRO SE FLAG ESTIVER ATIVADA
      elsif i.transportadora = t_lp.cod_freteiro and v_vai_freteiro then
        v_aux := v_aux + 1;
        arr_transp(v_aux) := i.transportadora;
      -- APENAS ADICIONA CORREIOS SE FLAG ESTIVER ATIVADA
      elsif i.transportadora = t_lp.cod_correio and v_vai_correio then
        v_aux := v_aux + 1;
        arr_transp(v_aux) := i.transportadora;
      end if;
    -- DEMAIS TRANSPORTADORAS
    else
      v_aux := v_aux + 1;
      arr_transp(v_aux) := i.transportadora;
    end if;
  end loop;
  --
  if v_vai_freteirosec then
     v_aux := v_aux + 1;
     arr_transp(v_aux) := 12; -- Freteiro
  elsif v_vai_frotasec then
     v_aux := v_aux + 1;
     arr_transp(v_aux) := 11; -- Frota Própria
  end if;

  -------------------------------------------------------------------------------------

  if p_debug then
    htp.bold('Possibilidades de Entrega'); htp.br;
    htp.br;
  end if;
  
  if arr_transp.count > 0 then
    for i in arr_transp.first..arr_transp.last loop
      begin
        --------------------------------------------------------------------------------

        -- TESTA SE REGRA DE FRETE GRÁTIS DEVE SER ANULADA OU NÃO
        v_anula_flag := false;

        select u.frete_gratis, t.descricao
        into   v_fg, v_descricao
        from   transportadora_uf u, fretes_transportadora t
        where  u.uf = v_uf
        and    u.transportadora = to_number(arr_transp(i))
        and    t.codigo = u.transportadora;

        if p_debug then
          if v_vai_freteirosec and arr_transp(i) in (11,12) then
             htp.p('Transportadora: ' || arr_transp(i) || ' - ' || v_descricao|| ' da Cidade de ' ||v_cidadesec); htp.br;
          else
             htp.p('Transportadora: ' || arr_transp(i) || ' - ' || v_descricao); htp.br;
          end if;
        end if;

        case v_fg
          when 'N' then
            v_anula_flag := true;  -- SE NÃO FOR FRETE GRÁTIS, ANULA FLAG V_FRETE_GRATIS
            if p_debug then
              htp.p('--> Se essa for a escolhida, não terá frete grátis pois ela não dá frete grátis para nenhuma localidade'); htp.br;
            end if;
          when 'S' then
            v_anula_flag := false; -- SE FOR FRETE GRÁTIS, NÃO ANULA FLAG V_FRETE_GRATIS
            if p_debug then
              htp.p('--> Se essa for a escolhida, poderá ter frete grátis pois ela dá frete grátis para qualquer localidade'); htp.br;
            end if;
          when v_tipo then
            v_anula_flag := false; -- SE FOR FRETE GRÁTIS SOMENTE PARA CAPITAL E CIDADE FOR CAPITAL, NÃO ANULA FLAG V_FRETE_GRATIS
            if p_debug then
              htp.p('--> Se essa for a escolhida, poderá ter frete grátis pois ela dá frete grátis para sua localidade'); htp.br;
            end if;
          else
            v_anula_flag := true;  -- SE FOR FRETE GRÁTIS SOMENTE PARA CAPITAL E CIDADE FOR NÃO CAPITAL, ANULA FLAG V_FRETE_GRATIS
            if p_debug then
              htp.p('--> Se essa for a escolhida, não terá frete grátis pois ela não dá frete grátis para sua localidade'); htp.br;
            end if;
        end case;

        --------------------------------------------------------------------------------

        -- ENVIA A FUNÇÃO PARA CÁLCULO DE PREÇOS E PRAZOS
        prc_fretes_calculo(to_number(arr_transp(i)), v_numero_cep, v_peso_total, v_cubagem, p_valor_nota, v_valor_frete, v_dias_min, v_dias_max, v_deposito, false, p_debug);

        --------------------------------------------------------------------------------

        -- ESCOLHE TRANSPORTADORA MAIS BARATA
        if v_valor_frete < p_valor_frete then

          -- Verifica Bloqueio de Entrega
          verifica_bloqueio_entrega
          ( to_number(arr_transp(i))
          , p_cod_item
          , v_retorno
          , v_mensagem
          ) ;

          if p_debug then
            htp.p(v_mensagem); htp.br;
          end if;

          if v_retorno = 'S' then
            raise bloqueio_entrega;
          end if;

          -- Verifica Obrigatoriedade de Frete
          verifica_obrigatoriedade_frete
          ( to_number(arr_transp(i))
          , p_cod_item
          , p_qtdade
          , v_retorno
          , v_mensagem
          , v_peso_cobrar
          , v_cubg_cobrar
          ) ;

          if v_retorno = 'S' then
            v_restricao := true;
          else
            v_restricao := false;
          end if;

          if p_debug then
            htp.p(v_mensagem); htp.br;
          end if;

          p_transportadora := to_number(arr_transp(i));
          p_dias_min       := v_dias_min;
          p_dias_max       := v_dias_max;
          p_valor_frete    := v_valor_frete;
          v_anula_fgratis  := v_anula_flag;

          if p_debug then
            htp.p('--> Por enquanto, esta transportadora foi escolhida como a melhor para fazer a entrega'); htp.br;
          end if;

        end if;

        -- SE TIVER FROTA PROPRIA NA CIDADE, ESCOLHE ELA E HONRA VALOR DA ENTREGA MAIS BARATA
        if to_number(arr_transp(i)) = t_lp.cod_frota and not v_vai_frotasec then
          p_transportadora := to_number(arr_transp(i));
          p_dias_min       := v_dias_min;
          p_dias_max       := v_dias_max;
          v_anula_fgratis  := v_anula_flag;

          if p_debug then
            htp.p('--> FROTA PRÓPRIA FARÁ A ENTREGA E HONRARÁ O PREÇO DA ENTREGA MAIS BARATA!'); htp.br;
          end if;
        end if;

        if p_debug then
          htp.br;
        end if;
      exception
        when bloqueio_entrega then
          if p_debug then
            htp.p('--> Não foi possível simular a entrega pois há um bloqueio de entrega identificado'); htp.br;
            htp.br;
          end if;
        when others then
          if p_debug then
            htp.p('--> Não foi possível simular a entrega com essa transportadora'); htp.br;
            htp.br;
          end if;
      end;
    end loop;
  end if;
  
  -- E-SEDEX
  if t_lp.opl_esedex = 'S' then

    if p_debug then
      htp.bold('Operação Especial Black Friday'); htp.br;
      htp.br;
    end if;

    if v_vai_frota and v_vai_correio and v_tipo in ('C') and v_uf in ('RS','PR') then

      begin
        prc_fretes_calculo( t_lp.cod_esedex, v_numero_cep, v_peso_total, v_cubagem, p_valor_nota, v_valor_frete, v_dias_min, v_dias_max, v_deposito, false, false);

        p_transportadora := t_lp.cod_esedex;
        p_dias_min       := v_dias_min;
        p_dias_max       := v_dias_max;
        p_valor_frete    := t_lp.vlr_frota;

        if p_debug then
          htp.p('Regras para Capital: Entrega seria feita por Frota Própria, poderia ser atendida pelos correios, então será entregue por E-Sedex!'); htp.br;
          htp.br;
        end if;
      exception
        when others then
          if p_debug then
            htp.p('Regras para Capital: Não há regras cadastradas para o E-Sedex fazer essa entrega!'); htp.br;
            htp.br;
          end if;
      end;

    elsif v_vai_frota and v_vai_correio and v_tipo in ('I') and v_uf in ('RS','PR') then

      begin
        prc_fretes_calculo( t_lp.cod_correio, v_numero_cep, v_peso_total, v_cubagem, p_valor_nota, v_valor_frete, v_dias_min, v_dias_max, v_deposito, false, false);

        p_transportadora := t_lp.cod_correio;
        p_dias_min       := v_dias_min;
        p_dias_max       := v_dias_max;
        p_valor_frete    := v_valor_frete;

        if p_debug then
          htp.p('Regras para Interior: Entrega seria feita por Frota Própria, poderia ser atendida pelos correios, então será entregue por Correios!'); htp.br;
          htp.br;
        end if;
      exception
        when others then
          if p_debug then
            htp.p('Regras para Interior: Não há regras cadastradas para o Correios fazer essa entrega!'); htp.br;
            htp.br;
          end if;
      end;

    else

      if p_debug then
        htp.p('Regras para Outros: Não foram estabelecidas regras para outros tipos de cidades!'); htp.br;
        htp.br;
      end if;

    end if;
  end if;

  -- SE TRANSPORTADORA ESCOLHIDA PEDIU PARA ANULAR FRETE GRÁTIS, ENTÃO ANULA O FRETE GRÁTIS
  if v_anula_fgratis then
    v_frete_gratis := false;
    if p_debug then
      htp.bold('Regras de frete grátis foram anuladas por parametrização na transportadoras_uf ou restrição de transportadora'); htp.br;
      htp.br;
    end if;
  end if;

  -- SE FRETE GRÁTIS ENTÃO...
  if v_frete_gratis then
    -- ... TESTA SE HÁ RESTRIÇÃO DE ENTREGA. SE SIM, DEVERÁ SER COBRADO FRETE DOS ITENS EM RESTRIÇÃO
    if v_restricao then
      if p_debug then
        htp.bold('Restrição de Frete'); htp.br;
        htp.br;
        htp.p('Será cobrado apenas o frete dos itens que possuem restrição de entrega'); htp.br;
        htp.p('O frete será recalculado com os pesos ajustados e apenas para a transportadora escolhida'); htp.br;
        htp.br;
        htp.p('Transportadora: ' || p_transportadora); htp.br;
        htp.p('Peso Total a Cobrar: ' || v_peso_cobrar || ' kg.'); htp.br;
        htp.p('Cubagem Total a Cobrar: ' || v_cubg_cobrar || ' cm³'); htp.br;
      end if;

      prc_fretes_calculo(p_transportadora, v_numero_cep, v_peso_cobrar, v_cubg_cobrar, p_valor_nota, v_valor_frete, v_dias_min, v_dias_max, v_deposito, false, p_debug);

      p_valor_frete := v_valor_frete;
      p_dias_min    := v_dias_min;
      p_dias_max    := v_dias_max;

      if p_debug then
        htp.br;
      end if;
    else
      p_valor_frete := 0;
      if p_debug then
        htp.bold('Valor do frete foi zerado por se encaixar nas regras de frete grátis da Colombo'); htp.br;
        htp.br;
      end if;
    end if;
  end if;

  -- APENAS VERIFICA AS PROMOÇÕES DE FRETE SE SIMULAÇÃO FOR DO SITE
  if p_cod_filial = 400 then

    if p_debug then
      htp.bold('Promoção de Frete'); htp.br;
      htp.br;
    end if;

    -- VERIFICA SE EXISTE ALGUMA PROMOÇÃO DE DESCONTO DE FRETE PARA O PRODUTO
    for i in p_cod_item.first..p_cod_item.last loop
      -- VERIFICA SE ITEM POSSUI PROMOÇÃO DE FRETE
      begin
        prc_promocoes_frete(v_numero_cep, to_number(p_cod_item(i)), p_valor_nota, v_tem_desconto, v_prc_desconto, v_vlfrete_fixo);
      exception
        when others then
          v_tem_desconto := 'N';
          v_prc_desconto :=  0 ;
          v_vlfrete_fixo :=  0 ;
      end;

      -- SEMPRE PRIORIZA A COLOMBO; SE FOR COMPRAR MAIS DE UM ITEM, E UM ITEM TEM PROMOÇÃO E OUTRO NÃO, NÃO DA PROMOÇÃO PRA NENHUM
      if nvl(v_tem_desconto,'N') = 'N' then
        v_tem_promocao  := false;
        v_men_desconto  := 0;
        v_men_fretefixo := 0;

        if p_debug then
          htp.p('--> Produto ' || p_cod_item(i) || ' não possui promoção de frete. Nenhum item terá promoção de frete.');
          htp.br;
        end if;
      else
        -- (PERCENTUAL) -- SEMPRE PRIORIZA A COLOMBO; SE UM ITEM TIVER PROMOÇÃO DE 20% E OUTRO DE 30%, CONSIDERA 20%.
        if v_tem_promocao and v_prc_desconto is not null then
          if nvl(v_prc_desconto,0) >= nvl(v_men_desconto,0) then
            v_men_desconto := nvl(v_prc_desconto,0);

            if p_debug then
              htp.p('--> Produto ' || p_cod_item(i) || ' possui promoção de frete. Cobrar do cliente ' || to_char(nvl(v_men_desconto,0)) || '% do valor original.');
              htp.br;
            end if;
          end if;
        -- (VALOR FIXO) -- SEMPRE PRIORIZA A COLOMBO; SE UM ITEM TIVER ENTREGA POR R$ 20,00 E OUTRA POR R$ 30,00, CONSIDERA R$ 30,00.
        elsif v_tem_promocao and v_vlfrete_fixo is not null then
          if nvl(v_vlfrete_fixo,0) >= nvl(v_men_fretefixo,0) then
            v_men_fretefixo := nvl(v_vlfrete_fixo,0);

            if p_debug then
              htp.p('--> Produto ' || p_cod_item(i) || ' possui promoção de frete fixo de R$ ' || util.to_curr(nvl(v_men_fretefixo,0)));
              htp.br;
            end if;
          end if;
        end if;
      end if;
    end loop;

    if v_tem_promocao then
      -- CONSIDERA FRETE POR PERCENTUAL
      if v_prc_desconto is not null then
        if p_debug then
          htp.p('--> Promoção de Frete: Sim. Percentual a Cobrar: ' || to_char(nvl(v_men_desconto,0)) || '%'); htp.br;
          htp.p('--> Valor do Frete Antes: R$ ' || util.to_curr(nvl(p_valor_frete,0)) || ' Valor do Frete Agora: R$ ' || util.to_curr(nvl(p_valor_frete,0) * nvl(v_men_desconto,0) / 100)); htp.br;
          htp.br;
        end if;
        p_valor_frete := nvl(p_valor_frete,0) * nvl(v_men_desconto,0) / 100;
      -- CONSIDERA FRETE FIXO
      elsif v_vlfrete_fixo is not null then
        if p_debug then
          htp.p('--> Promoção de Frete: Sim. Frete Fixo'); htp.br;
          htp.p('--> Valor do Frete Antes: R$ ' || util.to_curr(nvl(p_valor_frete,0)) || ' Valor do Frete Agora: R$ ' || util.to_curr(nvl(v_men_fretefixo,0))); htp.br;
          htp.br;
        end if;
        p_valor_frete := nvl(v_men_fretefixo,0);
      end if;
    else
      if p_debug then
        htp.p('--> Promoção de Frete: Não. Valor do Frete continuará o mesmo.'); htp.br;
        htp.p('--> Valor do Frete Antes: R$ ' || util.to_curr(nvl(p_valor_frete,0)) || ' Valor do Frete Agora: R$ ' || util.to_curr(nvl(p_valor_frete,0))); htp.br;
        htp.br;
      end if;
    end if;
  end if;

  -- SE TEM LOJA E FOR LISTA DE NOIVAS, NÃO COBRA FRETE
  if v_tem_loja and nvl(p_listacasamento,0) > 0 then
    p_valor_frete := 0;
    if p_debug then
      htp.bold('Valor do frete foi zerado por possuir loja na cidade e ser lista de casamento'); htp.br;
      htp.br;
    end if;
  end if;

  -- SE TEM LISTA DE CASAMENTO, ALTERA A DATA DE ENTREGA PARA RESPEITAR A DATA DE ENTREGA ESTIPULADA NA LISTA DE CASAMENTO
  if nvl(p_listacasamento,0) > 0 then
    begin
      select dtentrega1, dtentrega2
      into   v_dtentrega1, v_dtentrega2
      from   website.dados_identificacao_da_lista
      where  numero_da_lista = p_listacasamento;
    exception
      when others then
        v_dtentrega1 := null;
        v_dtentrega2 := null;
    end;

    if v_dtentrega1 is not null and trunc(sysdate) + nvl(p_dias_max,0) <= v_dtentrega1 then
      p_dias_min := v_dtentrega1 - trunc(sysdate);
      p_dias_max := v_dtentrega1 - trunc(sysdate);

      if p_debug then
        htp.bold('Data de entrega foi alterada para respeitar a 1ª data de entrega estipulada na lista de casamento'); htp.br;
        htp.br;
      end if;
    elsif v_dtentrega2 is not null and trunc(sysdate) + nvl(p_dias_max,0) <= v_dtentrega2 then
      p_dias_min := v_dtentrega2 - trunc(sysdate);
      p_dias_max := v_dtentrega2 - trunc(sysdate);

      if p_debug then
        htp.bold('Data de entrega foi alterada para respeitar a 2ª data de entrega estipulada na lista de casamento'); htp.br;
        htp.br;
      end if;
    end if;
  end if;

  -----------------------------------------------------------------

  -- SE CHEGOU ATÉ AQUI SEM TRANSPORTADORA DEFINIDA, ENTÃO É PORQUE NÃO HÁ COMO ENTREGAR
  if p_transportadora = 0 then
    if p_debug then
      htp.bold('ENTREGA INDISPONÍVEL PARA ESTA LOCALIDADE!'); htp.br;
      htp.br;
    else
      raise_application_error(-20001, 'Entrega indisponível para esta localidade!');
    end if;
  end if;

  --------------------------------------------------------------------------------

  -- BUSCA ESTADO DO DEPÓSITO
  begin
    select estado
    into   v_estorig
    from   cad_filial
    where  codfil = v_deposito;
  exception
    when others then
      raise_application_error(-20001, 'Depósito ' || v_deposito || ' inválido ou não cadastrado!');
  end;

  -- CÁLCULO DO VALOR DA GUIA A SER PAGO E QUE SERÁ SOMADO NO FRETE DA NOTA
  begin
    select nvl(aliquota,0), nvl(vlrlimite,0)
    into   p_aliquota, v_vlrlimite
    from   web_imptribut_frete
    where  estorig = v_estorig
    and    estdest = v_uf
    and    dtinicial <= trunc(sysdate)
    and    dtfinal is null;
  exception
    when others then
      p_aliquota  := 0;
      v_vlrlimite := 0;
  end;

  if p_aliquota > 0 and nvl(p_valor_nota,0) >= v_vlrlimite then
    p_vlrguia := (nvl(p_valor_nota,0) + nvl(p_valor_frete,0) - v_vlrlimite) * p_aliquota / 100;
  end if;

  -- 19/10/2012   Suanny/CWI Aliquota de frete
  if p_calcula_aliquota then
    p_valor_frete := nvl(p_valor_frete,0) + nvl(p_vlrguia,0);
  end if;

  -- Valor negociado pelo televendas
  if p_vlrtelevendas is not null then
    if p_debug then
      htp.bold('VALOR TOTAL SUBSTITUÍDO PELO NEGOCIADO NO TELEVENDAS: ' || util.to_curr(p_vlrtelevendas)); htp.br;
      htp.br;
    end if;
    p_valor_frete := p_vlrtelevendas;
  end if;

  if p_debug then
    htp.bold('Dias extras adicionados ao prazo de entrega: ' || fnc_retorna_parametro('LOGISTICA','DIAS EXTRAS ENTREGA')); htp.br;
    htp.br;
    htp.hr;
    htp.br;
    htp.bold('Resultado Final'); htp.br;
    htp.br;
    htp.p('Transportadora: ' || nvl(p_transportadora,0)); htp.br;
    htp.p('Valor do Frete: R$ ' || util.to_curr(nvl(p_valor_frete,0))); htp.br;
    htp.p('Prazo Mínimo: ' || nvl(p_dias_min,0) || ' dias'); htp.br;
    htp.p('Prazo Máximo: ' || nvl(p_dias_max,0) || ' dias'); htp.br;
    htp.p('Alíquota: ' || util.to_curr(nvl(p_aliquota,0)) || ' %'); htp.br;
    htp.p('Valor da Guia: R$ ' || util.to_curr(nvl(p_vlrguia,0))); htp.br;
    if p_calcula_aliquota then
      htp.p('<font color="Red">O valor de alíquota esta somado no valor de frete por que será destacado separadamente na nota.</font>'); htp.br;
    else
      htp.p('<font color="Red">O valor da alíquota não foi somado ao valor do frete, e na emissão da nota será separado.</font>'); htp.br;
    end if;
    htp.br;
  end if;

  --------------------------------------------------------------------------------

  if p_debug then
    htp.bold('Entrega Expressa'); htp.br;
    htp.br;
  end if;

  for i in cur_entrega_expressa (v_uf, v_numero_cep) loop
    begin
      if p_debug then
        htp.p('Transportadora: ' || i.codtransp || ' - ' || i.descricao); htp.br;
      end if;

      p_arr_transp(1) := i.codtransp;
      prc_fretes_calculo(p_arr_transp(1), v_numero_cep, v_peso_cobrar, v_cubg_cobrar, p_valor_nota, p_arr_vlfrete(1), p_arr_diasmin(1), p_arr_diasmax(1), v_deposito, false, false);

      if p_debug then
        htp.p('--> Valor do Frete: R$ ' || util.to_curr(nvl(p_arr_vlfrete(1),0))); htp.br;
        htp.p('--> Prazo de Entrega: de ' || p_arr_diasmin(1) || ' a ' || p_arr_diasmax(1) || ' dias'); htp.br;
        htp.br;
      end if;
    exception
      when others then
        htp.p('--> Erro: ' || sqlerrm); htp.br;
        htp.br;
    end;
  end loop;

  -----------------------------------------------------------------

  if p_debug then
    htp.bold('Opção de Retirar na Loja'); htp.br;
    htp.br;
    htp.p('Valor de frete se optar por retirar produto na loja: R$ ' || util.to_curr(t_lp.vlfrete_retira_loja)); htp.br;
    htp.br;
    htp.p('Lojas na cidade:'); htp.br;
  end if;

  n_cont := 0;
  v_mensagem := null;

  select fl_utiliza_retira_loja into v_ret_perfil from web_perfil where codigo = p_perfil;

  if(v_ret_perfil in ('S', 'T')) then
     v_sql := 'select distinct cf.codfil
                from cad_filial cf
                join cad_cep cc on cc.uf = cf.estado and cc.local = cf.cidade
                join cad_cidade ci on ci.uf = cc.uf     and ci.local = cc.local
               where nvl(cf.status,0) <> 9
                 and nvl(cf.codregiao,0) <> 99
                 and cc.cep = '||p_numero_cep;
    if(v_ret_perfil = 'S') then
      v_sql := v_sql || ' and cf.fl_retira_site = ''S'' ';
    elsif (v_ret_perfil = 'T') then
      v_sql := v_sql || ' and cf.fl_retira_tele = ''S'' ';
    end if;
    v_sql := v_sql || ' order by cf.codfil';
  end if;

  begin
  open c1 for v_sql;
    fetch c1 into v_codfil;
      loop
        n_cont := n_cont + 1;

        if n_cont = 1 then
          v_mensagem := v_mensagem || lpad(v_codfil,3,'0');
        else
          v_mensagem := v_mensagem || ', ' || lpad(v_codfil,3,'0');
        end if;
        p_arr_filiais(n_cont) := v_codfil;
    fetch c1 into v_codfil;
        exit when c1%notfound;
  end loop;
  exception when others then
    dbms_output.put_line(sqlerrm);
  end;

  p_vlr_ret_loja := t_lp.vlfrete_retira_loja;

  if p_debug then
    htp.p(v_mensagem); htp.br;
  end if;

  -----------------------------------------------------------------

exception
  when others then
    declare
      v_cod_item varchar2(1000);
      v_qtd_item varchar2(1000);
      v_debug    varchar2(100);
      v_calcula  varchar2(100);
    begin
      --
      for i in p_cod_item.first..p_cod_item.last loop
        v_cod_item := v_cod_item || p_cod_item(i) || '#';
      end loop;
      --
      for i in p_qtdade.first..p_qtdade.last loop
        v_qtd_item := v_qtd_item || p_qtdade(i) || '#';
      end loop;
      --
      if p_debug then
        v_debug := 'true';
      else
        v_debug := 'false';
      end if;
      --
      if p_calcula_aliquota then
        v_calcula := 'true';
      else
        v_calcula := 'false';
      end if;
      --
      if lower(sqlerrm) not like '%entrega indisponível para esta localidade%' then
        send_mail
        ( 'site-erros@colombo.com.br'
        , 'site-erros@colombo.com.br'
        , 'PROC_CALCULA_FRETE'
        , 'Erro: ' || sqlerrm || chr(13) ||
          'Parâmetros: ' || chr(13) ||
          '- p_numero_cep: ' || p_numero_cep || chr(13) ||
          '- p_cod_filial: ' || p_cod_filial || chr(13) ||
          '- p_cod_item: ' || v_cod_item || chr(13) ||
          '- p_qtdade: ' || v_qtd_item || chr(13) ||
          '- p_valor_nota: ' || p_valor_nota || chr(13) ||
          '- p_listacasamento: ' || p_listacasamento || chr(13) ||
          '- p_deposito: ' || p_deposito || chr(13) ||
          '- p_retira_filial: ' || p_retira_filial || chr(13) ||
          '- p_debug: ' || v_debug || chr(13) ||
          '- p_calcula: ' || v_calcula || chr(13) ||
          '- p_vlrtelevendas: ' || p_vlrtelevendas || chr(13) ||
          '- p_perfil: ' || p_perfil || chr(13)
        ) ;
      end if;
      --
      raise;
    end;
end proc_calcula_frete;
/
