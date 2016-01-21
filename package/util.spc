create or replace package util is

  type ref_cursor is ref cursor;
  type tarray is varray(1000) of varchar2(10000);
  type varray is varray(1000) of number;
  type ident_arr is table of varchar2(1050) index by binary_integer;
  type ident_long is table of varchar2(10050) index by binary_integer;
  type ident_extend is table of varchar2(32767) index by binary_integer;
  empty owa_util.ident_arr;
  vazio util.ident_arr;
  null_exception exception;

  /*********************************************************************************************************************/

  /*Seleciona uma substring baseado no numero de vezes em que o delimitador aparece, por exemplo:
  Cut('mm;nn;oo',';',0) vai retornar mm, Cut('mm;nn;oo',';',1) vai retornar nn, Cut('mm;nn;oo',';',3) vai retornar nulo*/
  function cut(p_string varchar2, p_delimit varchar2, p_posicao number default 0) return varchar2;

  /*Formata o numero no formato de moeda (utilizar apenas em relatorios)*/
  function to_curr(p_valor number, do_nvl boolean default true) return varchar2;
  function to_number(p_valor number, do_nvl boolean default true) return varchar2;

  /*Retorna o tempo entre duas datas*/
  function datediff(data1 date, data2 date) return varchar2;

  /* teste condicional em uma linha */
  function test(condicion boolean, iftrue varchar2, iffalse varchar2 default null) return varchar2;
  function test(condicion boolean, iftrue number, iffalse number default null) return number;
  function test(v_value varchar2, v_values util.tarray) return varchar2;
  
  /* teste de preenchimento de campo */
  function testFill(tipo varchar2, vlr varchar2, permiteNull boolean default false) return boolean;
  
  /* localiza o índice de um determinado valor na lista. Retorna null se não encontrado */
  function listIndex(v_vlr varchar2, v_lista owa_util.ident_arr) return number;
  
  /* localiza um valor em uma lista de valores, retornando true se encontrado */
  function listFind(v_vlr varchar2, v_lista owa_util.ident_arr) return boolean;

  /* concatena itens não vazios da lista em uma string separada por p_sep. Se solicitado, considera aspas simples */
  function listConcat(p_lista owa_util.ident_arr, p_sep varchar2 default ',', p_use_aspas boolean default false) return varchar2;

  /*Converte Enter para Nova Linha*/
  function nl2br(p_string varchar2) return varchar2;

  /*Retorna o dia da semana por extenso*/
  function dayofweek(p_day char, p_extenso boolean default false) return varchar2;
  function dayofweek(p_date date, p_extenso boolean default false) return varchar2;

  /*Verifica se o usuario tem acesso a transacao*/
  function val_acesso_user(p_tran_codigo in number) return boolean;

  /*Retorna o usuario atual*/
  function get_user return varchar2;
  
  /* retorna usuário + complemento */
  function get_user_ext return varchar2;

  /*Retorna um tarray que e a uniao dos dois parametros*/
  function add(old tarray, new tarray) return util.tarray;
  
  function get_prod_desc(p_cod_prod number default null, p_cod_itprod number default null) return varchar2;

  function num(txt varchar2) return number;

end util;
/
