create or replace
FUNCTION FNC_RETORNA_INVESTIMENTO (p_produto in number,
                                                     p_portal  in number) RETURN number AS 
  v_invest_linha      web_integr_portal_invest.valor%type;
  v_invest_familia    web_integr_portal_invest.valor%type;
  v_invest_grupo      web_integr_portal_invest.valor%type;
  
  v_preco_retorno     web_integr_portal_invest.valor%type;
BEGIN

  select ivl.valor, ivf.valor, ivg.valor
          into v_invest_linha, v_invest_familia, v_invest_grupo
          from web_prod p inner join web_grupo g on p.codgrupo = g.codgrupo
                          inner join web_familia f on f.codfam = g.codfam
                          inner join web_linha l on l.codlinha = f.codlinha
                     left outer join web_integr_portal_invest ivl on ivl.codtipo = l.codlinha and ivl.tipo = 'L' and ivl.portal = p_portal
                     left outer join web_integr_portal_invest ivf on ivf.codtipo = f.codfam   and ivf.tipo = 'F' and ivf.portal = p_portal
                     left outer join web_integr_portal_invest ivg on ivg.codtipo = g.codgrupo and ivg.tipo = 'G' and ivg.portal = p_portal
         where p.codprod = p_produto;
  if (v_invest_grupo > 0) then
    v_preco_retorno := v_invest_grupo;
  elsif (v_invest_familia > 0 ) then
    v_preco_retorno := v_invest_familia;
  elsif (v_invest_linha > 0 ) then
    v_preco_retorno := v_invest_linha;
  end if;
  
  return v_preco_retorno;
  
END FNC_RETORNA_INVESTIMENTO;