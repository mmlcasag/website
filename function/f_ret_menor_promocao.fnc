create or replace function f_ret_menor_promocao
( p_coditprod            in number
, p_codfil               in number
, p_codlinha             in number
, p_codfam               in number
, p_codsitprod           in varchar2
, p_traz_param_no_return in boolean default null
) return varchar2 is
  
  v_seq_menor_vlr           number;
  v_ano_menor_vlr           date;
  v_validade_menor_vlr      date;
  v_menor_valor             number;
  
  v_seq_per_dscto           number;
  v_ano_per_dscto           date;
  v_validade_per_dscto      date;
  v_per_desconto            number;
  
  v_seq_per_dscto_max1      number;
  v_ano_per_dscto_max1      date;
  v_validade_per_dscto_max1 date;
  v_per_desconto_max1       number;
  
  v_seq_per_dscto_max2      number;
  v_ano_per_dscto_max2      date;
  v_validade_per_dscto_max2 date;
  v_per_desconto_max2       number;
  
  v_per_desconto1           number;
  v_preco                   number;
  v_vlpromo                 number;
  v_minimo                  number;
  v_codforne                number;
  v_rejeitados              number;
  
  v_seq_result              number;
  v_ano_result              date;
  v_validade_result         date;
  
begin
  
  -- seleciona o menor preço promocional
  v_menor_valor        := 0;
  v_seq_menor_vlr      := null;
  v_ano_menor_vlr      := null;
  v_validade_menor_vlr := null;
  begin
    select nvl(min(it.vlr_promocao), 0)
      into v_menor_valor
      from web_promocoes   pr,
           web_prom_itens  it,
           web_prom_grupos gr,
           web_prom_lojas  lj
     where pr.seq_promocao = it.seq_promocao
       and it.seq_grupo = gr.seq_grupo
       and it.seq_promocao = gr.seq_promocao
       AND IT.ANO = GR.ANO
       and lj.seq_promocao = gr.seq_promocao
       AND LJ.ANO = GR.ANO
       and lj.codfil = p_codfil
       and it.coditprod = p_coditprod
       and it.vlr_promocao > 0
       and pr.dat_cancelamento is null
       and pr.status = 2
       and trunc(sysdate) between pr.dat_inicial and pr.dat_final;
    
    if (v_menor_valor > 0) then
      select it.seq_promocao, it.ano, pr.dat_final
        into v_seq_menor_vlr, v_ano_menor_vlr, v_validade_menor_vlr
        from web_promocoes   pr,
             web_prom_itens  it,
             web_prom_grupos gr,
             web_prom_lojas  lj
       where pr.seq_promocao = it.seq_promocao
         and it.seq_grupo = gr.seq_grupo
         and it.seq_promocao = gr.seq_promocao
         and lj.seq_promocao = gr.seq_promocao
         and lj.codfil = p_codfil
         and it.coditprod = p_coditprod
         and it.vlr_promocao > 0
         and pr.dat_cancelamento is null
         and pr.status = 2
         and nvl(it.vlr_promocao, 0) = v_menor_valor
         and trunc(sysdate) between pr.dat_inicial and pr.dat_final
         and rownum = 1;
    end if;
  exception
    when others then
      v_menor_valor        := 0;
      v_seq_menor_vlr      := null;
      v_ano_menor_vlr      := null;
      v_validade_menor_vlr := null;
  end;
  
  -- seleciona o preco de venda da loja
  begin
    select nvl(preco, 0)
      into v_preco
      from cad_preco
     where codfil = p_codfil
       and codembal = 0
       and coditprod = p_coditprod;
  exception
    when others then
      v_preco := 0;
  end;
  
  v_per_desconto       := 0;
  v_seq_per_dscto      := null;
  v_ano_per_dscto      := null;
  v_validade_per_dscto := null;
  begin
    select nvl(max(pr.per_desconto), 0)
      into v_per_desconto
      from web_prom_lojas pl, web_promocoes pr
     where pl.seq_promocao = pr.seq_promocao
       and pl.ano = pr.ano
       and pl.codfil = p_codfil
       and pr.codlinha = p_codlinha
       and pr.codfam = p_codfam
       and pr.codsitprod = decode(p_codsitprod, '* ', '*', p_codsitprod)
       and pr.dat_cancelamento is null
       and trunc(sysdate) between pr.dat_inicial and pr.dat_final;
    
    if (v_per_desconto > 0) then
      select pr.seq_promocao, pr.ano, pr.dat_final
        into v_seq_per_dscto, v_ano_per_dscto, v_validade_per_dscto
        from web_prom_lojas pl, web_promocoes pr
       where pl.seq_promocao = pr.seq_promocao
         and pl.ano = pr.ano
         and pl.codfil = p_codfil
         and pr.codlinha = p_codlinha
         and pr.codfam = p_codfam
         and pr.codsitprod = decode(p_codsitprod, '* ', '*', p_codsitprod)
         and pr.dat_cancelamento is null
         and nvl(pr.per_desconto, 0) = v_per_desconto
         and trunc(sysdate) between pr.dat_inicial and pr.dat_final
         and rownum = 1;
    end if;
  exception
    when others then
      v_per_desconto       := 0;
      v_seq_per_dscto      := null;
      v_ano_per_dscto      := null;
      v_validade_per_dscto := null;
  end;
  
  --seleciona o fornecedor do item
  select codforne
    into v_codforne
    from cad_itprod
   where coditprod = p_coditprod;
  
  v_per_desconto1 := 0;
  
  v_per_desconto_max1       := 0;
  v_seq_per_dscto_max1      := null;
  v_ano_per_dscto_max1      := null;
  v_validade_per_dscto_max1 := null;
  begin
    select nvl(max(pr.per_desconto), 0)
      into v_per_desconto_max1
      from web_prom_lojas pl, web_promocoes pr
     where pl.ano = pr.ano
       and pl.seq_promocao = pr.seq_promocao
       and pl.codfil = p_codfil
       and pr.codforne in (v_codforne, 0)
       and pr.dat_cancelamento is null
       and pr.flg_item = 'N'
       and trunc(sysdate) between pr.dat_inicial and pr.dat_final
       and nvl(pr.codsitprod, p_codsitprod) = decode(p_codsitprod, '* ', '*', p_codsitprod)
       and pr.codfam = p_codfam
       and pr.codlinha in (p_codlinha, 0, 99)
       and pr.per_desconto is not null;
    
    if (v_per_desconto_max1 > 0) then
      select pr.seq_promocao, pr.ano, pr.dat_final
        into v_seq_per_dscto_max1,
             v_ano_per_dscto_max1,
             v_validade_per_dscto_max1
        from web_prom_lojas pl, web_promocoes pr
       where pl.ano = pr.ano
         and pl.seq_promocao = pr.seq_promocao
         and pl.codfil = p_codfil
         and pr.codforne in (v_codforne, 0)
         and pr.dat_cancelamento is null
         and pr.flg_item = 'N'
         and trunc(sysdate) between pr.dat_inicial and pr.dat_final
         and nvl(pr.codsitprod, p_codsitprod) = decode(p_codsitprod, '* ', '*', p_codsitprod)
         and pr.codfam = p_codfam
         and pr.codlinha in (p_codlinha, 0, 99)
         and nvl(pr.per_desconto, 0) = v_per_desconto_max1
         and pr.per_desconto is not null
         and rownum = 1;
    end if;
  exception
    when others then
      v_per_desconto_max1       := 0;
      v_seq_per_dscto_max1      := null;
      v_ano_per_dscto_max1      := null;
      v_validade_per_dscto_max1 := null;
  end;
  
  v_per_desconto_max2       := 0;
  v_seq_per_dscto_max2      := null;
  v_ano_per_dscto_max2      := null;
  v_validade_per_dscto_max2 := null;
  begin
    select nvl(max(pr.per_desconto), 0)
      into v_per_desconto_max2
      from web_prom_lojas pl, web_promocoes pr
     where pl.ano = pr.ano
       and pl.seq_promocao = pr.seq_promocao
       and pl.codfil = p_codfil
       and pr.codforne in (v_codforne, 0)
       and pr.dat_cancelamento is null
       and pr.flg_item = 'N'
       and trunc(sysdate) between pr.dat_inicial and pr.dat_final
       and nvl(pr.codsitprod, p_codsitprod) = decode(p_codsitprod, '* ', '*', p_codsitprod)
       and pr.codfam = 0
       and pr.codlinha in (p_codlinha, 0, 99)
       and pr.per_desconto is not null;
    
    if (v_per_desconto_max2 > 0) then
      select pr.seq_promocao, pr.ano, pr.dat_final
        into v_seq_per_dscto_max2,
             v_ano_per_dscto_max2,
             v_validade_per_dscto_max2
        from web_prom_lojas pl, web_promocoes pr
       where pl.ano = pr.ano
         and pl.seq_promocao = pr.seq_promocao
         and pl.codfil = p_codfil
         and pr.codforne in (v_codforne, 0)
         and pr.dat_cancelamento is null
         and pr.flg_item = 'N'
         and trunc(sysdate) between pr.dat_inicial and pr.dat_final
         and nvl(pr.codsitprod, p_codsitprod) = decode(p_codsitprod, '* ', '*', p_codsitprod)
         and pr.codfam = 0
         and pr.codlinha in (p_codlinha, 0, 99)
         and nvl(pr.per_desconto, 0) = v_per_desconto_max2
         and pr.per_desconto is not null
         and rownum = 1;
    end if;
  exception
    when others then
      v_per_desconto_max2       := 0;
      v_seq_per_dscto_max2      := null;
      v_ano_per_dscto_max2      := null;
      v_validade_per_dscto_max2 := null;
  end;
  
  -- pega o maior desconto do max
  if nvl(v_per_desconto_max2, 0) > nvl(v_per_desconto_max1, 0) then
    v_per_desconto1   := nvl(v_per_desconto_max2, 0);
    v_seq_result      := v_seq_per_dscto_max2;
    v_ano_result      := v_ano_per_dscto_max2;
    v_validade_result := v_validade_per_dscto_max2;
  else
    v_per_desconto1   := nvl(v_per_desconto_max1, 0);
    v_seq_result      := v_seq_per_dscto_max1;
    v_ano_result      := v_ano_per_dscto_max1;
    v_validade_result := v_validade_per_dscto_max1;
  end if;
  
  if v_per_desconto1 > 0 then
    if v_per_desconto1 > v_per_desconto then
      v_per_desconto := v_per_desconto1;
    else
      v_seq_result      := v_seq_per_dscto;
      v_ano_result      := v_ano_per_dscto;
      v_validade_result := v_validade_per_dscto;
    end if;
  else
    v_seq_result      := v_seq_per_dscto;
    v_ano_result      := v_ano_per_dscto;
    v_validade_result := v_validade_per_dscto;
  end if;
  
  -- verifica se o item está na lista dos rejeitados
  v_rejeitados := 0;
  begin
    select count(*)
      into v_rejeitados
      from web_promocoes pr, web_prom_itens_rejeit pj
     where pr.seq_promocao = pj.seq_promocao
       and pr.ano = pj.ano
       and pr.dat_cancelamento is null
       and trunc(sysdate) between pr.dat_inicial and pr.dat_final
       and pj.seq_grupo > 0
       and pj.coditprod = p_coditprod;
  exception
    when others then
      v_rejeitados := 0;
  end;
  
  if v_rejeitados > 0 then
    v_per_desconto := 0;
  end if;
  
  -- calula o valor da promoçao
  if nvl(v_per_desconto, 0) > 0 then
    v_vlpromo := nvl(v_preco, 0) - (nvl(v_preco, 0) * (v_per_desconto / 100));
  else
    v_vlpromo := 0;
  end if;
  
  if nvl(v_vlpromo, 0) > 0 then
    if nvl(v_menor_valor, 0) > 0 then
      if nvl(v_menor_valor, 0) > nvl(v_vlpromo, 0) then
        v_minimo := v_vlpromo;
      else
        v_minimo          := nvl(v_menor_valor, 0);
        v_seq_result      := v_seq_menor_vlr;
        v_ano_result      := v_ano_menor_vlr;
        v_validade_result := v_validade_menor_vlr;
      end if;
    else
      v_minimo := v_vlpromo;
    end if;
  else
    v_minimo          := nvl(v_menor_valor, 0);
    v_seq_result      := v_seq_menor_vlr;
    v_ano_result      := v_ano_menor_vlr;
    v_validade_result := v_validade_menor_vlr;
  end if;
  
  if p_traz_param_no_return then
    return v_minimo || ';' || v_validade_result || ';' || v_seq_result || ';' || v_ano_result || ';';
  else
    return v_minimo;
  end if;
  
end f_ret_menor_promocao;
/
