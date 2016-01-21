create or replace
FUNCTION WEB_PRECO_LOJA (p_coditprod in number, 
                         p_codfil in number) RETURN number AS 
                         
  v_codfam     cad_prod.codfam%type;
  v_codlinha   cad_prod.codlinha%type;
  v_codsitprod web_itprod.codsitprod%type;
  
  v_preco    cad_preco.preco%type;
BEGIN
  select codfam, codlinha, it.codsitprod
    into v_codfam, v_codlinha, v_codsitprod
   from cad_prod cp, web_itprod it
   where cp.codprod = it.codprod
     and it.coditprod = p_coditprod;
  
  select f_ret_menor_promocao(p_coditprod, p_codfil, v_codlinha, v_codfam, v_codsitprod)
    into v_preco
    from dual;
  
  return v_preco;  
  
END WEB_PRECO_LOJA;
/
