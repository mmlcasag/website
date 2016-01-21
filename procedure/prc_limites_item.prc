create or replace procedure prc_limites_item
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
  
  begin
    select margem, preco, desconto
    into   p_margemmin, p_precomin, p_maxdesc
    from   web_itprod_limites
    where  codfil    = p_codfil
    and    coditprod = p_coditprod;
  exception
    when others then
      prc_ret_limites_item(p_coditprod, p_codfil, p_margemmin, p_precomin, p_maxdesc);
      
      insert into web_itprod_limites
        ( codfil, coditprod, margem, preco, desconto )
      values
        ( p_codfil, p_coditprod, p_margemmin, p_precomin, p_maxdesc );
  end;
  
end prc_limites_item;
/
