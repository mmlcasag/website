create or replace trigger website.trg_web_mais_vendidos
before insert or update or delete on website.web_mais_vendidos
for each row

begin
  
  if inserting then
    :new.source := 'COLOMBO';
  elsif updating then
    :new.source := 'COLOMBO';
  elsif deleting then
    :new.source := 'COLOMBO';
  end if;
  
end trg_web_mais_vendidos;
/
