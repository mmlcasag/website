CREATE OR REPLACE TRIGGER TRG_WEB_USUARIOS_END
BEFORE INSERT OR UPDATE OF ENDERECO,BAIRRO,CIDADE,UF ON website.WEB_USUARIOS_END
FOR EACH ROW 
begin
  :new.endereco := upper(:new.endereco);
  :new.bairro := upper(:new.bairro);
  :new.cidade := upper(:new.cidade);
  :new.uf := upper(:new.uf);
exception
  when others then
    send_mail('site-erros@colombo.com.br', 'site-erros@colombo.com.br', '[LojaVirtual] ERRO na TRIGGER',
              'TRG_WEB_USUARIOS_END - ' || sqlerrm || 'Usuario: ' || :new.codclilv);
end TRG_WEB_PROD_END;
/
