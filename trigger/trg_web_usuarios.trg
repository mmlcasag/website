create or replace TRIGGER TRG_WEB_USUARIOS
BEFORE INSERT OR UPDATE OF EMPRESA,NOMEPAI,NOMEMAE,NOMECONJ,NOME,EMAIL ON website.WEB_USUARIOS
FOR EACH ROW
begin
  :new.nome := initcap(:new.nome);
  :new.nomepai := initcap(:new.nomepai);
  :new.nomemae := initcap(:new.nomemae);
  :new.nomeconj := initcap(:new.nomeconj);
  :new.empresa := initcap(:new.empresa);
  :new.email := website.fnc_corr_email(:new.email);
  
  begin
    if :new.email <> :old.email then
      delete from website.web_usuarios_email where email = :old.email and dtnasc = :old.dtnasc;
    end if;
  exception
    when others then
      null;
  end;
  
exception
  when others then
    send_mail('site-erros@colombo.com.br', 'site-erros@colombo.com.br', '[LojaVirtual] ERRO na TRIGGER',
              'TRG_WEB_USUARIOS - ' || sqlerrm || 'Usuario: ' || :new.codclilv);
end TRG_WEB_PROD;
/
