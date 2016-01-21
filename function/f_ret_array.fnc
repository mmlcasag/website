create or replace function f_ret_array ( p_array in varchar2 ) return owa_util.ident_arr as
  
  wcaracter              varchar2(4000):='';
  i                      number;
  j                      number := 1;
  arr_caracter           owa_util.ident_arr;
  
begin
  
  for i in 1..length(p_array) loop
    if substr(p_array,i,1) != '#' then
      wcaracter := wcaracter || substr(p_array,i,1);
    else
      arr_caracter (j) := wcaracter;
      wcaracter    := '';
      j := j + 1;
    end if;
  end loop;
  
  return arr_caracter;
  
end f_ret_array;
/
