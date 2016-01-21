create or replace function f_decripta ( dado in varchar2 )
return varchar2 is
  
  wdado    varchar2(500);
  wtamanho    number;
  i           number;
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
      if substr(wdado,i,1) <> '2' then  /*carcater vindo erradamente criptografado*/
        wchar := CHR(((ASCII(substr(wdado,i,1))*11)/22)-33);
        wretorno := wretorno||wchar;
      end if;  
    end loop;
    
    return wretorno;
  end if;
  
end f_decripta;
/
