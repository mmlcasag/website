create or replace 
FUNCTION           "FNC_CORR_EMAIL" (user_email in varchar2) return varchar2 as
  cursor cur is
    select a.errado, a.certo 
      from web_email_regras a 
     order by ordem;
     
  prefixo varchar2(500);
  sufixo  varchar2(500);
begin
  prefixo := REGEXP_SUBSTR (user_email, '^[^@]*');
  sufixo := replaceCharsEmail(substr(user_email,instr(user_email,'@'),length(user_email)));
  if sufixo is null then 
    return null;
  end if;
  
  for l1 in cur loop
    if sufixo like '%'||l1.errado||'%' then
      sufixo := replace(sufixo, l1.errado,l1.certo);
    end if;
  end loop;
  
  return prefixo || sufixo;
 
end;