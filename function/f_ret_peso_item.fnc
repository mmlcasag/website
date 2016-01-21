CREATE OR REPLACE FUNCTION "F_RET_PESO_ITEM" ( p_coditprod in number ) RETURN number IS
  wpeso number;
begin
  begin
    select p.pesounit
      into wpeso
      from cad_itprod i, cad_prod p
     where i.coditprod = p_coditprod
       and i.codprod   = p.codprod;
  exception
    when no_data_found then
         wpeso := 0;
  end;
  --
  return wpeso;
  --
END f_ret_peso_item;
/
