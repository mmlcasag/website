create or replace procedure prc_pedido_valida_promocao
( p_codbrinde in number default null
, p_codprod   in number default null
) as
  
  v_nro_vendas     number;
  v_limite_vendas  web_itprod_brinde.limite_vendas%type;
  v_promocao       web_campanhas_preco.cpr_id%type;
  
begin
  
    -- brinde
    if nvl(p_codbrinde,0) > 0 then
      -- busca qtde vendas
      select count(distinct(mpw.numpedven))
      into   v_nro_vendas
      from   mov_itped_web mpw 
      where  mpw.cod_brinde = p_codbrinde;
      
      -- busca limite de vendas
      select limite_vendas
      into   v_limite_vendas
      from   web_itprod_brinde
      where  cod_brinde = p_codbrinde;
      
      if nvl(v_limite_vendas,0) > 0 and v_nro_vendas >= v_limite_vendas then
        update web_itprod_brinde
        set    fl_ativo = 'N'
        where  cod_brinde = p_codbrinde;
      end if;
    end if;
    
    -- produto
    if nvl(p_codprod,0) > 0 then
      -- busca promocao 
      select promocao
      into   v_promocao
      from ( select promocao from table(web_preco_ativo(p_codprod)) ) promocao_ativa;
      
      if nvl(v_promocao,0) > 0 then
        -- busca limite vendas
        select cpd_qtde_limite_vendas
        into   v_limite_vendas 
        from   web_camp_preco_produtos
        where  cpr_id      = v_promocao
        and    prd_codprod = p_codprod;
        
        -- se limite maior que zero, verifica qts foram vendidos
        if nvl(v_limite_vendas,0) > 0 then
          select sum(it.qtcomp)
          into   v_nro_vendas
          from   mov_itped_web w, mov_itped it
          where  w.campanha_preco = v_promocao
          and    w.coditprod in (select coditprod from web_itprod where codprod = p_codprod)
          and    w.numpedven = it.numpedven
          and    w.coditprod = it.coditprod
          and    w.codfil = it.codfil;
          
          -- verifica se promocao deve continuar ativa 
          if v_nro_vendas >= v_limite_vendas then
            update web_prod_preco
            set    cpd_flativo = 'N'
            where  codprod = p_codprod
            and    promocao = v_promocao;
            
            update web_camp_preco_produtos
            set    cpd_flativo = 'N'
            where  prd_codprod = p_codprod
            and    cpr_id = v_promocao;
          end if;
        end if;
      end if;
    end if;
    
exception
  when no_data_found then
    null;
end prc_pedido_valida_promocao;
/
