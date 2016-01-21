create or replace procedure calcdigcli
( pnumber in number
, pdig   out number
) as
  
  wprod     varchar2(10);
  j         number;
  dig       number;
  mult      number;
  li_prod   number;
  li_digito number;
  
begin
  
  wprod   := to_char(pnumber, '099999999');
  li_prod := 0;
  j       := 10;
  mult    := 2;
  
  for i in 1..9
  loop
    li_prod := li_prod + to_number(substr(wprod, j, 1)) * mult;
    j := j - 1;
    mult := mult + 1;
  end loop;
  
  li_digito := mod(li_prod, 11);
  
  if li_digito = 0 then
    dig := 0;
  elsif li_digito = 1 then
    dig := 1;
  else
    dig := 11 - li_digito;
  end if;
  
  pdig := dig;
  
end calcdigcli;
/
