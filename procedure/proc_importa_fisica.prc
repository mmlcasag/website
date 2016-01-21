CREATE OR REPLACE PROCEDURE proc_importa_fisica ( Cliente number ) is
BEGIN
  send_mail('site-erros@colombo.com.br','site-erros@colombo.com.br','Projeto Site na Nuvem','PROC_IMPORTA_FISICA foi chamada, porém está desativada');
END proc_importa_fisica;
/
