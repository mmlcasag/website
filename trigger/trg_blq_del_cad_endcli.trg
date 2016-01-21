create or replace trigger website.trg_blq_del_cad_endcli
before delete on website.cad_endcli  
for each row

begin
  
  if deleting then
    raise_application_error(-20000, 'OPERAÇÃO NÃO PERMITIDA: EXCLUSÃO DE ENDEREÇO DE CLIENTE');
  end if;
  
end trg_blq_del_cad_endcli;
/
