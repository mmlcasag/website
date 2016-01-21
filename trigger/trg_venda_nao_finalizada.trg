create or replace trigger website.trg_venda_nao_finalizada
before insert or update or delete on website.web_venda_nao_finalizada
for each row

begin
  
  if inserting then
    :new.source := 'COLOMBO';
  elsif updating then
    :new.source := 'COLOMBO';
  elsif deleting then
    :new.source := 'COLOMBO';
  end if;
  
end trg_venda_nao_finalizada;
/
