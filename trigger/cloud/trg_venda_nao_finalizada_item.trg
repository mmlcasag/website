create or replace trigger website.trg_venda_nao_finalizada_item
before insert or update or delete on website.web_venda_nao_finalizada_item
for each row

begin
  
  if inserting then
    :new.source := 'TIVIT';
  elsif updating then
    :new.source := 'TIVIT';
  elsif deleting then
    :new.source := 'TIVIT';
  end if;
  
end trg_venda_nao_finalizada_item;
/
