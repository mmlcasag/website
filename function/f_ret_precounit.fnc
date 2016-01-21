create or replace function f_ret_precounit
( p_codfil    in number
, p_coditprod in number
, p_codembal  in number default 0
) return number as 
  
  -- constantes
  c_curitiba  constant number := 820;
  c_sumare    constant number := 899;
  c_dfl       constant number := 827;
  c_ita       constant number := 296;
  
  wpreco      cad_preco.preco%type;
  
begin
  
  begin
    select nvl(p.preco,0)
    into   wpreco
    from   cad_preco p
    where  p.coditprod = p_coditprod
    and    p.codfil    = p_codfil
    and    p.codembal  = 0;
  exception
    when others then
      wpreco := 0;
  end;
  
  -- Para as lojas de SC que são atendidas pelo 820 - Paraná
  if wpreco = 0 and p_codfil = c_curitiba then
    begin
      select nvl(p.preco,0)
      into   wpreco
      from   cad_preco p
      where  p.coditprod = p_coditprod
      and    p.codfil    = c_dfl
      and    p.codembal  = 0;
    exception
      when others then
        wpreco := 0;
    end;
  end if;
  
  -- Para as lojas de MG que são atendidas pelo 899 - São Paulo
  if wpreco = 0 and p_codfil = c_sumare then
    begin
      select nvl(p.preco,0)
      into   wpreco
      from   cad_preco p
      where  p.coditprod = p_coditprod
      and    p.codfil    = c_ita
      and    p.codembal  = 0;
    exception
      when others then
        wpreco := 0;
    end;
  end if;
  
  return nvl(wpreco,0);

end f_ret_precounit;
/
