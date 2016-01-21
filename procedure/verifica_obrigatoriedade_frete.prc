create or replace procedure verifica_obrigatoriedade_frete
( p_transportadora in number
, p_coditprod      in owa_util.ident_arr
, p_qtdade         in owa_util.ident_arr
, p_retorno       out varchar2
, p_mensagem      out varchar2
, p_peso_cobrar   out number
, p_cubg_cobrar   out number
) is
  
  v_linha          cad_itprod.codlinha%type;
  v_familia        cad_itprod.codfam%type;
  v_grupo          cad_itprod.codgrupo%type;
  v_produto        cad_itprod.codprod%type;
  
  v_aux            number;
  v_peso_item      number;
  v_cubg_item      number;
  
begin
  
  p_peso_cobrar    := 0;
  p_cubg_cobrar    := 0;
  
  for i in p_coditprod.first..p_coditprod.last loop
    
    -- CARREGA DADOS DOS PRODUTOS --
    begin
      select p.codlinha, p.codfam, p.codgrupo, p.codprod
      into   v_linha, v_familia, v_grupo, v_produto
      from   cad_itprod p
      where  p.coditprod = p_coditprod(i);
    exception
      when others then
        v_linha   := null;
        v_familia := null;
        v_grupo   := null;
        v_produto := null;
    end;
    
    -- CALCULA PESO E CUBAGEM DO PRODUTO
    v_peso_item := nvl(f_ret_peso_item(to_number(p_coditprod(i))),0) * nvl(to_number(p_qtdade(i)),1);
    v_cubg_item := nvl(f_ret_cubagem_item(to_number(p_coditprod(i))),0) * nvl(to_number(p_qtdade(i)),1);
    
    -- VERIFICA SE CONSTA ALGUMA RESTRIÇÃO PARA A ENTREGA --
    select count(*)
    into   v_aux
    from   transportadora_restricoes
    where (transportadora = 0                and linha = 0       and familia = 0         and grupo = 0       and produto = v_produto) or
          (transportadora = 0                and linha = 0       and familia = 0         and grupo = v_grupo and produto = 0        ) or
          (transportadora = 0                and linha = 0       and familia = 0         and grupo = v_grupo and produto = v_produto) or
          (transportadora = 0                and linha = 0       and familia = v_familia and grupo = 0       and produto = 0        ) or
          (transportadora = 0                and linha = 0       and familia = v_familia and grupo = 0       and produto = v_produto) or
          (transportadora = 0                and linha = 0       and familia = v_familia and grupo = v_grupo and produto = 0        ) or
          (transportadora = 0                and linha = 0       and familia = v_familia and grupo = v_grupo and produto = v_produto) or
          (transportadora = 0                and linha = v_linha and familia = 0         and grupo = 0       and produto = 0        ) or
          (transportadora = 0                and linha = v_linha and familia = 0         and grupo = 0       and produto = v_produto) or
          (transportadora = 0                and linha = v_linha and familia = 0         and grupo = v_grupo and produto = 0        ) or
          (transportadora = 0                and linha = v_linha and familia = 0         and grupo = v_grupo and produto = v_produto) or
          (transportadora = 0                and linha = v_linha and familia = v_familia and grupo = 0       and produto = 0        ) or
          (transportadora = 0                and linha = v_linha and familia = v_familia and grupo = 0       and produto = v_produto) or
          (transportadora = 0                and linha = v_linha and familia = v_familia and grupo = v_grupo and produto = 0        ) or
          (transportadora = 0                and linha = v_linha and familia = v_familia and grupo = v_grupo and produto = v_produto) or
          (transportadora = p_transportadora and linha = 0       and familia = 0         and grupo = 0       and produto = v_produto) or
          (transportadora = p_transportadora and linha = 0       and familia = 0         and grupo = v_grupo and produto = 0        ) or
          (transportadora = p_transportadora and linha = 0       and familia = 0         and grupo = v_grupo and produto = v_produto) or
          (transportadora = p_transportadora and linha = 0       and familia = v_familia and grupo = 0       and produto = 0        ) or
          (transportadora = p_transportadora and linha = 0       and familia = v_familia and grupo = 0       and produto = v_produto) or
          (transportadora = p_transportadora and linha = 0       and familia = v_familia and grupo = v_grupo and produto = 0        ) or
          (transportadora = p_transportadora and linha = 0       and familia = v_familia and grupo = v_grupo and produto = v_produto) or
          (transportadora = p_transportadora and linha = v_linha and familia = 0         and grupo = 0       and produto = 0        ) or
          (transportadora = p_transportadora and linha = v_linha and familia = 0         and grupo = 0       and produto = v_produto) or
          (transportadora = p_transportadora and linha = v_linha and familia = 0         and grupo = v_grupo and produto = 0        ) or
          (transportadora = p_transportadora and linha = v_linha and familia = 0         and grupo = v_grupo and produto = v_produto) or
          (transportadora = p_transportadora and linha = v_linha and familia = v_familia and grupo = 0       and produto = 0        ) or
          (transportadora = p_transportadora and linha = v_linha and familia = v_familia and grupo = 0       and produto = v_produto) or
          (transportadora = p_transportadora and linha = v_linha and familia = v_familia and grupo = v_grupo and produto = 0        ) or
          (transportadora = p_transportadora and linha = v_linha and familia = v_familia and grupo = v_grupo and produto = v_produto) ;
    
    -- CASO ENCONTRAR, NÃO DEIXA ENTREGAR --
    if v_aux > 0 then
      p_retorno     := 'S';
      p_mensagem    := '--> Obrigatoriedade de Frete - Entrega possui restrição. Será necessário cobrar frete para este item.';
      p_peso_cobrar := p_peso_cobrar + v_peso_item;
      p_cubg_cobrar := p_cubg_cobrar + v_cubg_item;
    end if;
    
  end loop;
  
  if p_retorno is null then
     p_retorno      := 'N';
     p_mensagem     := '--> Obrigatoriedade de Frete - Entrega não possui restrição.';
  else
     p_cubg_cobrar  := round(nvl(p_cubg_cobrar,0) * 300,2);
  end if;
  
end verifica_obrigatoriedade_frete;
/
