CREATE OR REPLACE PROCEDURE proc_libera_pedido_komerci
( p_numpedido  IN VARCHAR2
, p_num_cartao IN VARCHAR2
, p_origem_bin IN VARCHAR2
, p_numautor   IN VARCHAR2
, p_numcv      IN VARCHAR2
, p_numautent  IN VARCHAR2
, p_numsqn     IN VARCHAR2
) IS
BEGIN
  send_mail('site-erros@colombo.com.br','site-erros@colombo.com.br','Projeto Site na Nuvem','PROC_LIBERA_PEDIDO_KOMERCI foi chamada, porém está desativada');
END proc_libera_pedido_komerci;
/
