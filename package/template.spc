CREATE OR REPLACE PACKAGE TEMPLATE is
/*
  c_tableheader varchar2(7) := '#AACDFA';
  c_tablesubtit varchar2(7) := '#BBDEFF';
  c_tableline01 varchar2(7) := '#FFFFFF';
  c_tableline02 varchar2(7) := '#DEEEFF';
  c_tablelnover varchar2(7) := '#FFFFAA';
  c_tablelnclik varchar2(7) := '#BCDCFF';
  c_tablefiltro varchar2(7) := '#EFF7FF';
  c_tableborder varchar2(7) := '#AAAAAA';

  c_fontallok varchar2(7) := '#000000';
  c_fontcolor varchar2(7) := '#0000BB';
  c_fonterror varchar2(7) := '#ff0000';
  c_fontdisab varchar2(7) := '#DDDDDD';

  c_bgcolor varchar2(7) := '#EFF7FF';
  c_inputborder varchar2(7) := '#CCCCCC';
*/
  g_linhaimpar number not null := 1;
  g_numcols    number not null := 0;

  /*Retorna a cor atual da TD*/
  function c_tablerowcolor return varchar2;

  /*Style padrão da Colombo*/
  procedure style;
  /*Tag de style*/
  procedure styles;
  /*Abre e fecha a tag de JavaScript*/
  procedure script(p_script varchar2);
  /*Redirecionar a página*/
  procedure redirect(p_page varchar2);
  /*Abre uma tag de JavaScript*/
  procedure scriptopen;
  /*Fecha a tag de script*/
  procedure scriptclose;
  /*Script para trocar as cores das linhas da tabela no Over e Click das linhas*/
  procedure scriptrowcolors;
  /*Scripts para validação dos campos do formulário*/
  procedure scripttests;

  /*Cria o cabeçalho padrao das paginas*/
  procedure heading(p_title varchar2);
  /*Inicia a página, ja seta o titulo, verifica se o usuario esta logado, cria o cabecalho e abre o body*/
  procedure pageopen(p_title varchar2 default null,p_transacao number default null);
  /*Fecha o body e o html da pagina*/
  procedure pageend;
  procedure pageclose(p_links util.tarray default null);

  /*Coloca uma mensagem com as tags de centro*/
  procedure centermsg(p_message varchar2);
  /*Coloca uma mensagem de centro na cor de erro*/
  procedure errormsg(p_message varchar2);

  /*Abre a tabela já com os padrões*/
  procedure tablestart(p_others varchar2 default null);
  /*Abre a tabela e tag de script de cores*/
  procedure tableopen(p_attributes varchar2 default null);
  /*Abre a tabela nos padrões e monta o cabecalho baseado no array*/
  /*Se p_tableID for informado, a tabela terá ordenação nos campos*/
  procedure tableopen(p_array util.tarray,
                      p_attributes varchar2 default null,
                      p_tableID varchar2 default null,
                      p_nullParam varchar2 default null--não usado, declarado apenas para não invalidar packages antigas
                      );
  /*Fecha a tabela com a linha da cor do titulo como eh o padrao*/
  procedure tableclose(p_numcols number default null);
  /*Abre a linha com a cor do titulo*/
  procedure tabletitleopen(p_others varchar2 default null);
  /*Linha com a cor do titulo*/
  procedure tabletitle(p_numcols number default null,p_others varchar2 default null);
  /*Linha com a cor do titulo*/
  procedure tabletitle(p_array util.tarray,p_others varchar2 default null);
  /*Abre a tag de total com a cor*/
  procedure tablesubopen;
  /*Linha com a cor do total*/
  procedure tablesub(p_numcols number default null,p_others varchar2 default null);
  /*Linha com a cor do total*/
  procedure tablesub(p_array util.tarray,p_others varchar2 default null);
  /*Tag de Header*/
  procedure tableheader(cvalue in varchar2 default null,calign in varchar2 default null,cdp in varchar2 default null,
                        cnowrap in varchar2 default null,crowspan in varchar2 default null,ccolspan in varchar2 default null,
                        cattributes in varchar2 default null);
  /*Tag de Header com cor*/
  procedure tableheader2(cvalue in varchar2 default null,calign in varchar2 default null,cdp in varchar2 default null,
                         cnowrap in varchar2 default null,crowspan in varchar2 default null,ccolspan in varchar2 default null,
                         cattributes in varchar2 default null);
  /*Abre a tag de linha com script onclick*/
  procedure rowopen(p_others varchar2 default null);
  /*Abre e fecha a tag de linha e coloca os valores do array nas colunas, parametro "||??" para alinhamento*/
  procedure rowopen(p_array util.tarray,p_others varchar2 default null);
  /*Abre a tag de linha com script onclick*/
  procedure row(p_others varchar2 default null);
  /*Abre e fecha a tag de linha e coloca os valores do array nas colunas, parametro "||??" para alinhamento*/
  procedure row(p_array util.tarray,p_others varchar2 default null);

  /*Abre a tag de linha sem script onclick*/
  procedure rowopen2(p_others varchar2 default null);
  /*Abre e fecha a tag de linha e coloca os valores do array nas colunas, parametro "||??" para alinhamento*/
  procedure rowopen2(p_array util.tarray,p_others varchar2 default null);
  /*Abre a tag de linha sem script onclick*/
  procedure row2(p_others varchar2 default null);
  /*Abre e fecha a tag de linha e coloca os valores do array nas colunas, parametro "||??" para alinhamento*/
  procedure row2(p_array util.tarray,p_others varchar2 default null);

  /*Fecha a linha*/
  procedure rowclose;

  /*Abre a tabela de filtro e o form*/
  procedure filtrostart(p_message varchar2,p_action varchar2,p_other varchar2 default null);
  /*Cabeçalho padrao do filtro*/
  procedure filtrotitle(p_title varchar2,p_numrows number default 2);
  /*Abre a tabela de filtro, o form e o cabeçalho padrao*/
  procedure filtroopen(p_title varchar2,p_message varchar2,p_action varchar2,p_other varchar2 default null);
  /*Fecha a tabela de filtro e o form*/
  procedure filtroclose;
  /*Abre a tag de linha no formato do filtro*/
  procedure filtrorow;
  /*Abre e fecha a tag de linha e coloca os valores do array nas colunas, parametro "||??" para alinhamento*/
  procedure filtrorow(p_array util.tarray,p_others varchar2 default null);
  /*Adiciona uma coluna de titulo no filtro*/
  procedure filtroheader(p_field varchar2);
  /*Adiciona uma coluna de campo no filtro*/
  procedure filtrodata(p_field varchar2);
  /*Abre a tag de linha do filtro e seta as colunas*/
  procedure filtrorow(p_field1 varchar2,p_field2 varchar2);
  /*Coloca os botoes ao final do form*/
  procedure filtrobotoes(p_array util.tarray);
  /*Retorna um botao de acordo com o tipo*/
  function botao(p_tipo number, p_others varchar2 default null) return varchar2;

  /*Insere um botao*/
  function formbutton(p_value varchar2,p_name varchar2 default null,p_others varchar2 default null) return varchar2;
  /*Insere um input text para entrada de datas*/
  function formdate(p_name varchar2,p_value varchar2 default null,p_tipo char default 'A',p_calendario boolean default true, p_attr varchar2 default null) return varchar2;
  /*Insere um input text para entrada de horas*/
  function formtime(p_name varchar2,p_value varchar2 default null,p_atrib varchar2 default null) return varchar2;
  /*Insere um input text para entrada de numeros*/
  function formnumber(p_name varchar2,p_size number,p_float boolean default null,p_value varchar2 default null,
                      p_atrib varchar2 default null) return varchar2;
  /*Insere um input text para entrada de cores (precisa ter o HTMLArea carregado para executar)*/
  function formcolor(p_name varchar2, p_size number, p_value varchar2, p_edit boolean default false) return varchar2;
  /*Retorna um select com name e os itens passados*/
  function formcombo(p_name varchar2,p_array util.tarray,p_value varchar2 default null,p_others varchar2 default null, p_script boolean default null) return varchar2;
  procedure formcombo(p_name varchar2,p_array util.tarray,p_value varchar2 default null,p_others varchar2 default null,p_script boolean default false);
  /*Retorna um editor de html*/
  procedure formhtmleditstart;
  function formhtmledit(p_name varchar2,p_rows number,p_cols number,p_value varchar2 default null) return varchar2;
  /*Retorna um texteditor*/
  function formtextarea(p_name varchar2,p_rows number,p_cols number,p_value varchar2 default null) return varchar2;

  /*Para alteracao*/
  function alteracao(p_action varchar2) return varchar2;

  /*Para exclusao*/
  procedure exclusaoopen(p_action varchar2,p_others varchar2 default null);
  function exclusao(p_value varchar2 default null,p_grupo varchar2 default null) return varchar2;
  function exclusaobotao return varchar2;

  /*Formata a mensagem de erro*/
  procedure erro(p_message varchar2 default null);
  /*Script para setar styles dos inputs*/
  procedure scriptinputstyle;

/*Busca parametros da tabela*/
function get_parametro (p_nome in varchar2) return varchar2;

/* Retorna parametros*/
function c_tableheader return varchar2;
function c_tablesubtit return varchar2;
function c_tableline01  return varchar2;
function c_tableline02 return varchar2;
function c_tablelnover return varchar2;
function c_tablelnclik return varchar2;
function c_tablefiltro return varchar2;
function c_tableborder return varchar2;
function c_fontallok return varchar2;
function c_fontcolor return varchar2;
function c_fonterror return varchar2;
function c_fontdisab return varchar2;
function c_bgcolor return varchar2;
function c_inputborder return varchar2;

/***************************************************************************************************************/

end template;
/
