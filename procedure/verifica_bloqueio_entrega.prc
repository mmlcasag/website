create or replace procedure verifica_bloqueio_entrega
( p_transportadora in number
, p_coditprod      in owa_util.ident_arr
, p_retorno       out varchar2
, p_mensagem      out varchar2
) is
  
  v_linha          cad_itprod.codlinha%type;
  v_familia        cad_itprod.codfam%type;
  v_grupo          cad_itprod.codgrupo%type;
  v_produto        cad_itprod.codprod%type;
  
  v_aux            number;
  
begin
  
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
    
    -- VERIFICA SE CONSTA ALGUMA RESTRIÇÃO PARA A ENTREGA --
    select count(*)
    into   v_aux
    from   correio_n_entrega_site
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
       p_retorno  := 'S';
       p_mensagem := '--> Bloqueio de Entrega - Entrega possui restrição. Transportadora não poderá entregar essa venda.';
    end if;
    
  end loop;
  
  if p_retorno is null then
     p_retorno  := 'N';
     p_mensagem := '--> Bloqueio de Entrega - Entrega não possui restrição.';
  end if;
  
end verifica_bloqueio_entrega;
/
