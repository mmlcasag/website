create or replace procedure prc_ret_limites_item
( p_coditprod  in number
, p_codfil     in number
, p_margemmin out number
, p_precomin  out number
, p_maxdesc   out number
) as
  
  v_rowid         varchar2(200);
  v_tipo          number;
  v_desc_vendedor number;
  
begin
  
  if f_get_id_limitores(p_coditprod, p_codfil, v_rowid, v_tipo) then
    
    if v_tipo = 1 then
      select tax_margem_menor, perc_desconto, null, desc_max_vendedor
      into   p_margemmin, p_maxdesc, p_precomin, v_desc_vendedor
      from   tipo_margens_familias
      where  rowid = v_rowid;
    end if;
    
    if v_tipo = 2 then
      select lim_menor, perc_desconto, preco_minimo, desc_max_vendedor
      into   p_margemmin, p_maxdesc, p_precomin, v_desc_vendedor
      from   limite_margem
      where  rowid = v_rowid;
    end if;
    
  end if;
  
end prc_ret_limites_item;
/
