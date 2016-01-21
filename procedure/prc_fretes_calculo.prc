create or replace procedure "PRC_FRETES_CALCULO"
( p_transportadora  in number
, p_numero_cep      in number
, p_peso            in number
, p_cubagem         in number
, p_valor_nota      in number
, p_valor_frete    out number
, p_dias_min       out number
, p_dias_max       out number
, p_deposito        in number  default null
, p_tem_promocao    in boolean default false
, p_debug           in boolean default false
) is

/************************************************************************************
   NAME:       PRC_FRETES_CALCULO
   PURPOSE:    procedure responsavel por calcular taxas, prazos e valores a partir do
               peso total dos produtos do pedido.

   REVISIONS:
   Ver        Date        Author              Description
   ---------  ----------  ------------------  ----------------------------------------
   1.0        02/07/2008  Márcio Casagrande   Criação da procedure
   1.1        29/07/2008  Márcio Casagrande   Revisão no cálculo das taxas
   1.2        04/08/2008  Márcio Casagrande   Revisão no cálculo das taxas
   1.3        15/08/2008  Márcio Casagrande   Desconsiderar dific. min e gris min.
   1.x                    vigol
*************************************************************************************/

  v_aux           number;
  v_nao_entrega   number;

  v_deposito            number := p_deposito;
  v_dia_carga           number := 0;
  v_dia_liberado        number := to_char(sysdate,'d');  
  v_dias_adic_entrega   number := 0;
  v_dias_adicionais_450 number := 0;
  v_dias_adicionais_820 number := 0;
  v_peso_excede         number := 0;
  v_peso_valendo        number;
  
  r1              fretes_calculo%rowtype;
  t_lp            lojas_parametros%rowtype;
  t_cp            correio_parametros%rowtype;
  t_tp            transportadora_parametros%rowtype;
  v_cidade        cad_cep.local%type;
  v_uf            cad_cep.uf%type;
  v_codcid        cad_cidade.codlocal%type;
  v_tipo          cad_cidade.col_itapemirim_tipo%type;
  v_aereo         cad_cidade.col_itapemirim_aereo%type;
  v_fluvial       cad_cidade.col_itapemirim_fluvial%type;
  v_dificuldade   cad_cidade.col_mercurio_taxa%type;
  v_tipocidade    cad_cidade.tipo%type;
  --
  v_vlr_min_frete_vda number := 0;
  v_km_ida_volta  cidades_freteiros.km_ida_volta%type;
  v_consiste_km   cidades_freteiros.consiste_km%type;
  v_preco_km      cidades_freteiros.preco_km%type;
  
begin

  if p_debug then
    htp.p('<font color="red">');
  end if;

  -------------------------------------------------------------------------------------

  -- VERIFICA DE QUAL DEPÓSITO SAIRÁ A MERCADORIA --
  if v_deposito is null then
     v_deposito := f_deposito(p_numero_cep);
  end if;

  -------------------------------------------------------------------------------------

  -- BUSCA PARÂMETROS DAS LOJAS --
  select * into t_lp from lojas_parametros;
  select * into t_cp from correio_parametros;
  select * into t_tp from transportadora_parametros;

  -------------------------------------------------------------------------------------

  -- BUSCA CIDADE E UF DO COMPRADOR ATRAVÉS DO CEP --

  -- VERIFICA TIPO DE CIDADE

  begin
    select nvl(tipo,'M')
    into   v_tipocidade
    from   cad_cidade
    where  cep = p_numero_cep;
  exception
    when others then
      v_tipocidade := 'M';
  end;

  if nvl(v_tipocidade,'M') = 'M' then
    -- BUSCA INFORMAÇÕES DO LOCAL DE COMPRA --
    begin
      select a.codlocal, trim(b.local), trim(b.uf)
      ,      nvl(a.col_itapemirim_tipo,'I')
      ,      nvl(a.col_mercurio_taxa,'N')
      ,      nvl(a.col_itapemirim_fluvial,0)
      ,      nvl(a.col_itapemirim_aereo,'N')
      ,      nvl(a.vlr_min_frete_vda,0)
      into   v_codcid, v_cidade, v_uf, v_tipo, v_dificuldade, v_fluvial, v_aereo, v_vlr_min_frete_vda
      from   cad_cidade a, cad_cep b
      where  trim(b.local) = trim(a.local)
      and    trim(b.uf)    = trim(a.uf)
      and    b.cep         = p_numero_cep
      and    rownum        = 1;
    exception
      when others then
        raise_application_error(-20000, 'O CEP informado é inválido ou não existe na base de dados.');
    end;
  else
    -- BUSCA INFORMAÇÕES DO LOCAL DE COMPRA --
    begin
      select a.codlocal, trim(b.local), trim(b.uf)
      ,      nvl(a.col_itapemirim_tipo,'I')
      ,      nvl(a.col_mercurio_taxa,'N')
      ,      nvl(a.col_itapemirim_fluvial,0)
      ,      nvl(a.col_itapemirim_aereo,'N')
      ,      nvl(a.vlr_min_frete_vda,0)
      into   v_codcid, v_cidade, v_uf, v_tipo, v_dificuldade, v_fluvial, v_aereo, v_vlr_min_frete_vda
      from   cad_cidade a, cad_cep b
      where  trim(b.local) = trim(a.local)
      and    trim(b.uf)    = trim(a.uf)
      and    a.codlocal    = ( select c.codlocal_pai from cad_cidade c where c.cep = p_numero_cep )
      and    rownum        = 1;
    exception
      when others then
        raise_application_error(-20000, 'O CEP informado é inválido ou não existe na base de dados.');
    end;
  end if;

  -------------------------------------------------------------------------------------

  -- VERIFICA SE CIDADE DO COMPRADOR CONSTA NA LISTA DE CEP AONDE NÃO FAZEMOS ENTREGA --
  select count(local)
  into   v_nao_entrega
  from   fretes_nao_entrega
  where  transportadora in (p_transportadora,0) -- 0 significa todas as transportadoras
  and    trim(local)    = v_cidade
  and    trim(uf)       = v_uf
  and  ( cep            = p_numero_cep or cep = 0 );

  if v_nao_entrega > 0 then
    if p_debug then
      htp.p('&nbsp;&nbsp;--> Endereço consta nos locais de não entrega.</font>'); htp.br;
    end if;
    raise_application_error(-20000,'Não realizamos entregas nesta localidade.');
  end if;

  -------------------------------------------------------------------------------------

  -- REGRAS PARA CORREIO E TRANSPORTADORAS --
  if p_transportadora not in (t_lp.cod_frota, t_lp.cod_freteiro) then

    if p_debug then
      htp.p('&nbsp;&nbsp;--> Considerar regras para correio e transportadoras'); htp.br;
    end if;

    if p_cubagem > p_peso then
      v_peso_valendo := p_cubagem;
      if p_debug then
        htp.p('&nbsp;&nbsp;--> Considerado peso cubado no cálculo: ' || util.to_curr(nvl(v_peso_valendo,0))); htp.br;
      end if;
    else
      v_peso_valendo := p_peso;
      if p_debug then
        htp.p('&nbsp;&nbsp;--> Considerado peso quilos no cálculo: ' || util.to_curr(nvl(v_peso_valendo,0))); htp.br;
      end if;
    end if;

    -- BUSCA TODAS TAXAS E VALORES CADASTRADOS NAS REGRAS DE TRANSPORTADORA --
    begin
      begin
        select *
        into   r1
        from   fretes_calculo
        where  filorig = v_deposito
        and    transportadora = p_transportadora
        and    polo = v_uf
        and    tipo = v_tipo
        and    ceil(nvl(v_peso_valendo,0)) between peso_ini and peso_fim
        and    rownum = 1;
      exception
        when others then
          select *
          into   r1
          from   fretes_calculo
          where  filorig = v_deposito
          and    transportadora = p_transportadora
          and    polo = v_uf
          and    tipo = v_tipo
          and    trunc(nvl(v_peso_valendo,0)) between peso_ini and peso_fim
          and    rownum = 1;
      end;

      -- DEFINIÇÃO DOS PRAZOS DE ENTREGA --
      p_dias_min := nvl(r1.prazo_min,0) + nvl(t_lp.dias_coleta,0);
      p_dias_max := nvl(r1.prazo_max,0) + nvl(t_lp.dias_coleta,0);

      -- CALCULA VALOR DO FRETE --
      p_valor_frete := nvl(r1.frete_minimo,0);
      if p_debug then
        htp.p('&nbsp;&nbsp;--> Frete Básico: ' || util.to_curr(nvl(r1.frete_minimo,0))); htp.br;
      end if;

      -- PESO EXCEDENTE --
      if 9999 between r1.peso_ini and r1.peso_fim then
        v_peso_excede := nvl(v_peso_valendo,0) - nvl(r1.peso_ini,0);
        p_valor_frete := p_valor_frete + nvl(r1.frete_quilo * v_peso_excede,0);
        if p_debug then
          htp.p('&nbsp;&nbsp;--> + Peso Excedente: ' || util.to_curr(nvl(r1.frete_quilo * v_peso_excede,0))); htp.br;
        end if;
      end if;

      -- AD-VALOREM --
      p_valor_frete := p_valor_frete + (p_valor_nota * (nvl(r1.frete_vlnota,0) / 100));
      if p_debug then
        htp.p('&nbsp;&nbsp;--> + Ad-Valorem: ' || p_valor_nota * (nvl(r1.frete_vlnota,0) / 100)); htp.br;
      end if;

      -- TAXAS SOBRE DESPACHO DA MERCADORIA --
      p_valor_frete := p_valor_frete + nvl(r1.taxa_despacho,0);
      if p_debug then
        htp.p('&nbsp;&nbsp;--> + Taxa Despacho: ' || util.to_curr(nvl(r1.taxa_despacho,0))); htp.br;
      end if;

      -- TAXAS SOBRE PEDÁGIOS --
      v_aux := v_peso_valendo / 100;
      --
      if v_aux = 0 then
        v_aux := 1;
      end if;

      v_aux := ceil(v_aux);

      --
      p_valor_frete := p_valor_frete + nvl(r1.pedagio * v_aux,0);
      if p_debug then
        htp.p('&nbsp;&nbsp;--> + Pedágio: ' || util.to_curr(nvl(r1.pedagio * v_aux,0))); htp.br;
      end if;

      -- TAXA DE ADMINISTRAÇÃO DO SEFAZ --
      p_valor_frete := p_valor_frete + nvl(r1.taxa_sefaz,0);
      if p_debug then
        htp.p('&nbsp;&nbsp;--> + Taxa SEFAZ: ' || util.to_curr(nvl(r1.taxa_sefaz,0))); htp.br;
      end if;

      -- CALCULA O GRIS DA EXPEDIÇÃO --
      v_aux := p_valor_nota * (nvl(r1.gris,0) / 100);
      if v_aux > nvl(r1.gris_min,0) then
        p_valor_frete := p_valor_frete + v_aux;
        if p_debug then
          htp.p('&nbsp;&nbsp;--> + GRIS Percentual: ' || util.to_curr(nvl(v_aux,0))); htp.br;
        end if;
      else
        p_valor_frete := p_valor_frete + nvl(r1.gris_min,0);
        if p_debug then
          htp.p('&nbsp;&nbsp;--> + GRIS Mínimo: ' || util.to_curr(nvl(r1.gris_min,0))); htp.br;
        end if;
      end if;

      -- CALCULA TAXA DIFICULDADE --
      if v_dificuldade = 'S' then
        v_aux := p_valor_nota * (nvl(r1.taxa_dificuldade,0) / 100);
        if v_aux > nvl(r1.taxa_dificuldade_min,0) then
          p_valor_frete := p_valor_frete + v_aux;
          if p_debug then
            htp.p('&nbsp;&nbsp;--> + Taxa Dificuldade Percentual: ' || util.to_curr(nvl(v_aux,0))); htp.br;
          end if;
        else
          p_valor_frete := p_valor_frete + nvl(r1.taxa_dificuldade_min,0);
          if p_debug then
            htp.p('&nbsp;&nbsp;--> + Taxa Dificuldade Mínimo: ' || util.to_curr(nvl(r1.taxa_dificuldade_min,0))); htp.br;
          end if;
        end if;
      end if;

      -- CALCULA TAXA AÉREA --
      if v_aereo = 'S' then
        p_valor_frete := p_valor_frete + (p_valor_nota * (nvl(r1.taxa_aereo,0) / 100));
        if p_debug then
          htp.p('&nbsp;&nbsp;--> + Taxa Aérea: ' || util.to_curr(nvl(r1.taxa_aereo,0))); htp.br;
        end if;
      end if;

      -- CALCULA TAXA FLUVIAL --
      if v_fluvial = 7 then
        p_valor_frete := p_valor_frete + (p_valor_nota * (nvl(r1.taxa_fluvial,0) / 100));
        if p_debug then
          htp.p('&nbsp;&nbsp;--> + Taxa Fluvial: ' || util.to_curr(nvl(r1.taxa_fluvial,0))); htp.br;
        end if;
      end if;

      p_valor_frete := round(nvl(p_valor_frete,0),2);

      if not p_tem_promocao then
        -- ADICIONA PERCENTUAL DE LUCRO --
        p_valor_frete := nvl(p_valor_frete,0) * (1 + (t_tp.percentual_lucro / 100));
        if p_debug then
          htp.p('&nbsp;&nbsp;--> + Percentual de Lucro: ' || util.to_curr(nvl(p_valor_frete,0) * t_tp.percentual_lucro / 100)); htp.br;
        end if;
      end if;

    exception
      when others then
        if p_debug then
          htp.p('&nbsp;&nbsp;--> Não há regras cadastradas na tabela de valores.</font>'); htp.br;
        end if;
        raise_application_error(-20000,'Não foram encontradas regras');
    end;

  -------------------------------------------------------------------------------------

  else -- REGRAS PARA FRETEIRO E FROTA PRÓPRIA --

    if p_debug then
      htp.p('&nbsp;&nbsp;--> Considerar regras para freteiro e frota própria'); htp.br;
    end if;

    -- VERIFICA QUAL DIA SERÁ FEITA A CARGA --
    begin
      -- QUANDO POSSUI LOJA NA CIDADE E ENTREGA PODE SER ESSA SEMANA --
      select *
      into   v_dia_carga, v_dias_adic_entrega
      from ( select l.dia_carga, nvl(l.dias_adic_entrega,0)
             from   roteiro_carga c, roteiro_carga_lojas l
             where  nvl(c.tipo,'A') <> 'C'
             and    nvl(l.status,0)  = 0
             and    l.dep            = v_deposito
             and    l.dep            = c.dep
             and    l.roteiro        = c.roteiro
             and    l.dia_carga      > to_char(sysdate,'d')
             and    l.loja in ( select codfil
                                from   cad_filial
                                where  col_codcidade     = v_codcid
                                and    nvl(codregiao,0) <> 99
                                and    nvl(status,0)    <> 9 )
             order  by l.dia_carga
      ) where rownum = 1;
    exception when others then
      begin
        -- QUANDO POSSUI LOJA NA CIDADE E ENTREGA SÓ PODE SER NA PRÓXIMA SEMANA --
        select *
        into   v_dia_carga, v_dias_adic_entrega
        from ( select l.dia_carga, nvl(l.dias_adic_entrega,0)
               from   roteiro_carga c, roteiro_carga_lojas l
               where  nvl(c.tipo,'A') <> 'C'
               and    nvl(l.status,0)  = 0
               and    l.dep            = v_deposito
               and    l.dep            = c.dep
               and    l.roteiro        = c.roteiro
               and    l.dia_carga      < to_char(sysdate,'d')
               and    l.loja in ( select codfil
                                  from   cad_filial
                                  where  col_codcidade     = v_codcid
                                  and    nvl(codregiao,0) <> 99
                                  and    nvl(status,0)    <> 9 )
               order  by l.dia_carga
        ) where rownum = 1;
      exception
        when others then
          -- QUANDO NÃO ENCONTRAR EM NENHUM DOS DOIS SELECTS É PQ LOJA POSSUI APENAS UM DIA DE ENTREGA
          -- E O DIA É EXATAMENTE O DIA DA SEMANA DO DIA CORRENTE
          -- NESSE CASO, PRAZO DE ENTREGA 7 DIAS, POIS SOMENTE RECEBERÁ MERCADORIA NA SEMANA QUE VEM
          v_dia_carga := to_char(sysdate,'d');
          v_dias_adic_entrega := 0;
      end;
    end;

    -- DIAS DE ENTREGA := DIAS PARA CARGA DO CAMINHÃO + DIAS PARA ENTREGA + DIAS PARA COLETA --
    -- se for frota própria retira o dia da coleta = 1 dia
    if p_transportadora = 11 then
      t_lp.dias_coleta := 0;
    end if;

    if p_debug then
      htp.p('&nbsp;&nbsp;--> Dia da Carga: ' || nvl(v_dia_carga,6)); htp.br;
      htp.p('&nbsp;&nbsp;--> Dia da Venda: ' || v_dia_liberado); htp.br;
      htp.p('&nbsp;&nbsp;--> Dias para Coleta: ' || t_lp.dias_coleta); htp.br;
    end if;

    if v_dia_carga > v_dia_liberado then
      -- Se não houver roteiro carga cadastrado considerar 6 feira como próximo dia
      p_dias_min := nvl(v_dia_carga,6) - (v_dia_liberado) + t_lp.dias_coleta;
      if p_debug then
        htp.p('&nbsp;&nbsp;--> Cálculo: ' || nvl(v_dia_carga,6) || ' - ' || v_dia_liberado || ' + ' || t_lp.dias_coleta || ' = ' || p_dias_min); htp.br;
      end if;
    else
      p_dias_min := 7 - (v_dia_liberado) + nvl(v_dia_carga,6) + t_lp.dias_coleta;
      if p_debug then
        htp.p('&nbsp;&nbsp;--> Cálculo: 7 - ' || v_dia_liberado || ' + ' || nvl(v_dia_carga,6) || ' + ' || t_lp.dias_coleta || ' = ' || p_dias_min); htp.br;
      end if;
    end if;

    -- VERIFICA SE DIA DA ENTREGA FOR DOMINGO, SOMA + 1 --
    if to_char(sysdate + p_dias_min,'d') = 1 then
      p_dias_min := p_dias_min + 1;
      if p_debug then
        htp.p('&nbsp;&nbsp;--> + 1 dia(s) pois entrega caiu em um domingo'); htp.br;
      end if;
    end if;

    p_dias_min := p_dias_min + nvl(v_dias_adic_entrega,0);
    p_dias_max := p_dias_min + 1;

    if p_debug then
      htp.p('&nbsp;&nbsp;--> + ' || nvl(v_dias_adic_entrega,0) || ' dia(s) para transporte'); htp.br;
      htp.p('&nbsp;&nbsp;--> + 1 dia(s) para o prazo máximo'); htp.br;
    end if;
    --
    if p_transportadora = 12 then
       v_km_ida_volta          := 0;
       v_consiste_km           := 'N';
       v_preco_km              := 0;
       begin
        select nvl(km_ida_volta,0), nvl(consiste_km,'N'), nvl(preco_km,0)
        into v_km_ida_volta, v_consiste_km, v_preco_km
        from cad_filial fil, cidades_freteiros cf, cad_cidade cid, cad_cep cep
        where cep.cep            = p_numero_cep
          and trim(cid.local)    = trim(cep.local)
          and trim(cid.uf)       = trim(cep.uf)
          and cf.cod_local       = cid.codlocal
          and cf.status          = 0
          and fil.codfil         = cf.codfil;
       exception
       when no_data_found then
        v_km_ida_volta          := 0;
        v_consiste_km           := 'N';
        v_preco_km              := 0;
       end;
       --
       if nvl(v_consiste_km,'N') = 'S' then
          p_valor_frete := round(nvl(v_km_ida_volta,0) * nvl(v_preco_km,0),2);
       else
          if nvl(v_vlr_min_frete_vda,0) = 0 then
             p_valor_frete := round(nvl(p_valor_frete,0),2);
          else
             p_valor_frete := round(nvl(v_vlr_min_frete_vda,0),2);
          end if;
       end if;
    else
       p_valor_frete := round(nvl(p_valor_frete,0),2);
    end if;

    if p_tem_promocao then
      if p_debug then
        htp.p('&nbsp;&nbsp;--> Não cobrou taxa de frete mínimo pois tem promoção'); htp.br;
      end if;
    else
      if nvl(v_vlr_min_frete_vda,0) = 0 then
         if nvl(p_valor_frete,0) < t_lp.min_frete then
            p_valor_frete := t_lp.min_frete;
            if p_debug then
               htp.p('&nbsp;&nbsp;--> Cobrou taxa de frete mínimo cadastrada nos parâmetros gerais'); htp.br;
            end if;
         else
            if p_debug then
              htp.p('&nbsp;&nbsp;--> Não cobrou taxa de frete mínimo'); htp.br;
            end if;
         end if;
      else
         if nvl(p_valor_frete,0) < v_vlr_min_frete_vda then
            p_valor_frete := v_vlr_min_frete_vda;
            if p_debug then
               htp.p('&nbsp;&nbsp;--> Cobrou taxa de frete mínimo cadastrada na cidade de '||v_cidade); htp.br;
            end if;
         else
            if p_debug then
              htp.p('&nbsp;&nbsp;--> Não cobrou taxa de frete mínimo'); htp.br;
            end if;
         end if;
      end if;
    end if;
  end if;

  -------------------------------------------------------------------------------------
  p_dias_min := p_dias_min + to_number(fnc_retorna_parametro('LOGISTICA','DIAS EXTRAS ENTREGA'));
  p_dias_max := p_dias_max + to_number(fnc_retorna_parametro('LOGISTICA','DIAS EXTRAS ENTREGA'));
  -------------------------------------------------------------------------------------
  
  select p.dias_adicionais_450, p.dias_adicionais_820
  into   v_dias_adicionais_450, v_dias_adicionais_820
  from   lojas_parametros p;
  
  if p_debug then
    htp.p('&nbsp;&nbsp;----Antes do somar os dias extras----'); htp.br;
    htp.p('&nbsp;&nbsp;--> Prazo Mínimo: ' || nvl(p_dias_min,0) || ' dias'); htp.br;
    htp.p('&nbsp;&nbsp;--> Prazo Máximo: ' || nvl(p_dias_max,0) || ' dias'); htp.br;
    htp.p('</font>');
  end if;  
  
  if (p_deposito = 450) then
    p_dias_min := p_dias_min + v_dias_adicionais_450;
    p_dias_max := p_dias_max + v_dias_adicionais_450;
  else
    p_dias_min := p_dias_min + v_dias_adicionais_820;
    p_dias_max := p_dias_max + v_dias_adicionais_820;
  end if;
  
  if p_debug then
    htp.p('&nbsp;&nbsp;----------------------------------------'); htp.br;
    htp.p('&nbsp;&nbsp;--> Valor do Frete: R$ ' || util.to_curr(nvl(p_valor_frete,0))); htp.br;
    htp.p('&nbsp;&nbsp;--> Prazo Mínimo: ' || nvl(p_dias_min,0) || ' dias'); htp.br;
    htp.p('&nbsp;&nbsp;--> Prazo Máximo: ' || nvl(p_dias_max,0) || ' dias'); htp.br;
    htp.p('</font>');
  end if;
  
end prc_fretes_calculo;
/
