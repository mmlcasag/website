create or replace function f_encripta ( dado in varchar2 ) return varchar2 is
  
  wtamanho    number;
  i           number;
  wdado       varchar2(500);
  wretorno    varchar2(500);
  wchar       varchar2(1);
  
begin
  
  if dado is null then 
    return null;
  else
    wdado    := dado;
    wtamanho := length(dado);
    wretorno := '';
    
    for i in 1..wtamanho loop
      wchar := CHR(((ASCII(substr(wdado,i,1))+33)*22)/11);
      wretorno := wretorno||wchar;
    end loop;
    
    return wretorno;
  end if;
  
end f_encripta;
/
