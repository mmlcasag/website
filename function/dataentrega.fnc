create or replace function dataEntrega
( dataini   date
, diasuteis number
) return date is
  
  dataaux date;
  dataret date;
  qtddias number := 0;
  
begin
  
  dataaux := dataini;
  qtddias := diasuteis;
  
  loop
    dataret := dataaux + qtddias;
    qtddias := diasNaoUteis(dataaux+1,dataret);
    exit when qtddias <= 0;
    dataaux := dataret;
  end loop;
  
  return dataret;
end;
/
