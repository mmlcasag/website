create or replace function get_codproddf ( p_coditprod in number ) return number as
  
  v_codproddf cad_itprod.codproddf%type;
  
begin
  
  begin
    select codproddf 
      into v_codproddf 
      from cad_itprod 
     where coditprod = p_coditprod;
  exception
    when others then 
      v_codproddf := null;
  end;
  
  return v_codproddf;

end get_codproddf;
/
