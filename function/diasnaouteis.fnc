create or replace function diasnaouteis
( dataini date
, datafim date
) return number is
  
  qtddias number;
  dayweek number;
  
begin
  
  qtddias := trunc(datafim - dataini);
  dayweek := to_char(dataini,'D');
  qtddias := trunc((qtddias +dayweek) /7) *2;
  
  if dayweek = 1 then
    qtddias := qtddias +1;
  end if;
  
  dayweek := to_char(datafim,'D');
  
  if dayweek = 7 then
    qtddias := qtddias -1;
  end if;
  
  select qtddias + count(*)
  into   qtddias
  from   cad_calendario
  where  codfil = 400
  and    dtcalendario between dataini and datafim
  and    flcom  = 'S'
  and    to_char(dtcalendario,'D') not in (1,7);
  
  return qtddias;
  
end diasnaouteis;
/
