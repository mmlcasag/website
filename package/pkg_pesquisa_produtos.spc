CREATE OR REPLACE PACKAGE PKG_PESQUISA_PRODUTOS AS

   varchar2_type CONSTANT PLS_INTEGER := 1;
   number_type   CONSTANT PLS_INTEGER := 2;
   date_type     CONSTANT PLS_INTEGER := 12;
   rowid_type    CONSTANT PLS_INTEGER := 11;
   char_type     CONSTANT PLS_INTEGER := 96;

   long_type     CONSTANT PLS_INTEGER := 8;
   raw_type      CONSTANT PLS_INTEGER := 23;
   mlslabel_type CONSTANT PLS_INTEGER := 106;
   clob_type     CONSTANT PLS_INTEGER := 112;
   blob_type     CONSTANT PLS_INTEGER := 113;
   bfile_type    CONSTANT PLS_INTEGER := 114;

  /* TODO informe as declarações de package (tipos, exceções, métodos etc) aqui */
  FUNCTION pesquisa_pagina( p_linhas varchar default null, p_familias varchar default null,
                                                p_grupos varchar default null, p_empresas varchar default null,
                                                p_pagina integer default null, p_results integer default null,
                                                p_ordem integer, p_theme varchar, p_loja_fisica varchar default 'N')
  RETURN tp_web_retorno_pesquisa_tb PIPELINED;

  FUNCTION pesquisa_produtos_banco( p_busca varchar, p_linha integer default null,
                                    p_familia integer default null, p_grupo integer default null,
                                    p_pagina integer default null, p_results integer default null,
                                    p_ordem integer, p_theme varchar, p_loja_fisica varchar default 'N',
                                    p_busca_caracts varchar default 'N', p_busca_completa varchar2 default 'S',
                                    p_busca_exata varchar2 default 'N',
                                    p_inicio integer default null, p_fim integer default null)
  RETURN tp_web_retorno_pesquisa_tb PIPELINED;

  FUNCTION pesquisa_livros( p_autor  varchar2 default null,
                            p_titulo varchar2 default null, p_editora varchar2 default null,
                            p_isbn   varchar2 default null, p_assunto varchar2 default null,
                            p_pagina integer default null, p_results integer default null,
                            p_ordem  integer, p_theme varchar, p_loja_fisica varchar default 'N')
  RETURN tp_web_retorno_pesquisa_tb PIPELINED;

  FUNCTION lista_selos( p_tipo integer, p_linha integer default null,
                        p_pagina integer default null, p_results integer default null,
                        p_ordem  integer, p_theme varchar, p_loja_fisica varchar default 'N')
  RETURN tp_web_retorno_pesquisa_tb PIPELINED;

  FUNCTION lista_virtual_gsa RETURN tp_web_virtual_gsa_tb PIPELINED;
  
  FUNCTION get_avaliacoes_produto_virtual (p_tipo_produto varchar2,
                                           p_codigo number)
  RETURN NUMBER;
  
  procedure defineColunas(p_cursor number, rec_tab dbms_sql.desc_tab);

END PKG_PESQUISA_PRODUTOS;
/
