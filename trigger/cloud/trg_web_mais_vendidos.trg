create or replace trigger website.trg_web_mais_vendidos
before insert or update or delete on website.web_mais_vendidos
for each row

begin
  
  if inserting then
    :new.source := 'TIVIT';
  elsif updating then
    :new.source := 'TIVIT';
  elsif deleting then
    :new.source := 'TIVIT';
  end if;
  
end trg_web_mais_vendidos;
/
