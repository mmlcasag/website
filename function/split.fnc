create or replace function split 
( p_array       in varchar2
, p_delimitador in varchar2 default '#'
) return owa_util.ident_arr as
  
  wcaracter              varchar2(4000) := '';
  j                      number := 1;
  arr_caracter           owa_util.ident_arr;
  
begin
  
  for i in 1..length(p_array) loop
    if substr(p_array,i,1) != p_delimitador then
      wcaracter := wcaracter || substr(p_array,i,1);
    else
      arr_caracter (j) := substr(wcaracter,1,60);
      wcaracter := '';
      j := j + 1;
    end if;
  end loop;
  
  return arr_caracter;
  
end split;
/
