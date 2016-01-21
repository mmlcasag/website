create or replace package body pkg_web_cupom is
  
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
  arr_status util.tarray := util.tarray('0||Selecione','1||Ativo','9||Desativado');
  -----------
  
  g_img_editar  varchar2(300) := 'http://intranet.colombo.com.br:7777/portal/img/editar.gif';
  g_img_regras  varchar2(300) := 'http://intranet.colombo.com.br:7777/lvirtual/imagens/ico_checklist.gif';
  
  -----------
  
  function get_next_id return number is
    
    v_id web_cupom.id%type;
    
  begin
    
    select nvl(max(id),0) + 1 into v_id from web_cupom;
    
    return v_id;
    
  end get_next_id;
  
  -----------
  
  function get_desc_status ( p_status in number ) return varchar2 is
    
    v_status varchar2(50);
    
  begin
    
    select decode(p_status, 0, 'Selecione', 1, 'Ativo', 9, 'Desativado') into v_status from dual;
    
    return v_status;
    
  end get_desc_status;
  
  -----------
  
  function get_desc_simnao ( p_status in number ) return varchar2 is
    
    v_status varchar2(50);
    
  begin
    
    select decode(p_status, 0, 'Não', 1, 'Sim') into v_status from dual;
    
    return v_status;
    
  end get_desc_simnao;
  
  -----------
  
  procedure insere ( p_vo in web_cupom_vo ) is
  begin
    
    insert into web_cupom
      ( id
      , descricao
      , codigo
      , status
      , limite_total
      , limite_cliente
      , dtvalini
      , dtvalfim
      )
    values
      ( p_vo.id
      , p_vo.descricao
      , p_vo.codigo
      , p_vo.status
      , p_vo.limite_total
      , p_vo.limite_cliente
      , p_vo.dtvalini
      , p_vo.dtvalfim
    ) ;
    
  end insere;
  
  -----------
  
  procedure altera ( p_vo in web_cupom_vo ) is
  begin
    
    update web_cupom
    set    descricao      = p_vo.descricao
    ,      codigo         = p_vo.codigo
    ,      status         = p_vo.status
    ,      limite_total   = p_vo.limite_total
    ,      limite_cliente = p_vo.limite_cliente
    ,      dtvalini       = p_vo.dtvalini
    ,      dtvalfim       = p_vo.dtvalfim
    where  id             = p_vo.id;
    
  end altera;
  
  -----------
  
  procedure exclui ( p_vo in web_cupom_vo ) is
  begin
    
    delete web_cupom
    where  id      = p_vo.id;
    
  end exclui;
  
  -----------
  
  function seleciona ( p_vo in web_cupom_vo ) return array_web_cupom_vo is
    
    cr        sys_refcursor;
    cr_sql    long;
    
    v_vo      web_cupom_vo;
    v_array   array_web_cupom_vo;
    
    n_cont    number := 0;
    
  begin
    
    cr_sql := ' select cp.id, cp.descricao, cp.codigo, cp.status, cp.limite_total, cp.limite_cliente, cp.dtvalini, cp.dtvalfim
                from   web_cupom cp
                where  1 = 1 ';
    
    if p_vo.id is not null then
      cr_sql := cr_sql || ' and cp.id = ' || p_vo.id;
    end if;
    
    if p_vo.descricao is not null then
      cr_sql := cr_sql || ' and lower(cp.descricao) like ' || '''%' || lower(p_vo.descricao) || '%''';
    end if;
    
    if p_vo.codigo is not null then
      cr_sql := cr_sql || ' and lower(cp.codigo) like ' || '''%' || p_vo.codigo || '%''';
    end if;
    
    if nvl(p_vo.status,0) <> 0 then
      cr_sql := cr_sql || ' and cp.status = ' || p_vo.status;
    end if;
    
    if p_vo.limite_total is not null then
      cr_sql := cr_sql || ' and cp.limite_total = ' || p_vo.limite_total;
    end if;
    
    if p_vo.limite_cliente is not null then
      cr_sql := cr_sql || ' and cp.limite_cliente = ' || p_vo.limite_cliente;
    end if;
    
    if p_vo.dtvalini is not null then
      cr_sql := cr_sql || ' and cp.dtvalini >= ' || '''' || p_vo.dtvalini || '''';
    end if;
    
    if p_vo.dtvalfim is not null then
      cr_sql := cr_sql || ' and cp.dtvalfim <= ' || '''' || p_vo.dtvalfim || '''';
    end if;
    
    cr_sql := cr_sql || ' order by cp.id ';
    
    open cr for cr_sql;
    loop
      fetch cr into v_vo.id, v_vo.descricao, v_vo.codigo, v_vo.status, v_vo.limite_total, v_vo.limite_cliente, v_vo.dtvalini, v_vo.dtvalfim;
      exit when cr%notfound;
      
      n_cont := n_cont + 1;
      
      v_array(n_cont).id             := v_vo.id;
      v_array(n_cont).descricao      := v_vo.descricao;
      v_array(n_cont).codigo         := v_vo.codigo;
      v_array(n_cont).status         := v_vo.status;
      v_array(n_cont).limite_total   := v_vo.limite_total;
      v_array(n_cont).limite_cliente := v_vo.limite_cliente;
      v_array(n_cont).dtvalini       := v_vo.dtvalini;
      v_array(n_cont).dtvalfim       := v_vo.dtvalfim;
      
    end loop;
    close cr;
    
    return v_array;
    
  end seleciona;
  
  -----------
  
  function carrega ( p_id in number ) return web_cupom_vo is
    
    v_vo web_cupom_vo;
    
  begin
    
    select cp.id, cp.descricao, cp.codigo, cp.status, cp.limite_total, cp.limite_cliente, cp.dtvalini, cp.dtvalfim
    into   v_vo.id, v_vo.descricao, v_vo.codigo, v_vo.status, v_vo.limite_total, v_vo.limite_cliente, v_vo.dtvalini, v_vo.dtvalfim
    from   web_cupom cp
    where  cp.id = p_id;
    
    return v_vo;
    
  end carrega;
  
  -----------
  
  procedure startup 
  ( p_id             in number   default null
  , p_descricao      in varchar2 default null
  , p_codigo         in varchar2 default null
  , p_status         in number   default null
  , p_limite_total   in number   default null
  , p_limite_cliente in number   default null
  , p_dtvalini       in date     default null
  , p_dtvalfim       in date     default null
  , z_action         in varchar2 default null
  ) is
    
    v_vo       web_cupom_vo;
    v_array_vo array_web_cupom_vo;
    
  begin
    
    template_site.pageopen('Central de Descontos', null, p_menu, p_link, p_dest);
    
    template_site.filtroopen('Filtros', '', 'pkg_web_cupom.startup');
      template_site.filtrorow('Id', template_site.formnumber('p_id', 10, false, p_id));
      template_site.filtrorow('Código', htf.formtext('p_codigo', 20, 20, p_codigo));
      template_site.filtrorow('Descrição', htf.formtext('p_descricao', 60, 100, p_descricao));
      template_site.filtrorow('Status', template.formcombo('p_status', arr_status, p_status));
      template_site.filtrorow('Limite de Uso (Total)', template_site.formnumber('p_limite_total', 10, false, p_limite_total));
      template_site.filtrorow('Limite de Uso (por Cliente)', template_site.formnumber('p_limite_cliente', 10, false, p_limite_cliente));
      template_site.filtrorow('Validade (Inicial)', template_site.formdate('p_dtvalini', p_dtvalini));
      template_site.filtrorow('Validade (Final)', template_site.formdate('p_dtvalfim', p_dtvalfim));
      template_site.filtrobotoes(util.tarray(htf.formsubmit('z_action', 'Consultar Registros')));
    template_site.filtroclose;
    
    v_vo.id             := p_id;
    v_vo.descricao      := p_descricao;
    v_vo.codigo         := p_codigo;
    v_vo.status         := p_status;
    v_vo.limite_total   := p_limite_total;
    v_vo.limite_cliente := p_limite_cliente;
    v_vo.dtvalini       := p_dtvalini;
    v_vo.dtvalfim       := p_dtvalfim;
    v_array_vo          := pkg_web_cupom.seleciona(v_vo);
    
    htp.br;
    
    template_site.tableopen(util.tarray('Id', 'Código', 'Descrição', 'Status', 'Limite de Uso (Total)', 'Limite de Uso (por Cliente)', 'Validade (Inicial)', 'Validade (Final)', '', ''));
    
    if v_array_vo.count > 0 then
      for i in v_array_vo.first..v_array_vo.last loop
        template_site.row(util.tarray
        ( v_array_vo(i).id                                    || '||align="right"'
        , v_array_vo(i).codigo                                || '||align="left"'
        , v_array_vo(i).descricao                             || '||align="left"'
        , pkg_web_cupom.get_desc_status(v_array_vo(i).status) || '||align="center"'
        , v_array_vo(i).limite_total                          || '||align="right"'
        , v_array_vo(i).limite_cliente                        || '||align="right"'
        , to_char(v_array_vo(i).dtvalini,'dd/mm/yyyy')        || '||align="right"'
        , to_char(v_array_vo(i).dtvalfim,'dd/mm/yyyy')        || '||align="right"'
        , htf.anchor('pkg_web_cupom.formulario?p_id=' || v_array_vo(i).id, htf.img(g_img_editar)) || '||align="right"'
        , htf.anchor('pkg_web_cupom_regras.startup?p_id_cupom=' || v_array_vo(i).id, htf.img(g_img_regras, cattributes => 'width="20"')) || '||align="center"'
        ) ) ;
      end loop;
    end if;
    
    template_site.tableclose;
    
    htp.br;
    htp.p(template_site.formbutton('Incluir Novo Registro', p_others => 'onclick="location.href=''pkg_web_cupom.formulario''"'));
    htp.br;
    
    template_site.pageclose;
    
  end startup;
  
  -----------
  
  procedure formulario 
  ( p_id        in number   default null
  ) is
    
    v_vo web_cupom_vo;
    
  begin
    
    begin
      v_vo := pkg_web_cupom.carrega(p_id);
    exception
      when others then
        v_vo := null;
    end;
    
    template_site.pageopen('Central de Descontos', null, p_menu, p_link, p_dest);
    
    template_site.filtroopen('Filtros', '', 'pkg_web_cupom.servlet');
      template_site.filtrorow('Id', template_site.formnumber('p_id', 10, false, v_vo.id, 'readonly="readonly"'));
      template_site.filtrorow('Código', htf.formtext('p_codigo', 20, 20, v_vo.codigo));
      template_site.filtrorow('Descrição', htf.formtext('p_descricao', 60, 100, v_vo.descricao));
      template_site.filtrorow('Status', template.formcombo('p_status', arr_status, v_vo.status));
      template_site.filtrorow('Limite de Uso (Total)', template_site.formnumber('p_limite_total', 10, false, v_vo.limite_total));
      template_site.filtrorow('Limite de Uso (por Cliente)', template_site.formnumber('p_limite_cliente', 10, false, v_vo.limite_cliente));
      template_site.filtrorow('Validade (Inicial)', template_site.formdate('p_dtvalini', v_vo.dtvalini));
      template_site.filtrorow('Validade (Final)', template_site.formdate('p_dtvalfim', v_vo.dtvalfim));
      template_site.filtrobotoes(util.tarray(htf.formsubmit('z_action', 'Salvar Alterações')));
    template_site.filtroclose;
    
    template_site.pageclose;
    
  end formulario;
  
  -----------
  
  procedure valida ( p_vo in web_cupom_vo ) is
    
    t_cupom web_cupom%rowtype;
    
  begin
    
    if p_vo.codigo is null then
      raise_application_error(-20000, 'Favor informar o código!');
    end if;
    
    if p_vo.descricao is null then
      raise_application_error(-20000, 'Favor informar a descrição!');
    end if;
    
    if nvl(p_vo.status,0) = 0 then
      raise_application_error(-20000, 'Favor informar o status!');
    end if;
    
    if p_vo.limite_total is null then
      raise_application_error(-20000, 'Favor informar o limite de uso total!');
    end if;
    
    if p_vo.limite_cliente is null then
      raise_application_error(-20000, 'Favor informar o limite de uso por cliente!');
    end if;
    
    if p_vo.id is not null then
      
      select * 
      into   t_cupom
      from   web_cupom 
      where  id = p_vo.id;
      
      if p_vo.codigo <> t_cupom.codigo then
        raise_application_error(-20000, 'Código do cupom não pode ser alterado!');
      end if;
      
      if p_vo.limite_total < t_cupom.limite_total then
        raise_application_error(-20000, 'Limite total do cupom não pode ser inferior ao que é atualmente!');
      end if;
      
      if p_vo.limite_cliente < t_cupom.limite_cliente then
        raise_application_error(-20000, 'Limite por cliente do cupom não pode ser inferior ao que é atualmente!');
      end if;
      
    end if;
    
  end valida;
  
  -----------
  
  procedure servlet 
  ( p_id             in number   default null
  , p_descricao      in varchar2 default null
  , p_codigo         in varchar2 default null
  , p_status         in number   default null
  , p_limite_total   in number   default null
  , p_limite_cliente in number   default null
  , p_dtvalini       in date     default null
  , p_dtvalfim       in date     default null
  , z_action         in varchar2 default null
  ) is
    
    v_vo web_cupom_vo;
    
  begin
    
    v_vo.id             := p_id;
    v_vo.descricao      := p_descricao;
    v_vo.codigo         := p_codigo;
    v_vo.status         := p_status;
    v_vo.limite_total   := p_limite_total;
    v_vo.limite_cliente := p_limite_cliente;
    v_vo.dtvalini       := p_dtvalini;
    v_vo.dtvalfim       := p_dtvalfim;
    
    begin
      pkg_web_cupom.valida(v_vo);
    exception
      when others then
        template_site.erro(sqlerrm);
        return;
    end;
    
    if z_action = 'Salvar Alterações' then
      
      if v_vo.id is null then
        
        v_vo.id := pkg_web_cupom.get_next_id();
        
        pkg_web_cupom.insere(v_vo);
        
      else
        
        pkg_web_cupom.altera(v_vo);
        
      end if;
      
    elsif z_action = 'Excluir Registro' then
      
      pkg_web_cupom.exclui(v_vo);
      
    end if;
    
    htp.script('
      alert("Operação realizada com sucesso!");
      location.href="pkg_web_cupom.startup";
    ');
    
  end servlet;
  
  -----------
  
  procedure utiliza_cupom_desconto
  ( p_num_cupom   in varchar2
  , p_cod_cliente in number
  , p_retorno    out varchar2
  ) is
    
    b_erro           boolean := false;
    v_mensagem       varchar2(200);
    
    t_cupom          web_cupom%rowtype;
    t_cliente        web_usuarios%rowtype;
    
    n_utilizado_cliente number := 0;
    
  begin
    
    if not b_erro then
      begin
        select * 
        into   t_cupom
        from   web_cupom
        where  codigo = p_num_cupom;
      exception
        when others then
          b_erro := true;
          v_mensagem := 'Número do cupom informado não foi encontrado!';
      end;
    end if;
    
    if not b_erro and t_cupom.status = 9 then
      b_erro := true;
      v_mensagem := 'Cupom informado está cancelado!';
    end if;
    
    if not b_erro and t_cupom.limite_total <= 0 then
      b_erro := true;
      v_mensagem := 'Cupom informado não possui limite total disponível!';
    end if;
    
    if not b_erro then
      begin
        select *
        into   t_cliente
        from   web_usuarios
        where  codclilv = p_cod_cliente;
      exception
        when others then
          b_erro := true;
          v_mensagem := 'Cliente informado não foi encontrado!';
      end;
    end if;
    
    if not b_erro then
      begin
        select count(*)
        into   n_utilizado_cliente
        from   web_cupom_utilizacoes
        where  codigo = p_num_cupom
        and    codclilv = p_cod_cliente;
      exception
        when others then
          n_utilizado_cliente := 0;
      end;
    end if;
    
    if t_cupom.limite_cliente <= n_utilizado_cliente then
      b_erro := true;
      v_mensagem := 'Cliente já utilizou o limite máximo definido por cliente para este cupom!';
    end if;
    
    if not b_erro then
      begin
        insert into web_cupom_utilizacoes
          ( id
          , codigo
          , codclilv
          )
        values
          ( ( select nvl(max(id),0) + 1 from web_cupom_utilizacoes )
          , p_num_cupom
          , p_cod_cliente
        ) ;
      exception
        when others then
          b_erro := true;
          v_mensagem := substr(sqlerrm,1,100);
      end;
    end if;
    
    if not b_erro then
      commit;
      p_retorno := 'S';
    else
      rollback;
      p_retorno := 'N' || v_mensagem;
    end if;
    
  end utiliza_cupom_desconto;
  
  -----------
  
end pkg_web_cupom;
/
