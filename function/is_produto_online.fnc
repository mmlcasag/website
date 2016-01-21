create or replace
FUNCTION IS_PRODUTO_ONLINE(
    p_codprod IN NUMBER default null,
    p_coditprod IN NUMBER default null)
RETURN BOOLEAN AS
  cursor cProduto is
    select nvl(pr.integracao_online,1)
      from web_prod pr, produto p
     where p.codprod = pr.codprod (+)
       and p.codprod = p_codprod;

  cursor cItem is
    select nvl(pr.integracao_online,1)
      from web_prod pr, produto p, cad_itprod it
     where p.codprod = pr.codprod (+)
       and p.codprod = it.codprod
       and it.coditprod = p_coditprod;

  rProd web_prod.integracao_online%type;
BEGIN
  rProd := 0;
  if(p_codprod is not null) then
    open cProduto;
    fetch cProduto into rProd;
    close cProduto;
  elsif(p_coditprod is not null) then
    open cItem;
    fetch cItem into rProd;
    close cItem;
  end if;
  if(rProd = 1) then
    return true;
  else
    return false;
  end if;
END IS_PRODUTO_ONLINE;
/
