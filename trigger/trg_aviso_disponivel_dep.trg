CREATE OR REPLACE TRIGGER TRG_AVISO_DISPONIVEL_DEP
BEFORE INSERT OR UPDATE OF CEP ON website.WEB_AVISO_DISPONIVEL 
FOR EACH ROW
-- Trigger que Pega o Cep do Cliente e Atualiza o campo deposito na tabela, conforme o Cep que esta cadastrado.
begin
  :new.deposito := f_deposito(:new.cep);
end;
/
