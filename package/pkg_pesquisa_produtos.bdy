CREATE OR REPLACE PACKAGE BODY PKG_PESQUISA_PRODUTOS AS

  procedure defineColunas(p_cursor number, rec_tab dbms_sql.desc_tab) as
    col_num integer;
    v_ret_varchar   varchar2(2000);
    v_ret_number    number;
    v_ret_date      date;
    v_ret_char      char(255);
    v_ret_long      long;
    v_ret_clob      clob;
    v_ret_blob      blob;
  begin
      col_num := rec_tab.first;
      IF (col_num IS NOT NULL) THEN
        LOOP
          if( rec_tab(col_num).col_type = varchar2_type ) then
            dbms_sql.define_column(p_cursor, col_num, v_ret_varchar, 2000);
          elsif( rec_tab(col_num).col_type = number_type ) then
            dbms_sql.define_column(p_cursor, col_num, v_ret_number);
          elsif( rec_tab(col_num).col_type = date_type ) then
            dbms_sql.define_column(p_cursor, col_num, v_ret_date);
          elsif( rec_tab(col_num).col_type = char_type ) then
            dbms_sql.define_column(p_cursor, col_num, v_ret_char, 255);
          elsif( rec_tab(col_num).col_type = long_type ) then
            dbms_sql.define_column(p_cursor, col_num, v_ret_long);
          elsif( rec_tab(col_num).col_type = clob_type ) then
            dbms_sql.define_column(p_cursor, col_num, v_ret_clob);
          elsif( rec_tab(col_num).col_type = blob_type ) then
            dbms_sql.define_column(p_cursor, col_num, v_ret_blob);
          end if;
          col_num := rec_tab.next(col_num);
          EXIT WHEN (col_num is null);
        END LOOP;
      END IF;
  end defineColunas;

  function geraParametrosIn(p_variavel in varchar, p_prefixo in varchar) return varchar as
    v_retorno varchar2(1000);
    v_count   integer;
    v_aux     varchar2(1000);
  begin
    v_retorno := '';
    v_count := 0;
    v_aux   := util.cut(p_variavel,',',v_count);
    while (v_aux is not null) loop
      if(v_count > 0) then
        v_retorno := v_retorno||',';
      end if;
      v_retorno := v_retorno||':'||p_prefixo||(v_count+1);

      v_count := v_count+1;
      v_aux   := util.cut(p_variavel,',',v_count);
    end loop;
    return(v_retorno);
  end geraParametrosIn;

  procedure bindParametrosIn(p_cursor number, p_variavel in varchar, p_prefixo in varchar) as
    v_count   integer;
    v_aux     varchar2(1000);
  begin
    v_count := 0;
    v_aux   := util.cut(p_variavel,',',v_count);
    while (v_aux is not null) loop
      dbms_sql.bind_variable(p_cursor, ':'||p_prefixo||(v_count+1), v_aux);

      v_count := v_count+1;
      v_aux   := util.cut(p_variavel,',',v_count);
    end loop;
  end bindParametrosIn;

  FUNCTION pesquisa_pagina( p_linhas varchar default null, p_familias varchar default null,
                            p_grupos varchar default null, p_empresas varchar default null,
                            p_pagina integer default null, p_results integer default null,
                            p_ordem integer, p_theme varchar, p_loja_fisica varchar default 'N')
  RETURN tp_web_retorno_pesquisa_tb PIPELINED AS

    v_tipo char(1);
    v_codigo integer;
    v_descricao_produto varchar2(500);
    v_descricao_empresa varchar2(120);

    v_pagina integer := p_pagina;
    v_imprimir boolean;

    cProdutos number;
    col_num   integer;
    row_num   integer := 0;
    p_ignore  integer;
    rec_tab   dbms_sql.desc_tab;

    out_rec tp_web_retorno_pesquisa;
    v_sql VARCHAR2(32000);
    v_where_produto VARCHAR2(32000);
    v_where_agregado VARCHAR2(32000);
    v_where_brinde VARCHAR2(32000);
  BEGIN
    /* Mandelli - 04/2012
       colocado controle para que se a PKG não receber parametros especificos
       nao retorne nada na busca
       caso nao exista este parametro, pkg ira retornar TODOS os produtos ativos no site, comprometendo o link e a aplicacao*/
       
    if (p_linhas is null and p_familias is null and p_grupos is null and p_empresas is null) then
      RETURN;
    END if;
    
    v_sql := '
      select tab.*
        from ( ';

    -- where da query de produto
    v_where_produto := ' where p.fl_disponivel_venda = ''S''';
    if(p_loja_fisica = 'S') then
      v_where_produto := v_where_produto||' and p.flcatalogo = ''S'' ';
    else
      v_where_produto := v_where_produto||' and p.flativo = ''S'' ';
    end if;
    if(p_theme not in ('site','mobile')) then
      v_where_produto := v_where_produto||' and p.fl'||p_theme||' = ''S'' ';
    end if;
    if(p_grupos is not null) then
      v_where_produto := v_where_produto||' and g.codgrupo in ('||geraParametrosIn(p_grupos,'g')||') ';
    end if;
    if((p_familias is not null) and (p_grupos is null)) then
      v_where_produto := v_where_produto||' and f.codfam in ('||geraParametrosIn(p_familias,'f')||') ';
    end if;
    if((p_linhas is not null) and (p_familias is null)) then
      v_where_produto := v_where_produto||' and l.codlinha in ('||geraParametrosIn(p_linhas,'l')||') ';
    end if;
    if(p_empresas is not null) then
      v_where_produto := v_where_produto||' and p.codempresa in ('||geraParametrosIn(p_empresas,'e')||') ';
    end if;

    v_sql := v_sql||'
            select ''P'' as tipo, p.codprod as codigo, p.descricao as descricao_produto, e.descricao as descricao_empresa,
                   o.nro_vendas as qnt_vendida, o.preco as precopromocoes, o.flestoque disp
            from web_prod p
            inner join web_grupo g on g.codgrupo = p.codgrupo
            inner join web_familia f on f.codfam = g.codfam
            inner join web_linha l on l.codlinha = f.codlinha
            inner join web_empresa e on e.codempresa = p.codempresa
            left outer join web_prod_ordenacao o on o.codprod = p.codprod';
    v_sql := v_sql || v_where_produto;

    v_sql := v_sql||'
            union
            select ''P'' as tipo, p.codprod as codigo, p.descricao as descricao_produto, e.descricao as descricao_empresa,
                    o.nro_vendas as qnt_vendida, o.preco as precopromocoes, o.flestoque disp
            from web_prod p
            inner join web_grupo_secundario gs on gs.codprod = p.codprod
            inner join web_grupo g on g.codgrupo = gs.codgrupo
            inner join web_familia f on f.codfam = g.codfam
            inner join web_linha l on l.codlinha = f.codlinha
            inner join web_empresa e on e.codempresa = p.codempresa
            left outer join web_prod_ordenacao o on o.codprod = p.codprod';
    v_sql := v_sql || v_where_produto;

    if(p_theme not in ('mobile')) then

      if (nvl(fnc_retorna_parametro('GSA','LISTA AGREGADOS'),'N') = 'S') then
          -- where da query de produto agregado
          v_where_agregado := ' where p.fl_disponivel_venda = ''S''
                      and a.pva_fl_ativo = ''S''
                      and a.pva_descricao_url is not null and a.pva_descricao_title is not null ';
          if(p_loja_fisica = 'S') then
            v_where_agregado := v_where_agregado||' and p.flcatalogo = ''S'' ';
          else
            v_where_agregado := v_where_agregado||' and p.flativo = ''S'' ';
          end if;
          if(p_theme not in ('site','mobile')) then
            v_where_agregado := v_where_agregado||' and p.fl'||p_theme||' = ''S'' ';
          end if;
          v_where_agregado := v_where_agregado||' and ( ( 1 = 1 ';
          if(p_grupos is not null) then
            v_where_agregado := v_where_agregado||' and g.codgrupo in ('||geraParametrosIn(p_grupos,'g')||') ';
          end if;
          if((p_familias is not null) and (p_grupos is null)) then
            v_where_agregado := v_where_agregado||' and f.codfam in ('||geraParametrosIn(p_familias,'f')||') ';
          end if;
          if(p_linhas is not null and p_familias is null) then
            v_where_agregado := v_where_agregado||' and l.codlinha in ('||geraParametrosIn(p_linhas,'l')||') ';
          end if;
          if(p_empresas is not null) then
            v_where_agregado := v_where_agregado||' and p.codempresa in ('||geraParametrosIn(p_empresas,'e')||') ';
          end if;
          v_where_agregado := v_where_agregado||' ) or ( a.fl_inversao = ''S'' ';
          if(p_grupos is not null) then
            v_where_agregado := v_where_agregado||' and g2.codgrupo in ('||geraParametrosIn(p_grupos,'g')||') ';
          end if;
          if((p_familias is not null) and (p_grupos is null)) then
            v_where_agregado := v_where_agregado||' and f2.codfam in ('||geraParametrosIn(p_familias,'f')||') ';
          end if;
          if((p_linhas is not null) and (p_familias is null)) then
            v_where_agregado := v_where_agregado||' and l2.codlinha in ('||geraParametrosIn(p_linhas,'l')||') ';
          end if;
          if(p_empresas is not null) then
            v_where_agregado := v_where_agregado||' and p2.codempresa in ('||geraParametrosIn(p_empresas,'e')||') ';
          end if;
          v_where_agregado := v_where_agregado||' ) ) ';            
    
          v_sql := v_sql||'
                  union
                  select distinct ''A'', a.pva_id, a.pva_descricao_title, e.descricao,
                        o.nro_vendas as qnt_vendida, o.preco as precopromocoes, o.flestoque disp
                  from web_prod_venda_agregada a
                  inner join web_itprod_venda_agregada ita on a.pva_id = ita.pva_id
                  inner join web_itprod it on a.itm_id = it.coditprod
                  inner join web_prod p on it.codprod = p.codprod
                  inner join web_grupo g on p.codgrupo = g.codgrupo
                  inner join web_familia f on g.codfam = f.codfam
                  inner join web_linha l on f.codlinha = l.codlinha
                  inner join web_empresa e on p.codempresa = e.codempresa
                  inner join web_itprod it2 on ita.itm_id_agregado = it2.coditprod
                  inner join web_prod p2 on it2.codprod = p2.codprod
                  inner join web_grupo g2 on p2.codgrupo = g2.codgrupo
                  inner join web_familia f2 on g2.codfam   = f2.codfam
                  inner join web_linha l2 on f2.codlinha = l2.codlinha
                  inner join web_empresa e2 on p2.codempresa = e2.codempresa
                  left outer join web_prod_agregada_ordenacao o on o.pva_id = a.pva_id ';
          v_sql := v_sql || v_where_agregado;
    
          v_sql := v_sql||'
                  union
                  select distinct ''A'', a.pva_id, a.pva_descricao_title, e.descricao,
                         o.nro_vendas as qnt_vendida, o.preco as precopromocoes, o.flestoque disp
                  from web_prod_venda_agregada a
                  inner join web_itprod_venda_agregada ita on a.pva_id = ita.pva_id
                  inner join web_itprod it on a.itm_id = it.coditprod
                  inner join web_prod p on it.codprod = p.codprod
                  inner join web_grupo_secundario gs on p.codprod = gs.codprod
                  inner join web_grupo g on gs.codgrupo = g.codgrupo
                  inner join web_familia f on g.codfam = f.codfam
                  inner join web_linha l on f.codlinha = l.codlinha
                  inner join web_empresa e on p.codempresa = e.codempresa
                  inner join web_itprod it2 on ita.itm_id_agregado = it2.coditprod
                  inner join web_prod p2 on it2.codprod = p2.codprod
                  inner join web_grupo_secundario gs2 on p2.codprod = gs2.codprod
                  inner join web_grupo g2 on gs2.codgrupo = g2.codgrupo
                  inner join web_familia f2 on g2.codfam   = f2.codfam
                  inner join web_linha l2 on f2.codlinha = l2.codlinha
                  inner join web_empresa e2 on p2.codempresa = e2.codempresa
                  left outer join web_prod_agregada_ordenacao o on o.pva_id = a.pva_id ';
          v_sql := v_sql || v_where_agregado;
      end if;

      -- where da query de produto brinde
      v_where_brinde := ' where 
                  sysdate between b.dtinicio and b.dtfim
                  and bp.codplano  = ''BO''
                  and b.fl_ativo = ''S''
                  and b.descricao_url is not null and b.descricao_title is not null ';
      if(p_loja_fisica = 'S') then
        v_where_brinde := v_where_brinde||' and p.flcatalogo = ''S'' ';
      else
        v_where_brinde := v_where_brinde||' and p.flativo = ''S'' ';
      end if;
      if(p_theme not in ('site','mobile')) then
        v_where_brinde := v_where_brinde||' and p.fl'||p_theme||' = ''S'' ';
      end if;
      if(p_grupos is not null) then
        v_where_brinde := v_where_brinde||' and g.codgrupo in ('||geraParametrosIn(p_grupos,'g')||') ';
      end if;
      if((p_familias is not null) and (p_grupos is null)) then
        v_where_brinde := v_where_brinde||' and f.codfam in ('||geraParametrosIn(p_familias,'f')||') ';
      end if;
      if((p_linhas is not null) and (p_familias is null)) then
        v_where_brinde := v_where_brinde||' and l.codlinha in ('||geraParametrosIn(p_linhas,'l')||') ';
      end if;
      if(p_empresas is not null) then
        v_where_brinde := v_where_brinde||' and p.codempresa in ('||geraParametrosIn(p_empresas,'e')||') ';
      end if;
    end if;

    v_sql := v_sql||'
               union
             select distinct ''B'', b.cod_brinde, b.descricao_title,  e.descricao,
                    o.nro_vendas as qnt_vendida, o.preco as precopromocoes, o.flestoque disp
               from web_itprod_brinde b
               inner join web_itprod_brindeplano bp on b.cod_brinde = bp.cod_brinde
               inner join web_itprod it on b.cod_itprod_principal = it.coditprod
               inner join web_prod p on it.codprod = p.codprod
               inner join web_grupo g on p.codgrupo = g.codgrupo
               inner join web_familia f on g.codfam   = f.codfam
               inner join web_linha l on f.codlinha = l.codlinha
               inner join web_empresa e on p.codempresa = e.codempresa
               left outer join web_itprod_brinde_ordenacao o on o.cod_brinde = b.cod_brinde ';
    v_sql := v_sql || v_where_brinde;

    v_sql := v_sql||'
               union
             select distinct ''B'', b.cod_brinde, b.descricao_title, e.descricao,
                    o.nro_vendas as qnt_vendida, o.preco as precopromocoes, o.flestoque disp
               from web_itprod_brinde b
               inner join web_itprod_brindeplano bp on b.cod_brinde = bp.cod_brinde
               inner join web_itprod it on b.cod_itprod_principal = it.coditprod
               inner join web_prod p on it.codprod = p.codprod
               inner join web_grupo_secundario gs on p.codprod = gs.codprod
               inner join web_grupo g on gs.codgrupo = g.codgrupo
               inner join web_familia f on g.codfam   = f.codfam
               inner join web_linha l on f.codlinha = l.codlinha
               inner join web_empresa e on p.codempresa = e.codempresa
               left outer join web_itprod_brinde_ordenacao o on o.cod_brinde = b.cod_brinde ';
    v_sql := v_sql || v_where_brinde;

    v_sql := v_sql||' ) tab order by disp desc, ';
    if(p_ordem = 1)then
      v_sql := v_sql||' descricao_produto ';
    elsif(p_ordem = 2)then
      v_sql := v_sql||' precopromocoes ';
    elsif(p_ordem = 3)then
      v_sql := v_sql||' precopromocoes desc ';
    elsif(p_ordem = 4)then
      v_sql := v_sql||' descricao_empresa ';
    elsif(p_ordem = 5)then
      v_sql := v_sql||' descricao_produto ';
    elsif(p_ordem = 6)then
      v_sql := v_sql||' descricao_produto desc';
    elsif(p_ordem = 7)then
      v_sql := v_sql||' qnt_vendida desc ';
    else
      v_sql := v_sql||' descricao_produto ';
    end if;
    --dbms_output.put_line(v_sql);
    cProdutos := dbms_sql.open_cursor;
    dbms_sql.parse(cProdutos, v_sql, dbms_sql.NATIVE);

    if(p_grupos is not null) then
      bindParametrosIn(cProdutos, p_grupos, 'g');
    end if;
    if((p_familias is not null) and (p_grupos is null)) then
      bindParametrosIn(cProdutos, p_familias, 'f');
    end if;
    if((p_linhas is not null) and (p_familias is null)) then
      bindParametrosIn(cProdutos, p_linhas, 'l');
    end if;

    if(p_empresas is not null) then
      bindParametrosIn(cProdutos, p_empresas, 'e');
    end if;

    dbms_sql.describe_columns(cProdutos, col_num, rec_tab);
    defineColunas(cProdutos, rec_tab);

    if(p_results is not null and p_pagina is null) then
      v_pagina := 1;
    end if;

    p_ignore := dbms_sql.execute(cProdutos);
    loop
      exit when dbms_sql.fetch_rows(cProdutos) <= 0;
      row_num := row_num+1;
      exit when (p_results is not null and row_num > v_pagina*p_results);
      dbms_sql.column_value(cProdutos, 1, v_tipo);
      dbms_sql.column_value(cProdutos, 2, v_codigo);
      dbms_sql.column_value(cProdutos, 3, v_descricao_produto);
      dbms_sql.column_value(cProdutos, 4, v_descricao_empresa);

      v_imprimir := true;
      if(p_results is not null) then
        v_imprimir := row_num between ((v_pagina-1)*p_results)+1 and (v_pagina*p_results);
      end if;
      if(v_imprimir) then
        out_rec := tp_web_retorno_pesquisa(v_tipo, v_codigo, v_descricao_produto);
        pipe row(out_rec);
      end if;

    end loop;
    dbms_output.put_line(v_sql);
    dbms_sql.close_cursor(cProdutos);
  END pesquisa_pagina;


  FUNCTION pesquisa_produtos_banco( p_busca varchar, p_linha integer default null,
                                    p_familia integer default null, p_grupo integer default null,
                                    p_pagina integer default null, p_results integer default null,
                                    p_ordem integer, p_theme varchar, p_loja_fisica varchar default 'N',
                                    p_busca_caracts varchar default 'N', p_busca_completa varchar2 default 'S',
                                    p_busca_exata varchar2 default 'N',
                                    p_inicio integer default null, p_fim integer default null)
  RETURN tp_web_retorno_pesquisa_tb PIPELINED AS

    v_contador integer;
    v_sinonimos util.tarray := util.tarray();
    v_texto     varchar2(10050);

    v_tipo char(1);
    v_codigo integer;
    v_descricao_produto varchar2(500);
    v_precovista number(12,4);
    v_descricao_empresa varchar2(120);

    v_pagina integer := p_pagina;
    v_imprimir boolean;

    cPesquisa number;
    col_num   integer;
    row_num   integer := 0;
    p_ignore  integer;
    rec_tab   dbms_sql.desc_tab;

    v_inicio  integer;
    v_fim     integer;

    out_rec tp_web_retorno_pesquisa;
    v_sql VARCHAR2(32000);

    procedure filtro_busca(v_grau varchar2 default null) as
    begin

      v_sql := v_sql||' and ( ( ';
      --descrição do produto
      for counter in v_sinonimos.first..v_sinonimos.last loop
        if(counter > 1) then
          v_sql := v_sql||' and ';
        end if;
        v_sql := v_sql||' CONVERT(UPPER(p'||v_grau||'.descricao),''SF7ASCII'') LIKE :p_sinonimo'||counter||' ';
      end loop;
      v_sql := v_sql||' ) ';
      if(p_busca_completa = 'S') then
        --caracteristicas
        if(p_busca_caracts = 'S') then
          v_sql := v_sql||' or ( ';
          for counter in v_sinonimos.first..v_sinonimos.last loop
            if(counter > 1) then
              v_sql := v_sql||' and ';
            end if;
            v_sql := v_sql||' ( CONVERT(UPPER(c'||v_grau||'.caracteristica),''SF7ASCII'') LIKE :p_sinonimo'||counter||' or CONVERT(UPPER(p'||v_grau||'.minicaract),''SF7ASCII'') LIKE :p_sinonimo'||counter||' )';
          end loop;
          v_sql := v_sql||' ) ';
        end if;
        --fornecedor
        v_sql := v_sql||' or ( ';
        for counter in v_sinonimos.first..v_sinonimos.last loop
          if(counter > 1) then
            v_sql := v_sql||' and ';
          end if;
          v_sql := v_sql||' CONVERT(UPPER(e'||v_grau||'.descricao),''SF7ASCII'') LIKE :p_sinonimo'||counter||' ';
        end loop;
        v_sql := v_sql||' ) ';
        --familia e grupo
        v_sql := v_sql||' or ( ';
        for counter in v_sinonimos.first..v_sinonimos.last loop
          if(counter > 1) then
            v_sql := v_sql||' and ';
          end if;
          v_sql := v_sql||' ( CONVERT(UPPER(g'||v_grau||'.descricao),''SF7ASCII'') LIKE :p_sinonimo'||counter||' or CONVERT(UPPER(f'||v_grau||'.descricao),''SF7ASCII'') LIKE :p_sinonimo'||counter||' )';
        end loop;
        v_sql := v_sql||' ) ';

      end if;
      v_sql := v_sql||' ) ';
    end;

  BEGIN

    if (v_pagina is not null or p_results is not null) then
      if (v_pagina is null) then
        v_pagina := 1;
      end if;
      v_inicio := v_pagina * p_results;
      v_fim := v_inicio + p_results;
    else
      v_inicio := p_inicio;
      v_fim := p_fim;
    end if;

    v_contador := 0;
    loop
      exit when v_contador = -1;
      v_texto := util.cut(p_busca,'-%-', v_contador);
      if(v_texto is not null) then
        v_sinonimos.extend();
        v_sinonimos(v_sinonimos.last) := v_texto;
        v_contador := v_contador+1;
      else
        v_contador := -1;
      end if;
    end loop;

    if(v_sinonimos.first is not null) then

      v_sql := '
        select tab.*

          from (
                select distinct ''P'' as tipo, p.codprod as codigo, p.descricao as descricao_produto, e.descricao as descricao_empresa,
                       o.nro_vendas as qnt_vendida, o.preco as precopromocoes, o.flestoque disp
                  from web_prod p, web_grupo g, web_familia f, web_linha l, web_empresa e, web_prodcaract c, web_prod_ordenacao o
                 where p.codprod  = c.codprod
                   and p.codgrupo = g.codgrupo
                   and g.codfam   = f.codfam
                   and f.codlinha = l.codlinha
                   and p.codempresa = e.codempresa
                   and p.fl_disponivel_venda = ''S''
                   and o.codprod (+) = p.codprod ';
      if(p_loja_fisica = 'S') then
        v_sql := v_sql||' and p.flcatalogo = ''S'' ';
      else
        v_sql := v_sql||' and p.flativo = ''S'' ';
      end if;
      if(p_theme not in ('site','mobile')) then
        v_sql := v_sql||' and p.fl'||p_theme||' = ''S'' ';
      end if;

      --filtro da busca
      if(p_busca_exata = 'N') then
        filtro_busca;
      else
        v_sql := v_sql||' and upper(p.descricaourl) = :p_sinonimo1 ';
      end if;

      if(p_linha is not null) then
        v_sql := v_sql||' and l.codlinha = :p_linha ';
      end if;
      if(p_familia is not null) then
        v_sql := v_sql||' and f.codfam = :p_familia ';
      end if;
      if(p_grupo is not null) then
        v_sql := v_sql||' and g.codgrupo = :p_grupo ';
      end if;

      if(p_theme not in ('mobile')) then
        if (nvl(fnc_retorna_parametro('GSA','LISTA AGREGADOS'),'N') = 'S') then
            v_sql := v_sql||'
                       union
                     select distinct ''A'', a.pva_id, a.pva_descricao_title, e.descricao,
                            o.nro_vendas as qnt_vendida, o.preco as precopromocoes, o.flestoque disp
                       from web_prod_venda_agregada a, web_itprod_venda_agregada ita,
                            web_itprod it, web_prod p, web_grupo g, web_familia f, web_linha l, web_empresa e, web_prodcaract c,
                            web_itprod it2, web_prod p2, web_grupo g2, web_familia f2, web_linha l2, web_empresa e2, web_prodcaract c2, web_prod_agregada_ordenacao o
                      where a.pva_id = ita.pva_id
                        and a.itm_id   = it.coditprod
                        and it.codprod = p.codprod
                        and p.codprod  = c.codprod
                        and p.codgrupo = g.codgrupo
                        and g.codfam   = f.codfam
                        and f.codlinha = l.codlinha
                        and p.codempresa = e.codempresa
                        and p.fl_disponivel_venda = ''S''
                        and a.pva_fl_ativo = ''S''
                        and ita.itm_id_agregado = it2.coditprod
                        and it2.codprod = p2.codprod
                        and p2.codprod  = c2.codprod
                        and p2.codgrupo = g2.codgrupo
                        and g2.codfam   = f2.codfam
                        and f2.codlinha = l2.codlinha
                        and p2.codempresa = e2.codempresa
                        and a.pva_descricao_url is not null and a.pva_descricao_title is not null
                        and o.pva_id (+) = a.pva_id ';
            if(p_loja_fisica = 'S') then
              v_sql := v_sql||' and p.flcatalogo = ''S'' ';
            else
              v_sql := v_sql||' and p.flativo = ''S'' ';
            end if;
            if(p_theme not in ('site','mobile')) then
              v_sql := v_sql||' and p.fl'||p_theme||' = ''S'' ';
            end if;
    
            if(p_busca_exata = 'N') then
              v_sql := v_sql||' and ( ( 1 = 1 ';
              filtro_busca;
              if(p_linha is not null) then
                v_sql := v_sql||' and l.codlinha = :p_linha ';
              end if;
              if(p_familia is not null) then
                v_sql := v_sql||' and f.codfam = :p_familia ';
              end if;
              if(p_grupo is not null) then
                v_sql := v_sql||' and g.codgrupo = :p_grupo ';
              end if;
    
              v_sql := v_sql||' ) or ( a.fl_inversao = ''S'' ';
              filtro_busca('2');
              if(p_linha is not null) then
                v_sql := v_sql||' and l2.codlinha = :p_linha ';
              end if;
              if(p_familia is not null) then
                v_sql := v_sql||' and f2.codfam = :p_familia ';
              end if;
              if(p_grupo is not null) then
                v_sql := v_sql||' and g2.codgrupo = :p_grupo ';
              end if;
              v_sql := v_sql||' ) ) ';
            else
              v_sql := v_sql||' and upper(a.pva_descricao_url) = :p_sinonimo1 ';
            end if;
        end if;

        v_sql := v_sql||'
                   union
                 select distinct ''B'', b.cod_brinde, b.descricao_title, e.descricao,
                        o.nro_vendas as qnt_vendida, o.preco as precopromocoes, o.flestoque disp
                   from web_itprod_brinde b, web_itprod_brinde_itens ib,
                        web_itprod it, web_prod p, web_grupo g, web_familia f, web_linha l, web_empresa e, web_prodcaract c,
                        web_itprod it2, web_prod p2, web_grupo g2, web_familia f2, web_linha l2, web_empresa e2, web_itprod_brinde_ordenacao o
                  where b.cod_itprod_principal = it.coditprod
                    and it.codprod = p.codprod
                    and p.codprod  = c.codprod
                    and p.codgrupo = g.codgrupo
                    and g.codfam   = f.codfam
                    and f.codlinha = l.codlinha
                    and p.codempresa = e.codempresa
                    and sysdate between b.dtinicio and b.dtfim
                    and b.fl_ativo = ''S''
                    and ib.cod_brinde = b.cod_brinde
                    and ib.cod_itprod = it2.coditprod
                    and it2.codprod = p2.codprod
                    and p2.codgrupo = g2.codgrupo
                    and g2.codfam   = f2.codfam
                    and f2.codlinha = l2.codlinha
                    and p2.codempresa = e2.codempresa
                    and b.descricao_url is not null and b.descricao_title is not null
                    and o.cod_brinde (+) = b.cod_brinde
                    ';
        if(p_loja_fisica = 'S') then
          v_sql := v_sql||' and p.flcatalogo = ''S'' ';
        else
          v_sql := v_sql||' and p.flativo = ''S'' ';
        end if;
        if(p_theme not in ('site','mobile')) then
          v_sql := v_sql||' and p.fl'||p_theme||' = ''S'' ';
        end if;
        if(p_busca_exata = 'N') then
          v_sql := v_sql||' and ( ( 1 = 1 ';
          filtro_busca;
          if(p_linha is not null) then
            v_sql := v_sql||' and l.codlinha = :p_linha ';
          end if;
          if(p_familia is not null) then
            v_sql := v_sql||' and f.codfam = :p_familia ';
          end if;
          if(p_grupo is not null) then
            v_sql := v_sql||' and g.codgrupo = :p_grupo ';
          end if;
          v_sql := v_sql||' ) or ( 1 = 1 ';
          filtro_busca('2');
          if(p_linha is not null) then
            v_sql := v_sql||' and l2.codlinha = :p_linha ';
          end if;
          if(p_familia is not null) then
            v_sql := v_sql||' and f2.codfam = :p_familia ';
          end if;
          if(p_grupo is not null) then
            v_sql := v_sql||' and g2.codgrupo = :p_grupo ';
          end if;
          v_sql := v_sql||' ) ) ';
        else
          v_sql := v_sql||' and upper(b.descricao_url) = :p_sinonimo1 ';
        end if;
      end if;

      v_sql := v_sql||' ) tab order by disp desc, ';
      if(p_ordem = 1)then
        v_sql := v_sql||' descricao_produto ';
      elsif(p_ordem = 2)then
        v_sql := v_sql||' precopromocoes ';
      elsif(p_ordem = 3)then
        v_sql := v_sql||' precopromocoes desc ';
      elsif(p_ordem = 4)then
        v_sql := v_sql||' descricao_empresa ';
      elsif(p_ordem = 5)then
        v_sql := v_sql||' descricao_produto  ';
      elsif(p_ordem = 6)then
        v_sql := v_sql||' descricao_produto desc ';
      elsif(p_ordem = 7)then
        v_sql := v_sql||'  qnt_vendida desc ';
      else
        v_sql := v_sql||'  descricao_produto ';
      end if;
      --dbms_output.put_line(v_sql);

      cPesquisa := dbms_sql.open_cursor;
      dbms_sql.parse(cPesquisa, v_sql, dbms_sql.NATIVE);

      if(p_linha is not null) then
        dbms_sql.bind_variable(cPesquisa, ':p_linha', p_linha);
      end if;
      if(p_familia is not null) then
        dbms_sql.bind_variable(cPesquisa, ':p_familia', p_familia);
      end if;
      if(p_grupo is not null) then
        dbms_sql.bind_variable(cPesquisa, ':p_grupo', p_grupo);
      end if;
      if(p_busca_exata = 'N') then
        for counter in v_sinonimos.first..v_sinonimos.last loop
          dbms_sql.bind_variable(cPesquisa, ':p_sinonimo'||counter, '%'||upper(v_sinonimos(counter))||'%');
          dbms_output.put_line('v_sinonimos:' || counter || '    :   ' || v_sinonimos(counter));
        end loop;
      else
        dbms_sql.bind_variable(cPesquisa, ':p_sinonimo1', upper(v_sinonimos(1)));
        dbms_output.put_line('p_sinonimo1:' || v_sinonimos(1));
      end if;

      dbms_sql.describe_columns(cPesquisa, col_num, rec_tab);
      defineColunas(cPesquisa, rec_tab);

      p_ignore := dbms_sql.execute(cPesquisa);
      loop
        exit when dbms_sql.fetch_rows(cPesquisa) <= 0;
        row_num := row_num+1;
        exit when (v_fim is not null and row_num > v_fim);
        dbms_sql.column_value(cPesquisa, 1, v_tipo);
        dbms_sql.column_value(cPesquisa, 2, v_codigo);
        dbms_sql.column_value(cPesquisa, 3, v_descricao_produto);
        dbms_sql.column_value(cPesquisa, 4, v_descricao_empresa);

        v_imprimir := true;
        if(v_inicio is not null and v_fim is not null) then
          v_imprimir := row_num between (v_inicio+1) and (v_fim);
        end if;
        if(v_imprimir) then
          out_rec := tp_web_retorno_pesquisa(v_tipo, v_codigo, v_descricao_produto);
          pipe row(out_rec);
        end if;

      end loop;
      dbms_sql.close_cursor(cPesquisa);

    end if;

    null;
  END pesquisa_produtos_banco;

  FUNCTION pesquisa_livros( p_autor  varchar2 default null,
                            p_titulo varchar2 default null, p_editora varchar2 default null,
                            p_isbn   varchar2 default null, p_assunto varchar2 default null,
                            p_pagina integer default null, p_results integer default null,
                            p_ordem  integer, p_theme varchar, p_loja_fisica varchar default 'N')
  RETURN tp_web_retorno_pesquisa_tb PIPELINED as

    v_tipo char(1);
    v_codigo integer;
    v_descricao_produto varchar2(500);
    v_precovista number(12,4);

    v_pagina integer := p_pagina;
    v_imprimir boolean;

    cPesquisa number;
    col_num   integer;
    row_num   integer := 0;
    p_ignore  integer;
    rec_tab   dbms_sql.desc_tab;

    out_rec tp_web_retorno_pesquisa;
    v_sql VARCHAR2(32000);

  BEGIN

  v_sql := '
      select *
        from (
              select ''P'' as tipo, p.codprod as codigo, p.descricao as descricao_produto, p.precovista
                from web_prod p, sitefornecedor.produto pf, sitefornecedor.livro l
               where p.fl_disponivel_venda = ''S''
                 and p.codprod = pf.codprod
                 and pf.id_produto = l.id_produto
                 ';
    if(p_loja_fisica = 'S') then
      v_sql := v_sql||' and p.flcatalogo = ''S'' ';
    else
      v_sql := v_sql||' and p.flativo = ''S'' ';
    end if;
    if(p_theme not in ('site','mobile')) then
      v_sql := v_sql||' and p.fl'||p_theme||' = ''S'' ';
    end if;

    if(p_isbn is not null) then
        v_sql := v_sql||' and l.isbn = :p_isbn ';
    else
      if(p_autor is not null) then
        v_sql := v_sql||' and CONVERT(UPPER(l.autor),''SF7ASCII'') LIKE :p_autor ';
      end if;
      if(p_titulo is not null) then
        v_sql := v_sql||' and CONVERT(UPPER(pf.descricao),''SF7ASCII'') LIKE :p_titulo ';
      end if;
      if(p_editora is not null) then
        v_sql := v_sql||' and CONVERT(UPPER(l.editora),''SF7ASCII'') LIKE :p_editora ';
      end if;
      if(p_assunto is not null) then
        v_sql := v_sql||' and CONVERT(UPPER(l.assuntos),''SF7ASCII'') LIKE :p_assunto ';
      end if;
    end if;

    if(p_theme not in ('mobile')) then
      v_sql := v_sql||'
                 union
               select distinct ''A'', a.pva_id, a.pva_descricao_title, p.precovista+sum(p2.precovista)
                 from web_prod_venda_agregada a, web_itprod_venda_agregada ita,
                      web_itprod it, web_prod p, sitefornecedor.produto pf, sitefornecedor.livro l,
                      web_itprod it2, web_prod p2, sitefornecedor.produto pf2, sitefornecedor.livro l2
                where a.pva_id = ita.pva_id
                  and a.itm_id   = it.coditprod
                  and it.codprod = p.codprod
                  and p.codprod = pf.codprod
                  and pf.id_produto = l.id_produto
                  and p.fl_disponivel_venda = ''S''
                  and a.pva_fl_ativo = ''S''
                  and ita.itm_id_agregado = it2.coditprod
                  and it2.codprod = p2.codprod
                  and p2.codprod = pf2.codprod
                  and pf2.id_produto = l2.id_produto
                  and a.pva_descricao_url is not null and a.pva_descricao_title is not null ';
      if(p_loja_fisica = 'S') then
        v_sql := v_sql||' and p.flcatalogo = ''S'' ';
      else
        v_sql := v_sql||' and p.flativo = ''S'' ';
      end if;
      if(p_theme not in ('site','mobile')) then
        v_sql := v_sql||' and p.fl'||p_theme||' = ''S'' ';
      end if;

      v_sql := v_sql||' and ( ( 1 = 1 ';

      if(p_isbn is not null) then
          v_sql := v_sql||' and l.isbn = :p_isbn ';
      else
        if(p_autor is not null) then
          v_sql := v_sql||' and CONVERT(UPPER(l.autor),''SF7ASCII'') LIKE :p_autor ';
        end if;
        if(p_titulo is not null) then
          v_sql := v_sql||' and CONVERT(UPPER(pf.descricao),''SF7ASCII'') LIKE :p_titulo ';
        end if;
        if(p_editora is not null) then
          v_sql := v_sql||' and CONVERT(UPPER(l.editora),''SF7ASCII'') LIKE :p_editora ';
        end if;
        if(p_assunto is not null) then
          v_sql := v_sql||' and CONVERT(UPPER(l.assuntos),''SF7ASCII'') LIKE :p_assunto ';
        end if;
      end if;

      v_sql := v_sql||' ) or ( a.fl_inversao = ''S'' ';

      if(p_isbn is not null) then
          v_sql := v_sql||' and l2.isbn = :p_isbn ';
      else
        if(p_autor is not null) then
          v_sql := v_sql||' and CONVERT(UPPER(l2.autor),''SF7ASCII'') LIKE :p_autor ';
        end if;
        if(p_titulo is not null) then
          v_sql := v_sql||' and CONVERT(UPPER(pf2.descricao),''SF7ASCII'') LIKE :p_titulo ';
        end if;
        if(p_editora is not null) then
          v_sql := v_sql||' and CONVERT(UPPER(l2.editora),''SF7ASCII'') LIKE :p_editora ';
        end if;
        if(p_assunto is not null) then
          v_sql := v_sql||' and CONVERT(UPPER(l2.assuntos),''SF7ASCII'') LIKE :p_assunto ';
        end if;
      end if;

      v_sql := v_sql||' ) ) group by a.pva_id, a.pva_descricao_title, p.precovista ';
      v_sql := v_sql||'
                 union
               select distinct ''B'', b.cod_brinde, b.descricao_title, bp.preco
                 from web_itprod_brinde b, web_itprod_brindeplano bp,
                      web_itprod it, web_prod p, sitefornecedor.produto pf, sitefornecedor.livro l
                where b.cod_itprod_principal = it.coditprod
                  and it.codprod = p.codprod
                  and p.codprod = pf.codprod
                  and pf.id_produto = l.id_produto
                  and p.fl_disponivel_venda = ''S''
                  and sysdate between b.dtinicio and b.dtfim
                  and b.cod_brinde = bp.cod_brinde
                  and bp.codplano  = ''BO''
                  and b.fl_ativo = ''S''
                  and b.descricao_url is not null and b.descricao_title is not null ';
      if(p_loja_fisica = 'S') then
        v_sql := v_sql||' and p.flcatalogo = ''S'' ';
      else
        v_sql := v_sql||' and p.flativo = ''S'' ';
      end if;
      if(p_theme not in ('site','mobile')) then
        v_sql := v_sql||' and p.fl'||p_theme||' = ''S'' ';
      end if;

      if(p_isbn is not null) then
          v_sql := v_sql||' and l.isbn = :p_isbn ';
      else
        if(p_autor is not null) then
          v_sql := v_sql||' and CONVERT(UPPER(l.autor),''SF7ASCII'') LIKE :p_autor ';
        end if;
        if(p_titulo is not null) then
          v_sql := v_sql||' and CONVERT(UPPER(pf.descricao),''SF7ASCII'') LIKE :p_titulo ';
        end if;
        if(p_editora is not null) then
          v_sql := v_sql||' and CONVERT(UPPER(l.editora),''SF7ASCII'') LIKE :p_editora ';
        end if;
        if(p_assunto is not null) then
          v_sql := v_sql||' and CONVERT(UPPER(l.assuntos),''SF7ASCII'') LIKE :p_assunto ';
        end if;
      end if;
    end if;

    v_sql := v_sql||' ) ';
    if(p_ordem = 1)then
      v_sql := v_sql||' order by descricao_produto ';
    elsif(p_ordem = 2)then
      v_sql := v_sql||' order by precovista ';
    elsif(p_ordem = 3)then
      v_sql := v_sql||' order by precovista desc ';
    else
      v_sql := v_sql||' order by descricao_produto ';
    end if;
    --dbms_output.put_line(v_sql);

    cPesquisa := dbms_sql.open_cursor;
    dbms_sql.parse(cPesquisa, v_sql, dbms_sql.NATIVE);

    if(p_isbn is not null) then
      dbms_sql.bind_variable(cPesquisa, ':p_isbn', p_isbn);
    else
      if(p_autor is not null) then
        dbms_sql.bind_variable(cPesquisa, ':p_autor', '%'||upper(p_autor)||'%');
      end if;
      if(p_titulo is not null) then
        dbms_sql.bind_variable(cPesquisa, ':p_titulo', '%'||upper(p_titulo)||'%');
      end if;
      if(p_editora is not null) then
        dbms_sql.bind_variable(cPesquisa, ':p_editora', '%'||upper(p_editora)||'%');
      end if;
      if(p_assunto is not null) then
        dbms_sql.bind_variable(cPesquisa, ':p_assunto', '%'||upper(p_assunto)||'%');
      end if;
    end if;

    dbms_sql.describe_columns(cPesquisa, col_num, rec_tab);
    defineColunas(cPesquisa, rec_tab);

    if(p_results is not null and p_pagina is null) then
      v_pagina := 1;
    end if;

    p_ignore := dbms_sql.execute(cPesquisa);
    loop
      exit when dbms_sql.fetch_rows(cPesquisa) <= 0;
      row_num := row_num+1;
      exit when (p_results is not null and row_num > v_pagina*p_results);
      dbms_sql.column_value(cPesquisa, 1, v_tipo);
      dbms_sql.column_value(cPesquisa, 2, v_codigo);
      dbms_sql.column_value(cPesquisa, 3, v_descricao_produto);
      dbms_sql.column_value(cPesquisa, 4, v_precovista);

      v_imprimir := true;
      if(p_results is not null) then
        v_imprimir := row_num between ((v_pagina-1)*p_results)+1 and (v_pagina*p_results);
      end if;
      if(v_imprimir) then
        out_rec := tp_web_retorno_pesquisa(v_tipo, v_codigo, v_descricao_produto);
        pipe row(out_rec);
      end if;

    end loop;
    dbms_sql.close_cursor(cPesquisa);

  END pesquisa_livros;

  FUNCTION lista_selos( p_tipo integer, p_linha integer default null,
                        p_pagina integer default null, p_results integer default null,
                        p_ordem  integer, p_theme varchar, p_loja_fisica varchar default 'N')
  RETURN tp_web_retorno_pesquisa_tb PIPELINED AS

    v_tipo char(1);
    v_codigo integer;
    v_descricao_produto varchar2(500);
    v_precovista number(12,4);

    v_pagina integer := p_pagina;
    v_imprimir boolean;

    cPesquisa number;
    col_num   integer;
    row_num   integer := 0;
    p_ignore  integer;
    rec_tab   dbms_sql.desc_tab;

    out_rec tp_web_retorno_pesquisa;
    v_sql VARCHAR2(32000);

  BEGIN

    v_sql := '
      select *
        from (
              select ''P'' as tipo, p.codprod as codigo, p.descricao as descricao_produto, p.precovista
                from web_prod p, web_grupo g, web_familia f, web_selo s, web_prod_selo ps
               where p.fl_disponivel_venda = ''S''
                 and p.codgrupo = g.codgrupo
                 and g.codfam   = f.codfam
                 and p.codprod  = ps.produto
                 and ps.selo    = s.codigo
                 and ps.tipo    = ''I''
                 and sysdate between s.dtinicio and s.dtfinal
                 and s.tpselo   = :p_tipo
                 and s.theme    = :p_theme
                 ';
    if(p_loja_fisica = 'S') then
      v_sql := v_sql||' and p.flcatalogo = ''S'' ';
    else
      v_sql := v_sql||' and p.flativo = ''S'' ';
    end if;
    if(p_theme not in ('site','mobile')) then
      v_sql := v_sql||' and p.fl'||p_theme||' = ''S'' ';
    end if;
    if(p_linha is not null) then
      v_sql := v_sql||' and s.linha = :p_linha ';
    else
      v_sql := v_sql||' and s.linha is null ';
    end if;

    if(p_theme not in ('mobile')) then
      if (nvl(fnc_retorna_parametro('GSA','LISTA AGREGADOS'),'N') = 'S') then
          v_sql := v_sql||'
                     union
                   select distinct ''A'', a.pva_id, a.pva_descricao_title, p.precovista
                     from web_prod_venda_agregada a,
                          web_itprod it, web_prod p, web_grupo g, web_familia f,
                          web_selo s, web_virtual_selo vs
                    where a.itm_id   = it.coditprod
                      and it.codprod = p.codprod
                      and p.codgrupo = g.codgrupo
                      and g.codfam   = f.codfam
    
                      and a.pva_id   = vs.codigo_tipo
                      and vs.tipo    = ''A''
                      and vs.selo    = s.codigo
                      and sysdate between s.dtinicio and s.dtfinal
                      and s.tpselo   = :p_tipo
                      and s.theme    = :p_theme
    
                      and p.fl_disponivel_venda = ''S''
                      and a.pva_fl_ativo = ''S''
                      and a.pva_descricao_url is not null and a.pva_descricao_title is not null
                       ';
          if(p_loja_fisica = 'S') then
            v_sql := v_sql||' and p.flcatalogo = ''S'' ';
          else
            v_sql := v_sql||' and p.flativo = ''S'' ';
          end if;
          if(p_theme not in ('site','mobile')) then
            v_sql := v_sql||' and p.fl'||p_theme||' = ''S'' ';
          end if;
          if(p_linha is not null) then
            v_sql := v_sql||' and s.linha = :p_linha ';
          else
            v_sql := v_sql||' and s.linha is null ';
          end if;
      end if;

      v_sql := v_sql||'
                 union
               select distinct ''B'', b.cod_brinde, b.descricao_title, p.precovista
                 from web_itprod_brinde b,
                      web_itprod it, web_prod p, web_grupo g, web_familia f,
                      web_selo s, web_virtual_selo vs
                where b.cod_itprod_principal = it.coditprod
                  and it.codprod = p.codprod
                  and p.codgrupo = g.codgrupo
                  and g.codfam   = f.codfam

                  and b.cod_brinde = vs.codigo_tipo
                  and vs.tipo      = ''B''
                  and vs.selo      = s.codigo
                  and sysdate between s.dtinicio and s.dtfinal
                  and s.tpselo     = :p_tipo
                  and s.theme      = :p_theme

                  and p.fl_disponivel_venda = ''S''
                  and sysdate between b.dtinicio and b.dtfim
                  and b.fl_ativo = ''S''
                  and b.descricao_url is not null and b.descricao_title is not null ';
      if(p_loja_fisica = 'S') then
        v_sql := v_sql||' and p.flcatalogo = ''S'' ';
      else
        v_sql := v_sql||' and p.flativo = ''S'' ';
      end if;
      if(p_theme not in ('site','mobile')) then
        v_sql := v_sql||' and p.fl'||p_theme||' = ''S'' ';
      end if;
      if(p_linha is not null) then
        v_sql := v_sql||' and s.linha = :p_linha ';
      else
        v_sql := v_sql||' and s.linha is null ';
      end if;
    end if;

    v_sql := v_sql||' ) ';
    if(p_results is null or p_pagina is null) then
      v_sql := v_sql||' order by dbms_random.random ';
    else
      if(p_ordem = 1)then
        v_sql := v_sql||' order by descricao_produto ';
      elsif(p_ordem = 2)then
        v_sql := v_sql||' order by precovista ';
      elsif(p_ordem = 3)then
        v_sql := v_sql||' order by precovista desc ';
      else
        v_sql := v_sql||' order by descricao_produto ';
      end if;
    end if;
    --dbms_output.put_line(v_sql);

    cPesquisa := dbms_sql.open_cursor;
    dbms_sql.parse(cPesquisa, v_sql, dbms_sql.NATIVE);

    dbms_sql.bind_variable(cPesquisa, ':p_tipo', p_tipo);
    dbms_sql.bind_variable(cPesquisa, ':p_theme', p_theme);
    if(p_linha is not null) then
      dbms_sql.bind_variable(cPesquisa, ':p_linha', p_linha);
    end if;

    dbms_sql.describe_columns(cPesquisa, col_num, rec_tab);
    defineColunas(cPesquisa, rec_tab);

    if(p_results is not null and p_pagina is null) then
      v_pagina := 1;
    end if;

    p_ignore := dbms_sql.execute(cPesquisa);
    loop
      exit when dbms_sql.fetch_rows(cPesquisa) <= 0;
      row_num := row_num+1;
      exit when (p_results is not null and row_num > v_pagina*p_results);
      dbms_sql.column_value(cPesquisa, 1, v_tipo);
      dbms_sql.column_value(cPesquisa, 2, v_codigo);
      dbms_sql.column_value(cPesquisa, 3, v_descricao_produto);
      dbms_sql.column_value(cPesquisa, 4, v_precovista);

      v_imprimir := true;
      if(p_results is not null) then
        v_imprimir := row_num between ((v_pagina-1)*p_results)+1 and (v_pagina*p_results);
      end if;
      if(v_imprimir) then
        out_rec := tp_web_retorno_pesquisa(v_tipo, v_codigo, v_descricao_produto);
        pipe row(out_rec);
      end if;

    end loop;
    dbms_sql.close_cursor(cPesquisa);

  END lista_selos;

  FUNCTION lista_virtual_gsa RETURN tp_web_virtual_gsa_tb PIPELINED AS

    cursor cAgregada is
      select a.pva_id as codigo, 'A' as tipo, a.pva_descricao_url, a.pva_descricao_title as descricao, g.codgrupo, g.descricao as descricao_grupo, p.minicaract,
             f.codfam, f.descricao as descricao_familia, l.codlinha, l.descricao as descricao_linha, p.codprod,
             p.flativo, p.flcatalogo,p.floutlet, e.codempresa, e.descricao as descricao_empresa, nvl(p.precovista,0) precovista,
             a.pva_descricao_title as descricao_title
        from web_prod_venda_agregada a, web_itprod it, web_prod p, web_grupo g, web_familia f, web_linha l, web_empresa e
       where a.pva_descricao_url is not null
         and a.pva_fl_lista_site = 'S'
         and a.pva_fl_ativo      = 'S'
         and a.itm_id = it.coditprod
         and it.codprod = p.codprod
         and p.codgrupo = g.codgrupo
         and g.codfam   = f.codfam
         and f.codlinha = l.codlinha
         and p.codempresa = e.codempresa
       union
      select b.cod_brinde, 'B', b.descricao_url, b.descricao_title, g.codgrupo, g.descricao, p.minicaract,
             f.codfam, f.descricao, l.codlinha, l.descricao, p.codprod,
             p.flativo, p.flcatalogo, p.floutlet, e.codempresa, e.descricao, b.valor_boleto precovista, b.descricao_title
        from web_itprod_brinde b, web_itprod it, web_prod p, web_grupo g, web_familia f, web_linha l, web_empresa e
       where b.descricao_url is not null
         and b.fl_lista_site = 'S'
         and b.fl_ativo      = 'S'
         and b.cod_itprod_principal = it.coditprod
         and sysdate between b.dtinicio and b.dtfim
         and it.codprod = p.codprod
         and p.codgrupo = g.codgrupo
         and g.codfam   = f.codfam
         and f.codlinha = l.codlinha
         and p.codempresa = e.codempresa;

    cursor cItensAgregada(p_pva_id in number) is
      select p.codprod, p.descricao, p.minicaract, p.flativo, p.flcatalogo,p.floutlet, nvl(p.precovista,0) precovista
        from web_itprod_venda_agregada ia, web_itprod i, web_prod p
       where ia.pva_id = p_pva_id
         and ia.itm_id_agregado = i.coditprod
         and i.codprod = p.codprod;

    cursor cItensBrinde(p_cod_brinde in number) is
      select p.codprod, p.descricao, p.minicaract, p.flativo, p.flcatalogo, p.floutlet, ib.valor_boleto precovista
        from web_itprod_brinde_itens ib, web_itprod i, web_prod p
       where ib.cod_brinde = p_cod_brinde
         and ib.cod_itprod = i.coditprod
         and i.codprod = p.codprod;

    cursor cPrecoBrinde(p_codbrinde number) is
      select preco from web_itprod_brinde_parcelas where codbrinde = p_codbrinde and tppgto = 2 and codfil = 400;


    out_rec tp_web_virtual_gsa;
    cr      sys_refcursor;

    r1      cAgregada%rowType;

    v_dias_mais_vendidos number(3);
    v_sql VARCHAR2(32000);

  BEGIN

    if (nvl(fnc_retorna_parametro('GSA','LISTA AGREGADOS'),'N') = 'S') then
      v_sql := 'select a.pva_id as codigo, ''A'' as tipo, a.pva_descricao_url, a.pva_descricao_title as descricao, g.codgrupo, g.descricao as descricao_grupo, p.minicaract,
                             f.codfam, f.descricao as descricao_familia, l.codlinha, l.descricao as descricao_linha, p.codprod,
                             p.flativo, p.flcatalogo,p.floutlet, e.codempresa, e.descricao as descricao_empresa, nvl(p.precovista,0) precovista,
                             a.pva_descricao_title as descricao_title
                        from web_prod_venda_agregada a, web_itprod it, web_prod p, web_grupo g, web_familia f, web_linha l, web_empresa e
                       where a.pva_descricao_url is not null
                         and a.pva_fl_lista_site = ''S''
                         and a.pva_fl_ativo      = ''S''
                         and a.itm_id = it.coditprod
                         and it.codprod = p.codprod
                         and p.codgrupo = g.codgrupo
                         and g.codfam   = f.codfam
                         and f.codlinha = l.codlinha
                         and p.codempresa = e.codempresa
                union ';
    end if;
    v_sql := v_sql ||'
              select b.cod_brinde, ''B'', b.descricao_url, b.descricao_title, g.codgrupo, g.descricao, p.minicaract,
                           f.codfam, f.descricao, l.codlinha, l.descricao, p.codprod,
                           p.flativo, p.flcatalogo, p.floutlet, e.codempresa, e.descricao, b.valor_boleto precovista, b.descricao_title
                      from web_itprod_brinde b, web_itprod it, web_prod p, web_grupo g, web_familia f, web_linha l, web_empresa e
                     where b.descricao_url is not null
                       and b.fl_lista_site = ''S''
                       and b.fl_ativo      = ''S''
                       and b.cod_itprod_principal = it.coditprod
                       and sysdate between b.dtinicio and b.dtfim
                       and it.codprod = p.codprod
                       and p.codgrupo = g.codgrupo
                       and g.codfam   = f.codfam
                       and f.codlinha = l.codlinha
                       and p.codempresa = e.codempresa    ';
   

    open cr for v_sql;
      loop
        fetch cr into r1;
        exit when cr%notfound;
              out_rec := tp_web_virtual_gsa(r1.codigo, r1.tipo);
              out_rec.codprod      := r1.codprod||',';
              out_rec.descricao    := fnc_tiraacentos_GSA(r1.descricao_title);
              out_rec.codgrupo     := r1.codgrupo;
              out_rec.desc_grupo   := fnc_tiraacentos_GSA(r1.descricao_grupo);
              out_rec.codfam       := r1.codfam;
              out_rec.desc_fam     := fnc_tiraacentos_GSA(r1.descricao_familia);
              out_rec.codlinha     := r1.codlinha;
              out_rec.desc_lin     := fnc_tiraacentos_GSA(r1.descricao_linha);
              out_rec.codempresa   := r1.codempresa;
              out_rec.desc_empresa := fnc_tiraacentos_GSA(r1.descricao_empresa);
              out_rec.minidescricao:= fnc_tiraacentos_GSA(r1.minicaract);
              out_rec.flativo      := r1.flativo;
              out_rec.flcatalogo   := r1.flcatalogo;
              out_rec.floutlet     := r1.floutlet;
              out_rec.mime         := 'text/html';
              out_rec.estoque_rs   := fnc_estoque_prod_uf(r1.codprod, 90000000);
              out_rec.estoque_sp   := fnc_estoque_prod_uf(r1.codprod, 01001000);
              out_rec.estoque_pr   := fnc_estoque_prod_uf(r1.codprod, 80010000);
              out_rec.url          := r1.pva_descricao_url;
              out_rec.qnt_vendida  := 0;

             begin
               select nvl(sum(quantidade),0) qnt
               into out_rec.qnt_vendida
               from web_mais_vendidos m
               where m.codprod = r1.codprod
               and m.data_compra between sysdate - v_dias_mais_vendidos and sysdate;
             exception when others then
                 RAISE_APPLICATION_ERROR(-20003,' Erro: '||r1.codprod||' - '||v_dias_mais_vendidos);
             end;
             
             dbms_output.put_line('codigo: ' || r1.codprod  );
             
             begin
              select fnc_calcula_preco_gsa(r1.codprod,'P')
                into out_rec.precovista
                from dual;
             exception
               when others then
                 RAISE_APPLICATION_ERROR(-20003,' Erro2: '||out_rec.precovista||' - '||out_rec.codprod||' - '||sqlerrm);
             end;

              if(out_rec.tipoprod = 'A')then
                for r2 in cItensAgregada(r1.codigo) loop
                  out_rec.codprod       := out_rec.codprod||r2.codprod||',';
                  out_rec.minidescricao := out_rec.minidescricao||' - '||fnc_tiraacentos_GSA(r2.minicaract);
                  out_rec.flativo      := util.test( out_rec.flativo = 'S' and r2.flativo = 'S', 'S', 'N');
                  out_rec.flcatalogo   := util.test( out_rec.flcatalogo = 'S' and r2.flcatalogo = 'S', 'S', 'N');
                  out_rec.floutlet     := util.test( out_rec.floutlet = 'S' and r2.floutlet = 'S', 'S', 'N');
                  select preco_normal into r2.precovista from table (web_preco_ativo_parcela(r2.codprod)) preco where plano = 'BO';
                  out_rec.precovista   := out_rec.precovista+r2.precovista;
                end loop;
               out_rec.avaliacao    := get_avaliacoes_produto_virtual('A',r1.codigo); 
              elsif(out_rec.tipoprod = 'B')then
                for r2 in cItensBrinde(r1.codigo) loop
                  out_rec.codprod       := out_rec.codprod||r2.codprod||',';
                  out_rec.minidescricao := out_rec.minidescricao||' - '||fnc_tiraacentos_GSA(r2.minicaract);
                  out_rec.flativo      := util.test( out_rec.flativo = 'S' and r2.flativo = 'S', 'S', 'N');
                  out_rec.flcatalogo   := util.test( out_rec.flcatalogo = 'S' and r2.flcatalogo = 'S', 'S', 'N');
                  out_rec.floutlet     := util.test( out_rec.floutlet = 'S' and r2.floutlet = 'S', 'S', 'N');
                end loop;
                out_rec.avaliacao    := get_avaliacoes_produto_virtual('B',r1.codigo);
                for r3 in cPrecoBrinde(r1.codigo) loop
                  out_rec.precovista   := nvl(r3.preco, 0) ;
                end loop;
              end if;

              out_rec.minidescricao_lob := to_clob('<title>' || fnc_tiraacentos_GSA(out_rec.descricao) || '</title><body>' || fnc_tiraacentos_GSA(out_rec.minidescricao) || '</body>');

              pipe row(out_rec);
      end loop;
    close cr;

  END lista_virtual_gsa;

  FUNCTION get_avaliacoes_produto_virtual (p_tipo_produto varchar2,
                                           p_codigo number)
                                           RETURN NUMBER AS
                                           
      v_avaliacao number(6,2) := 0;
        
    BEGIN                                           
     
     if p_tipo_produto = 'B' then
     
      select GREATEST(
         (select max(nvl(p.nota,0)) as avaliacao
         from web_itprod_brinde b 
         left join WEB_ITPROD_BRINDE_ITENS item on item.cod_brinde = b.cod_brinde
         left join web_itprod it on it.coditprod = item.cod_itprod
         left join web_prod p on p.codprod = it.codprod
         where b.cod_brinde = p_codigo),
         (select nvl(p.nota,0)
          from web_itprod_brinde b 
          left join web_itprod it on it.coditprod = b.cod_itprod_principal
          left join web_prod p on p.codprod = it.codprod
          where b.cod_brinde = p_codigo)
        )avaliacao
        into v_avaliacao
        from dual;
        
     elsif p_tipo_produto = 'A' then
     
      select GREATEST(           
           (select  
             nvl(p.nota,0) as avaliacao
           from web_prod_venda_agregada va
           left join web_itprod it on it.coditprod = va.itm_id
           left join web_prod p on p.codprod = it.codprod
           where va.pva_id = p_codigo)
         ,
           (select  
             max(nvl(p.nota,0)) as avaliacao
           from web_prod_venda_agregada va
           left join WEB_ITPROD_VENDA_AGREGADA iv on iv.pva_id = va.pva_id
           left join web_itprod it on it.coditprod = iv.itm_id_agregado
           left join web_prod p on p.codprod = it.codprod
           where va.pva_id = p_codigo)
       ) avaliacao
       into v_avaliacao
       from dual;
       
     end if;
     
     return v_avaliacao;
                      
  END get_avaliacoes_produto_virtual;                                           


END PKG_PESQUISA_PRODUTOS;
/
