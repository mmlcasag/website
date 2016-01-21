CREATE OR REPLACE FUNCTION "F_RET_DESCRICAO" (p_coditprod IN number )
RETURN varchar2 IS
  wdescricao        varchar2(80);
begin
  begin
    select p.descricao
      into wdescricao     
      from cad_itprod i, cad_prod p
     where i.coditprod = p_coditprod 
       and i.codprod   = p.codprod;
  exception
    when no_data_found then
         wdescricao := null;
  end;
  --
  wdescricao:= trim(replace(wdescricao, '"', ''));
  --
  if wdescricao is not null then
    return (wdescricao);
  else
    return ('Item não cadastrado');   
  end if;
  --
END f_ret_descricao;
/
