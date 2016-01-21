create or replace package body pkg_web_cupom_regras is
  
  -----------
  
  -- ARRAYS USADOS PARA MONTAGEM DO MENU --
  p_menu util.tarray := util.tarray('Cadastro do Cupom',
                                    'Simulador por Dados',
                                    'Simulador por Pedido');
  p_link util.tarray := util.tarray('pkg_web_cupom.startup',
                                    'pkg_web_cupom_simulador.startup_2',
                                    'pkg_web_cupom_simulador.startup');
  p_dest util.tarray := util.tarray('','',
                                    '','',
                                    '','');
  
  -----------
  
  cursor cur_tppgtos is
  select tppgto, descricao
  from   web_tppgto
  order  by 1;
  
  -----------
  
  arr_tipo_regra util.tarray := util.tarray
                                ( '0||Selecione'
                                , '1||Condição'
                                , '2||Instrução'
                                ) ;
  
  arr_clausula_11 util.tarray := util.tarray
                                 ( '||Selecione'
                                 , 'IF||SE'
  --                             , 'IF NOT||SE (Negado)'
                                 , 'ELSEIF||SENÃO SE'
  --                             , 'ELSEIF NOT||SENÃO SE (Negado)'
                                 , 'AND||E'
  --                             , 'AND NOT||E (Negado)'
                                 , 'OR||OU'
  --                             , 'OR NOT||OU (Negado)'
                                 ) ;
  
  arr_clausula_12 util.tarray := util.tarray
                                 ( '||Selecione'
                                 , 'VLMERCAD||Valor de produtos no carrinho'
                                 , 'QTDITENS||Quantidade total de produtos no carrinho '
                                 , 'QTDPRODS||Quantidade de produtos distintos no carrinho'
                                 , 'CODLINHA||Linha do produto'
                                 , 'CODFAM||Família do produto'
                                 , 'CODFORNE||Fornecedor do produto'
                                 , 'CODSITPROD||Atributo do produto'
                                 , 'CODPROD||Código do produto'
                                 , 'CODITPROD||Código do item'
                                 , 'ESTADO||UF do cliente'
                                 , 'CIDADE||Cidade do cliente'
                                 , 'CEP||CEP do cliente'
                                 , 'DTNASC||Data de nascimento do cliente'
                                 , 'DTCADASTRO||Data de cadastro do cliente'
                                 , 'SEXO||Sexo do cliente'
                                 , 'QTDCOMPRAS||Quantidade de compras do cliente'
                                 ) ;
  
  arr_clausula_13 util.tarray := util.tarray
                                 ( '||Selecione'
                                 , '>||Maior'
                                 , '>=||Maior igual'
                                 , '=||Igual'
                                 , '<=||Menor igual'
                                 , '<||Menor'
                                 , '<>||Diferente'
                                 ) ;
  
  arr_clausula_21 util.tarray := util.tarray
                                 ( '||Selecione'
                                 , 'DESCCARR||Desconto no carrinho'
                                 , 'DESCFRET||Desconto no frete'
                                 ) ;
  
  arr_clausula_23 util.tarray := util.tarray
                                 ( '||Selecione'
                                 , '%||%'
                                 , 'R$||Reais'
                                 ) ;
  
  arr_clausula_24 util.tarray := util.tarray
                                 ( '||Selecione'
                                 ) ;
  
  g_img_novo    varchar2(300) := 'http://intranet.colombo.com.br:7777/webjur/img/para_analise.gif';
  g_img_editar  varchar2(300) := 'http://intranet.colombo.com.br:7777/portal/img/editar.gif';
  g_img_excluir varchar2(300) := 'http://intranet.colombo.com.br:7777/portal/img/delete.gif';
  
  -----------
  
  function is_uppercase (p_value in varchar2) return boolean is
  begin
    
    if p_value = fnc_tiraacentos(upper(p_value)) then
      return true;
    else
      return false;
    end if;
    
  exception
    when others then
      return false;
  end is_uppercase;
  
  -----------
  
  function is_integer (p_value in varchar2) return boolean is
    
    v_aux number;
    
  begin
    
    v_aux := to_number(p_value);
    
    if v_aux = trunc(v_aux) then
      return true;
    else
      return false;
    end if;
    
  exception
    when value_error then
      return false;
  end is_integer;
  
  -----------
  
  function is_number (p_value in varchar2) return boolean is
    
    v_aux number;
    
  begin
    
    v_aux := to_number(p_value);
    
    return true;
    
  exception
    when value_error then
      return false;
  end is_number;
  
  -----------
  
  function is_date (p_value in varchar2) return boolean is
    
    v_aux date;
    
  begin
    
    v_aux := to_date(p_value,'dd/mm/yyyy');
    
    return true;
    
  exception
    when others then
      return false;
  end is_date;
  
  -----------
  
  function get_next_id return number is
    
    v_id_regra web_cupom_regras.id_regra%type;
    
  begin
    
    select nvl(max(id_regra),0) + 1 into v_id_regra from web_cupom_regras;
    
    return v_id_regra;
    
  end get_next_id;
  
  -----------
  
  function get_desc_tipo_regra ( p_tipo_regra in number ) return varchar2 is
    
    v_tipo_regra varchar2(50);
    
  begin
    
    select decode( p_tipo_regra, 0, 'Selecione', 1, 'Condição', 2, 'Instrução' ) into v_tipo_regra from dual;
    
    return v_tipo_regra;
    
  end get_desc_tipo_regra;
  
  -----------
  
  function get_desc_simnao ( p_status in number ) return varchar2 is
    
    v_status varchar2(50);
    
  begin
    
    select decode( p_status, 0, 'Não', 1, 'Sim' ) into v_status from dual;
    
    return v_status;
    
  end get_desc_simnao;
  
  -----------
  
  function get_desc_clausula_11 ( p_clausula_11 in varchar2 ) return varchar2 is
    
    v_clausula_11 varchar2(100);
    
  begin
    
    select decode( p_clausula_11, 'IF'        , 'SE'
                                , 'IF NOT'    , 'SE (Negado)'
                                , 'ELSEIF'    , 'SENÃO SE'
                                , 'ELSEIF NOT', 'SENÃO SE (Negado)'
                                , 'AND'       , 'E'
                                , 'AND NOT'   , 'E (Negado)'
                                , 'OR'        , 'OU'
                                , 'OR NOT'    , 'OU (Negado)'
                 )
    into   v_clausula_11 
    from   dual;
    
    return v_clausula_11;
    
  end get_desc_clausula_11;
  
  -----------
  
  function get_desc_clausula_12 ( p_clausula_12 in varchar2 ) return varchar2 is
    
    v_clausula_12 varchar2(100);
    
  begin
    
    select decode( p_clausula_12, 'VLMERCAD'  , 'Valor de produtos no carrinho'
                                , 'QTDITENS'  , 'Quantidade total de produtos no carrinho '
                                , 'QTDPRODS'  , 'Quantidade de produtos distintos no carrinho'
                                , 'CODLINHA'  , 'Linha do produto'
                                , 'CODFAM'    , 'Família do produto'
                                , 'CODFORNE'  , 'Fornecedor do produto'
                                , 'CODSITPROD', 'Atributo do produto'
                                , 'CODPROD'   , 'Código do produto'
                                , 'CODITPROD' , 'Código do item'
                                , 'ESTADO'    , 'UF do cliente'
                                , 'CIDADE'    , 'Cidade do cliente'
                                , 'CEP'       , 'CEP do cliente'
                                , 'DTNASC'    , 'Data de nascimento do cliente'
                                , 'DTCADASTRO', 'Data de cadastro do cliente'
                                , 'SEXO'      , 'Sexo do cliente'
                                , 'QTDCOMPRAS', 'Quantidade de compras do cliente'
                 )
    into   v_clausula_12
    from   dual;
    
    return v_clausula_12;
    
  end get_desc_clausula_12;
  
  -----------

  function get_desc_clausula_13 ( p_clausula_13 in varchar2 ) return varchar2 is
    
    v_clausula_13 varchar2(100);
    
  begin
    
    select decode( p_clausula_13, '>'     , 'Maior'
                                , '>='    , 'Maior igual'
                                , '='     , 'Igual'
                                , '<='    , 'Menor igual'
                                , '<'     , 'Menor'
                                , '<>'    , 'Diferente'
                 )
    into   v_clausula_13
    from   dual;
    
    return v_clausula_13;
    
  end get_desc_clausula_13;
  
  -----------
  
  function get_desc_clausula_21 ( p_clausula_21 in varchar2 ) return varchar2 is
    
    v_clausula_21 varchar2(100);
    
  begin
    
    select decode( p_clausula_21, 'DESCCARR', 'Desconto no carrinho'
                                , 'DESCFRET', 'Desconto no frete'
                 )
    into   v_clausula_21
    from   dual;
    
    return v_clausula_21;
    
  end get_desc_clausula_21;
  
  -----------
  
  function get_desc_clausula_23 ( p_clausula_23 in varchar2 ) return varchar2 is
    
    v_clausula_23 varchar2(100);
    
  begin
    
    select decode( p_clausula_23, '%' , '%'
                                , 'R$', 'Reais'
                 )
    into   v_clausula_23
    from   dual;
    
    return v_clausula_23;
    
  end get_desc_clausula_23;
  
  -----------
  
  function get_desc_clausula_24 ( p_clausula_24 in varchar2 default null ) return varchar2 is
    
    v_clausula_24 varchar2(100);
    
  begin
    
    select descricao
    into   v_clausula_24
    from   web_tppgto
    where  tppgto = p_clausula_24;
    
    return v_clausula_24;
  
  exception
    when others then
      return null;
  end get_desc_clausula_24;
  
  -----------
  
  function ret_teste_clausula_13_number
  ( p_prefixo  in number   default null
  , p_operador in varchar2 
  , p_sufixo   in number 
  ) return boolean is
  begin
    
    if p_prefixo is null then
      return false;
    else
      case p_operador
        when '>'  then return p_prefixo >  p_sufixo;
        when '>=' then return p_prefixo >= p_sufixo;
        when '='  then return p_prefixo =  p_sufixo;
        when '<=' then return p_prefixo <= p_sufixo;
        when '<'  then return p_prefixo <  p_sufixo;
        when '<>' then return p_prefixo <> p_sufixo;
      end case;
    end if;
    
  end ret_teste_clausula_13_number;
  
  -----------
  
  function ret_teste_clausula_13_date
  ( p_prefixo  in date     default null
  , p_operador in varchar2 
  , p_sufixo   in date 
  ) return boolean is
  begin
    
    if p_prefixo is null then
      return false;
    else
      case p_operador
        when '>'  then return p_prefixo >  p_sufixo;
        when '>=' then return p_prefixo >= p_sufixo;
        when '='  then return p_prefixo =  p_sufixo;
        when '<=' then return p_prefixo <= p_sufixo;
        when '<'  then return p_prefixo <  p_sufixo;
        when '<>' then return p_prefixo <> p_sufixo;
      end case;
    end if;
    
  end ret_teste_clausula_13_date;
  
  -----------
  
  function ret_teste_clausula_13_varchar
  ( p_prefixo  in varchar2 default null
  , p_operador in varchar2 
  , p_sufixo   in varchar2 
  ) return boolean is
  
    v_prefixo varchar2(300) := replace(p_prefixo,'''','');
    v_sufixo  varchar2(300) := replace(p_sufixo,'''','');
    
  begin
    
    if p_prefixo is null then
      return false;
    else
      case p_operador
        when '>'  then return v_prefixo >  v_sufixo;
        when '>=' then return v_prefixo >= v_sufixo;
        when '='  then return v_prefixo =  v_sufixo;
        when '<=' then return v_prefixo <= v_sufixo;
        when '<'  then return v_prefixo <  v_sufixo;
        when '<>' then return v_prefixo <> v_sufixo;
      end case;
    end if;
    
  end ret_teste_clausula_13_varchar;
  
  -----------
  
  function ret_teste_clausula_13_array
  ( p_prefixo  in owa_util.ident_arr
  , p_operador in varchar2 
  , p_sufixo   in varchar2 
  ) return boolean is
  begin
    
    for i in p_prefixo.first..p_prefixo.last loop
      begin
        if pkg_web_cupom_regras.ret_teste_clausula_13_number(p_prefixo(i), p_operador, p_sufixo) then
          return true;
        end if;
      exception when others then
        if pkg_web_cupom_regras.ret_teste_clausula_13_varchar(p_prefixo(i), p_operador, p_sufixo) then
          return true;
        end if;
      end;
    end loop;
    
    return false;
    
  end ret_teste_clausula_13_array;
  
  -----------
  
  procedure insere ( p_vo in web_cupom_regra_vo ) is
  begin
    
    insert into web_cupom_regras
      ( id_regra
      , id_regra_pai
      , id_cupom
      , tipo_regra
      , clausula_1
      , clausula_2
      , clausula_3
      , clausula_4
      )
    values
      ( p_vo.id_regra
      , p_vo.id_regra_pai
      , p_vo.id_cupom
      , p_vo.tipo_regra
      , replace(p_vo.clausula_1,'''','')
      , replace(replace(replace(p_vo.clausula_2,'''',''),'.',''),',','.')
      , replace(p_vo.clausula_3,'''','')
      , replace(p_vo.clausula_4,'''','')
    ) ;
    
  end insere;
  
  -----------
  
  procedure altera ( p_vo in web_cupom_regra_vo ) is
  begin
    
    update web_cupom_regras
    set    id_regra_pai   = p_vo.id_regra_pai
    ,      id_cupom       = p_vo.id_cupom
    ,      tipo_regra     = p_vo.tipo_regra
    ,      clausula_1     = replace(p_vo.clausula_1,'''','')
    ,      clausula_2     = replace(replace(replace(p_vo.clausula_2,'''',''),'.',''),',','.')
    ,      clausula_3     = replace(p_vo.clausula_3,'''','')
    ,      clausula_4     = replace(p_vo.clausula_4,'''','')
    where  id_regra       = p_vo.id_regra;
    
  end altera;
  
  -----------
  
  procedure exclui ( p_id_cupom     in number default null ,
                     p_id_regra_pai in number default null ,
                     p_id_regra     in number default null ) is
  begin
    
    update web_cupom_regras
    set    id_regra_pai = p_id_regra_pai
    where  id_regra_pai = p_id_regra;
    
    delete web_cupom_regras 
    where  id_regra     = p_id_regra;
    
    htp.script('
      alert("Regra removida com sucesso!");
      location.href="pkg_web_cupom_regras.startup?p_id_cupom=' || p_id_cupom || '";
    ');
    
  end exclui;
  
  -----------
  
  function seleciona ( p_vo in web_cupom_regra_vo ) return array_web_cupom_regra_vo is
    
    cr        sys_refcursor;
    cr_sql    long;
    
    v_vo      web_cupom_regra_vo;
    v_array   array_web_cupom_regra_vo;
    
    n_cont    number := 0;
    
  begin
    
    cr_sql := ' select cr.id_regra, cr.id_regra_pai, cr.id_cupom, cr.tipo_regra, cr.clausula_1, cr.clausula_2, cr.clausula_3, cr.clausula_4
                from   web_cupom_regras cr
                where  1 = 1 ';
    
    if p_vo.id_regra is not null then
      cr_sql := cr_sql || ' and cr.id_regra = ' || p_vo.id_regra;
    end if;
    
    if p_vo.id_regra_pai is not null then
      cr_sql := cr_sql || ' and cr.id_regra_pai = ' || p_vo.id_regra_pai;
    end if;
    
    if p_vo.id_cupom is not null then
      cr_sql := cr_sql || ' and cr.id_cupom = ' || p_vo.id_cupom;
    end if;
    
    if p_vo.tipo_regra is not null then
      cr_sql := cr_sql || ' and cr.tipo_regra = ' || p_vo.tipo_regra;
    end if;
    
    if p_vo.clausula_1 is not null then
      cr_sql := cr_sql || ' and lower(cr.clausula_1) like ' || '''%' || lower(p_vo.clausula_1) || '%''';
    end if;
    
    if p_vo.clausula_2 is not null then
      cr_sql := cr_sql || ' and lower(cr.clausula_2) like ' || '''%' || lower(p_vo.clausula_2) || '%''';
    end if;
    
    if p_vo.clausula_3 is not null then
      cr_sql := cr_sql || ' and lower(cr.clausula_3) like ' || '''%' || lower(p_vo.clausula_3) || '%''';
    end if;
    
    if p_vo.clausula_4 is not null then
      cr_sql := cr_sql || ' and lower(cr.clausula_4) like ' || '''%' || lower(p_vo.clausula_4) || '%''';
    end if;
    
    cr_sql := cr_sql || ' order by cr.id_regra_pai NULLS FIRST ';
    
    open cr for cr_sql;
    loop
      fetch cr into v_vo.id_regra, v_vo.id_regra_pai, v_vo.id_cupom, v_vo.tipo_regra, v_vo.clausula_1, v_vo.clausula_2, v_vo.clausula_3, v_vo.clausula_4;
      exit when cr%notfound;
      
      n_cont := n_cont + 1;
      
      v_array(n_cont).id_regra     := v_vo.id_regra;
      v_array(n_cont).id_regra_pai := v_vo.id_regra_pai;
      v_array(n_cont).id_cupom     := v_vo.id_cupom;
      v_array(n_cont).tipo_regra   := v_vo.tipo_regra;
      v_array(n_cont).clausula_1   := v_vo.clausula_1;
      v_array(n_cont).clausula_2   := v_vo.clausula_2;
      v_array(n_cont).clausula_3   := v_vo.clausula_3;
      v_array(n_cont).clausula_4   := v_vo.clausula_4;
      
    end loop;
    close cr;
    
    return v_array;
    
  end seleciona;
  
  -----------
  
  function carrega ( p_id_regra in number ) return web_cupom_regra_vo is
    
    v_vo web_cupom_regra_vo;
    
  begin
    
    select cr.id_regra, cr.id_regra_pai, cr.id_cupom, cr.tipo_regra, cr.clausula_1, cr.clausula_2, cr.clausula_3, cr.clausula_4
    into   v_vo.id_regra, v_vo.id_regra_pai, v_vo.id_cupom, v_vo.tipo_regra, v_vo.clausula_1, v_vo.clausula_2, v_vo.clausula_3, v_vo.clausula_4
    from   web_cupom_regras cr
    where  cr.id_regra = p_id_regra;
    
    return v_vo;
    
  end carrega;
  
  -----------
  
  procedure startup
  ( p_id_regra       in number   default null
  , p_id_regra_pai   in number   default null
  , p_id_cupom       in number   default null
  , p_tipo_regra     in number   default null
  , p_clausula_1     in varchar2 default null
  , p_clausula_2     in varchar2 default null
  , p_clausula_3     in varchar2 default null
  , p_clausula_4     in varchar2 default null
  , z_action         in varchar2 default null
  ) is
    
    n_cont     number := 0;
    v_vo       web_cupom_regra_vo;
    v_cupom_vo pkg_web_cupom.web_cupom_vo;
    v_regra_vo array_web_cupom_regra_vo;
    
  begin
    
    v_vo.id_cupom := p_id_cupom;
    v_cupom_vo    := pkg_web_cupom.carrega(p_id_cupom);
    v_regra_vo    := pkg_web_cupom_regras.seleciona(v_vo);
    
    template_site.pageopen('Central de Descontos: Regras do Cupom', null, p_menu, p_link, p_dest);
    
    hto.fieldsetopen;
    hto.legend('Dados do Cupom');
      
      htp.tableopen(cattributes => 'align="center" border="0" cellspacing="0" cellpadding="2"');
        
        htp.tablerowopen;
          htp.tableheader('Número: ', 'left');
          htp.tabledata(v_cupom_vo.id, 'left');
        htp.tablerowclose;
        
        htp.tablerowopen;
          htp.tableheader('Descrição: ', 'left');
          htp.tabledata(v_cupom_vo.descricao, 'left');
        htp.tablerowclose;
        
        htp.tablerowopen;
          htp.tableheader('Código: ', 'left');
          htp.tabledata(v_cupom_vo.codigo, 'left');
        htp.tablerowclose;
        
        htp.tablerowopen;
          htp.tableheader('Status: ', 'left');
          htp.tabledata(pkg_web_cupom.get_desc_status(v_cupom_vo.status), 'left');
        htp.tablerowclose;
        
        htp.tablerowopen;
          htp.tableheader('Limite de uso (Total): ', 'left');
          htp.tabledata(v_cupom_vo.limite_total, 'left');
        htp.tablerowclose;
        
        htp.tablerowopen;
          htp.tableheader('Limite de uso (por Cliente): ', 'left');
          htp.tabledata(v_cupom_vo.limite_cliente, 'left');
        htp.tablerowclose;
        
      htp.tableclose;
      
    hto.fieldsetclose;
    
    htp.br;
    
    hto.fieldsetopen;
    hto.legend('Regras');
    
    htp.br;
    
    if v_regra_vo.count > 0 then
      for i in v_regra_vo.first..v_regra_vo.last loop
        n_cont := n_cont + 1;
        
        if v_regra_vo(i).tipo_regra = 1 then
          htp.p (
          '<p style="font-weight: normal;">' || 
            htf.bold(upper(pkg_web_cupom_regras.get_desc_clausula_11(v_regra_vo(i).clausula_1))) || ' ' ||
            lower(pkg_web_cupom_regras.get_desc_clausula_12(v_regra_vo(i).clausula_2)) || ' ' ||
            htf.bold(' for ' || lower(pkg_web_cupom_regras.get_desc_clausula_13(v_regra_vo(i).clausula_3)) || ' a ') || ' ' ||
            v_regra_vo(i).clausula_4 || ' ' ||
            htf.anchor('pkg_web_cupom_regras.formulario?p_id_cupom=' || p_id_cupom || '&p_id_regra_pai=' || v_regra_vo(i).id_regra, htf.img(g_img_novo)) || ' ' ||
            htf.anchor('pkg_web_cupom_regras.formulario?p_id_regra=' || v_regra_vo(i).id_regra, htf.img(g_img_editar)) || ' ' ||
            htf.anchor('pkg_web_cupom_regras.exclui?p_id_cupom='     || p_id_cupom || '&p_id_regra='     || v_regra_vo(i).id_regra || '&p_id_regra_pai=' || v_regra_vo(i).id_regra_pai, htf.img(g_img_excluir)) ||
          '</p>'
          ) ;
          htp.br;
        elsif v_regra_vo(i).tipo_regra = 2 then
          htp.p (
          '<p style="font-weight: normal;">' ||
            htf.bold('ENTÃO')                                                          || ' ' ||
            lower(pkg_web_cupom_regras.get_desc_clausula_21(v_regra_vo(i).clausula_1)) || ' ' ||
            htf.bold('deve ser de ')                                                   || ' ' || 
            util.to_curr(str2num(v_regra_vo(i).clausula_2))                            || ' ' ||
            pkg_web_cupom_regras.get_desc_clausula_23(v_regra_vo(i).clausula_3)        || ' ' ||
            util.test(nvl(v_regra_vo(i).clausula_4,'Z') = 'Z', '', htf.br || '<sup>(caso pagamento seja feito via ' || lower(pkg_web_cupom_regras.get_desc_clausula_24(v_regra_vo(i).clausula_4)) || ')</sup>' || htf.br) || ' ' ||
            htf.anchor('pkg_web_cupom_regras.formulario?p_id_cupom=' || p_id_cupom || '&p_id_regra_pai=' || v_regra_vo(i).id_regra, htf.img(g_img_novo)) || ' ' ||
            htf.anchor('pkg_web_cupom_regras.formulario?p_id_regra=' || v_regra_vo(i).id_regra, htf.img(g_img_editar)) || ' ' ||
            htf.anchor('pkg_web_cupom_regras.exclui?p_id_cupom='     || p_id_cupom || '&p_id_regra='     || v_regra_vo(i).id_regra || '&p_id_regra_pai=' || v_regra_vo(i).id_regra_pai, htf.img(g_img_excluir)) ||
          '</p>'
          ) ;
          htp.br;
        end if;
      end loop;
    end if;
    
    hto.fieldsetclose;
    
    if n_cont = 0 then
      htp.br;
      htp.p(template_site.formbutton('Incluir Novo Registro', p_others => 'onclick="location.href=''pkg_web_cupom_regras.formulario?p_id_cupom=' || p_id_cupom || '''"'));
      htp.br;
    else
      htp.br;
      htp.p(template_site.formbutton('Voltar à Tela Principal', null, 'onclick="location.href=''pkg_web_cupom.startup''"'));
      htp.br;
    end if;
    
    template_site.pageclose;
    
  end startup;
  
  -----------
  
  procedure formulario 
  ( p_id_regra     in number   default null
  , p_id_cupom     in number   default null
  , p_id_regra_pai in number   default null
  , p_tipo_regra   in number   default null
  ) is
    
    v_vo web_cupom_regra_vo;
    v_tipo_regra number;
    
  begin
    
    begin
      v_vo := pkg_web_cupom_regras.carrega(p_id_regra);
    exception
      when others then
        v_vo := null;
    end;
    
    v_tipo_regra := nvl(p_tipo_regra, v_vo.tipo_regra);
    
    template_site.pageopen('Central de Descontos: Regras do Cupom', null, p_menu, p_link, p_dest);
    
    htp.script('
    function recarrega() {
      location.href="pkg_web_cupom_regras.formulario?p_id_regra=' || p_id_regra ||'&p_id_cupom=' || p_id_cupom || '&p_id_regra_pai=' || p_id_regra_pai || '&p_tipo_regra=" + document.forms[0].p_tipo_regra.value;
    }
    ');
    
    template_site.filtroopen('Filtros', '', 'pkg_web_cupom_regras.servlet');
      
      htp.formhidden('p_id_regra'    , v_vo.id_regra);
      htp.formhidden('p_id_regra_pai', nvl(v_vo.id_regra_pai, p_id_regra_pai));
      htp.formhidden('p_id_cupom'    , nvl(v_vo.id_cupom, p_id_cupom));
      
      template_site.filtrorow('Tipo Regra', template.formcombo('p_tipo_regra', arr_tipo_regra, v_tipo_regra, 'onchange="recarrega();"'));
      
      if v_tipo_regra = 1 then
        template_site.filtrorow('Cláusula 1', template.formcombo('p_clausula_1', arr_clausula_11, v_vo.clausula_1));
        template_site.filtrorow('Cláusula 2', template.formcombo('p_clausula_2', arr_clausula_12, v_vo.clausula_2));
        template_site.filtrorow('Cláusula 3', template.formcombo('p_clausula_3', arr_clausula_13, v_vo.clausula_3));
        template_site.filtrorow('Cláusula 4', htf.formtext('p_clausula_4', 60, 100, v_vo.clausula_4));
      elsif v_tipo_regra = 2 then
        template_site.filtrorow('Cláusula 1', template.formcombo('p_clausula_1', arr_clausula_21, v_vo.clausula_1));
        template_site.filtrorow('Cláusula 2', template.formnumber('p_clausula_2', 7, true, util.to_curr(str2num(v_vo.clausula_2))));
        template_site.filtrorow('Cláusula 3', template.formcombo('p_clausula_3', arr_clausula_23, v_vo.clausula_3));
        template_site.filtrorow('Cláusula 4', template.formcombo('p_clausula_4', arr_clausula_24, v_vo.clausula_4));
      end if;
      
      template_site.filtrobotoes(util.tarray(htf.formsubmit('z_action', 'Salvar Alterações')));
      
    template_site.filtroclose;
    
    template_site.pageclose;
    
  end formulario;
  
  -----------
  
  function valida ( p_vo in web_cupom_regra_vo ) return boolean is
    
    t_parametros web_respparam%rowtype;
    
  begin
    
    if p_vo.id_cupom is null then
      template_site.erro('Favor informar o cupom!');
      return false;
    end if;
    
    case nvl(p_vo.tipo_regra,0) 
    
    when 0 then
      
      template_site.erro('Favor informar o tipo de regra!');
      return false;
      
    when 1 then
      
      if p_vo.clausula_1 is null then
        template_site.erro('Favor informar a cláusula 1!');
        return false;
      end if;
      
      if p_vo.clausula_2 is null then
        template_site.erro('Favor informar a cláusula 2!');
        return false;
      end if;
      
      if p_vo.clausula_3 is null then
        template_site.erro('Favor informar a cláusula 3!');
        return false;
      end if;
      
      if p_vo.clausula_4 is null then
        template_site.erro('Favor informar a cláusula 4!');
        return false;
      end if;
      
      if p_vo.clausula_2 = 'VLMERCAD' and not is_number(p_vo.clausula_4) then
        template_site.erro('Valor inválido para "Valor de produtos no carrinho". Deve ser um valor numérico.');
        return false;
      end if;
      
      if p_vo.clausula_2 = 'QTDITENS' and not is_integer(p_vo.clausula_4) then
        template_site.erro('Valor inválido para "Quantidade total de produtos no carrinho". Deve ser um valor inteiro.');
        return false;
      end if;
      
      if p_vo.clausula_2 = 'QTDPRODS' and not is_integer(p_vo.clausula_4) then
        template_site.erro('Valor inválido para "Quantidade de produtos distintos no carrinho". Deve ser um valor inteiro.');
        return false;
      end if;
      
      if p_vo.clausula_2 = 'CODLINHA' and not is_integer(p_vo.clausula_4) then
        template_site.erro('Valor inválido para "Linha do produto". Deve ser um valor inteiro. Informe o código.');
        return false;
      end if;
      
      if p_vo.clausula_2 = 'CODFAM' and not is_integer(p_vo.clausula_4) then
        template_site.erro('Valor inválido para "Família do produto". Deve ser um valor inteiro. Informe o código.');
        return false;
      end if;
      
      if p_vo.clausula_2 = 'CODFORNE' and not is_integer(p_vo.clausula_4) then
        template_site.erro('Valor inválido para "Fornecedor do produto". Deve ser um valor inteiro. Informe o código.');
        return false;
      end if;
      
      if p_vo.clausula_2 = 'CODSITPROD' then
        begin
          select * 
          into   t_parametros
          from   web_respparam 
          where  codparam = 205 
          and    resposta = p_vo.clausula_4;
        exception
          when others then
            template_site.erro('Valor inválido para "Atributo do produto". Tem que estar na lista de atributos comercializados pelo site. Verifique os cadastros de parâmetros, código 205.');
            return false;
        end;
      end if;
      
      if p_vo.clausula_2 = 'CODPROD' and not is_integer(p_vo.clausula_4) then
        template_site.erro('Valor inválido para "Código do produto". Deve ser um valor inteiro.');
        return false;
      end if;
      
      if p_vo.clausula_2 = 'CODITPROD' and not is_integer(p_vo.clausula_4) then
        template_site.erro('Valor inválido para "Código do item". Deve ser um valor inteiro.');
        return false;
      end if;
      
      if p_vo.clausula_2 = 'ESTADO' and not is_uppercase(p_vo.clausula_4) then
        template_site.erro('Valor inválido para "UF do cliente". Deve estar em maiúsculo em sem acento.');
        return false;
      end if;
      
      if p_vo.clausula_2 = 'CIDADE' and not is_uppercase(p_vo.clausula_4) then
        template_site.erro('Valor inválido para "Cidade do cliente". Deve estar em maiúsculo em sem acento.');
        return false;
      end if;
      
      if p_vo.clausula_2 = 'CEP' and not is_integer(p_vo.clausula_4) then
        template_site.erro('Valor inválido para "CEP do item". Deve ser um valor inteiro. Sem hífen.');
        return false;
      end if;
      
      if p_vo.clausula_2 = 'DTNASC' and not is_date(p_vo.clausula_4) then
        template_site.erro('Valor inválido para "Data de nascimento do cliente". Deve ser no formato DD/MM/AAAA.');
        return false;
      end if;
      
      if p_vo.clausula_2 = 'DTCADASTRO' and not is_date(p_vo.clausula_4) then
        template_site.erro('Valor inválido para "Data de cadastro do cliente". Deve ser no formato DD/MM/AAAA.');
        return false;
      end if;
      
      if p_vo.clausula_2 = 'SEXO' and p_vo.clausula_4 not in ('M','F') then
        template_site.erro('Valor inválido para "Sexo do cliente". Deve ser "M" ou "F".');
        return false;
      end if;
      
      if p_vo.clausula_2 = 'QTDCOMPRAS' and not is_integer(p_vo.clausula_4) then
        template_site.erro('Valor inválido para "Quantidade de compras do cliente". Deve ser um valor inteiro.');
        return false;
      end if;
      
    when 2 then
      
      if p_vo.clausula_1 is null then
        template_site.erro('Favor informar a cláusula 1!');
        return false;
      end if;
      
      if p_vo.clausula_2 is null then
        template_site.erro('Favor informar a cláusula 2!');
        return false;
      end if;
      
      if not is_number(p_vo.clausula_2) then
        template_site.erro('Valor inválido para "Cláusula 2". Deve ser um valor numérico.');
        return false;
      end if;
      
      if p_vo.clausula_3 is null then
        template_site.erro('Favor informar a cláusula 3!');
        return false;
      end if;
            
    else
      
      template_site.erro('Tipo de regra inválida!');
      return false;
      
    end case;
    
    return true;
    
  end valida;
  
  -----------
  
  procedure update_filhos ( p_vo in web_cupom_regra_vo ) is
  begin
    
    update web_cupom_regras
    set    id_regra_pai = p_vo.id_regra
    where  id_regra_pai = p_vo.id_regra_pai
    and    id_regra    != p_vo.id_regra;
    
  end update_filhos;
  
  -----------
  
  procedure servlet 
  ( p_id_regra       in number   default null
  , p_id_regra_pai   in number   default null
  , p_id_cupom       in number   default null
  , p_tipo_regra     in number   default null
  , p_clausula_1     in varchar2 default null
  , p_clausula_2     in varchar2 default null
  , p_clausula_3     in varchar2 default null
  , p_clausula_4     in varchar2 default null
  , z_action         in varchar2 default null
  ) is
    
    v_vo web_cupom_regra_vo;
    
  begin
    
    v_vo.id_regra       := p_id_regra;
    v_vo.id_regra_pai   := p_id_regra_pai;
    v_vo.id_cupom       := p_id_cupom;
    v_vo.tipo_regra     := p_tipo_regra;
    v_vo.clausula_1     := p_clausula_1;
    v_vo.clausula_2     := p_clausula_2;
    v_vo.clausula_3     := p_clausula_3;
    v_vo.clausula_4     := p_clausula_4;
    
    if not pkg_web_cupom_regras.valida(v_vo) then
      return;
    end if;
    
    if z_action = 'Salvar Alterações' then
      if v_vo.id_regra is null then
        
        v_vo.id_regra := pkg_web_cupom_regras.get_next_id();
        
        pkg_web_cupom_regras.insere(v_vo);
        
        update_filhos(v_vo);
        
      else
        
        pkg_web_cupom_regras.altera(v_vo);
        
      end if;      
    end if;
    
    htp.script('
      alert("Operação realizada com sucesso!");
      location.href="pkg_web_cupom_regras.startup?p_id_cupom=' || p_id_cupom || '";
    ');
    
  end servlet;
  
  -----------
  
begin
  
  for i in cur_tppgtos loop
    arr_clausula_24.extend;
    arr_clausula_24(arr_clausula_24.count) := i.tppgto || '||' || i.descricao;
  end loop;
  
end pkg_web_cupom_regras;
/
