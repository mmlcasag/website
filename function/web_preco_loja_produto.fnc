create or replace FUNCTION website.WEB_PRECO_LOJA_PRODUTO
( p_codprod in number
, p_codfil in number
) RETURN number AS
  
  v_preco cad_preco.preco%type;
  
BEGIN
  
  -- chama informações do owner colombo no banco website da matriz
  -- aplicação na nuvem não chama esta function
  select max(c.preco)
  into   v_preco
  from   colombo.cad_preco c, web_itprod w
  where  codfil = p_codfil
  and    c.coditprod = w.coditprod
  and    w.codprod = p_codprod;
  
  return v_preco;
  
END WEB_PRECO_LOJA_PRODUTO;
/
