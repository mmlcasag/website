create or replace package body pkg_web_cupom_simulador is
  
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
  
  procedure startup is 
  begin
    
    template_site.pageopen('Central de Descontos: Simulador', null, p_menu, p_link, p_dest);
    
    htp.formopen('pkg_web_cupom_simulador.servlet');
    
    htp.tableopen(cattributes => 'align="center" border="0" cellspacing="1" cellpadding="4"');
      
      htp.tablerowopen;
        htp.tableheader('Nº do Pedido: ', cattributes => 'align="left"');
        htp.tabledata(template.formnumber('p_numpedven', 8, false, null), cattributes => 'align="left"');
      htp.tablerowclose;
      
      htp.tablerowopen;
        htp.tableheader('Código do Cupom: ', cattributes => 'align="left"');
        htp.tabledata(htf.formtext('p_numcupom', 20, 20, null), cattributes => 'align="left"');
      htp.tablerowclose;
      
    htp.tableclose;
    
    htp.br;
      htp.formsubmit(null, 'Efetuar Simulação');
    htp.br;
    
    htp.formclose;
    
    template_site.pageclose;
    
  end startup;
  
  -----------
  
  procedure servlet
  ( p_numpedven      in number 
  , p_numcupom       in varchar2
  ) is
    
    cursor cur_itens is
    select * 
    from   mov_itped
    where  numpedven = p_numpedven;
    
    b_erro             boolean := false;
    v_mensagem         varchar2(300);
    
    t_pedido           mov_pedido%rowtype;
    t_cliente          web_usuarios%rowtype;
    t_pedido_web       web_pedidos%rowtype;
    t_cad_endcli       web_usuarios_end%rowtype;
    t_cupom            web_cupom%rowtype;
    
    v_arr_coditprod    varchar2(300);
    v_arr_qtcomp       varchar2(300);
    v_arr_precounit    varchar2(300);
    v_arr_vldescitem   varchar2(300);
    
    v_tip_desc         varchar2(300);
    v_per_desc         number;
    v_vlr_desc         number;
    
    v_oper             char;
    v_texto            clob;
    
  begin
    
    if not b_erro and p_numpedven is null then
      b_erro := true;
      v_mensagem := 'Por favor, informe o número do pedido';
    end if;
    
    if not b_erro then
      begin
        select * 
        into   t_pedido
        from   mov_pedido 
        where  numpedven = p_numpedven;
      exception
        when others then
          b_erro := true;
          v_mensagem := 'Número do pedido informado é inválido';
      end;
    end if;
    
    if not b_erro and t_pedido.status in (7,8,9) then
      b_erro := true;
      v_mensagem := 'Pedido informado está com erro, devolvido ou foi cancelado';
    end if;
    
    if not b_erro then
      begin
        select *
        into   t_cliente
        from   web_usuarios 
        where  codcli_gemco = t_pedido.codcli;
      exception
        when others then
          b_erro := true;
          v_mensagem := 'Cliente do pedido é inválido';
      end;
    end if;
    
    if not b_erro then
      begin
        select * 
        into   t_pedido_web
        from   web_pedidos
        where  pedido = t_pedido.numpedven;
      exception
        when others then
          b_erro := true;
          v_mensagem := 'Número do pedido informado não é da loja web';
      end;
    end if;
    
    if not b_erro then
      begin
        select * 
        into   t_cad_endcli
        from   web_usuarios_end
        where  codclilv = t_cliente.codclilv
        and    codendlv = t_pedido.endent;
      exception
        when others then
          b_erro := true;
          v_mensagem := 'Não conseguiu carregar o endereço de entrega do cliente';
      end;
    end if;
    
    for i in cur_itens loop
      v_arr_coditprod  := v_arr_coditprod  || i.coditprod          || '#';
      v_arr_qtcomp     := v_arr_qtcomp     || (i.qtcomp     * 100) || '#';
      v_arr_precounit  := v_arr_precounit  || (i.precounit  * 100) || '#';
      v_arr_vldescitem := v_arr_vldescitem || (i.vldescitem * 100) || '#';
    end loop;
    
    if not b_erro and p_numcupom is null then
      b_erro := true;
      v_mensagem := 'Por favor, informe o número do cupom:';
    end if;
    
    if not b_erro then
      begin
        select * 
        into   t_cupom
        from   web_cupom
        where  codigo = p_numcupom;
      exception
        when others then
          b_erro := true;
          v_mensagem := 'Número do cupom informado é inválido:';
      end;
    end if;
    
    if not b_erro and t_cupom.status = 9 then
      b_erro := true;
      v_mensagem := 'Cupom informado está cancelado:';
    end if;
    
    if not b_erro then
      template_site.pageopen('Central de Descontos: Simulador', null, p_menu, p_link, p_dest);
      
      pkg_web_cupom_simulador.busca_desconto(t_cupom.codigo, t_pedido_web.forma_pagto, t_cad_endcli.cep, t_cliente.codclilv, t_cad_endcli.codendlv, v_arr_coditprod, v_arr_qtcomp, v_arr_precounit, v_arr_vldescitem, v_tip_desc, v_per_desc, v_vlr_desc, 'PEDIDO', 1);
      
      if v_tip_desc is not null then
        v_oper := 'S';
        v_texto := 'Esse cupom pôde ser aplicado ao pedido informado e gerou um desconto de ';
        
        if v_vlr_desc is not null then
          v_texto := v_texto || 'R$ ' || util.to_curr(v_vlr_desc);
        else
          v_texto := v_texto || util.to_curr(v_vlr_desc) || '%';
        end if;
        
        v_texto := v_texto || ' no valor do ';
        
        case v_tip_desc
          when 'DESCCARR' then v_texto := v_texto || 'carrinho';
          when 'DESCFRET' then v_texto := v_texto || 'frete';
        end case;
      else
        v_oper := 'E';
        v_texto := 'Esse cupom não pode ser aplicado ao pedido informado.' || htf.br || 'O pedido não atende aos requisitos dele.';
      end if;
      
      if v_oper = 'S' then
        htp.center(htf.fontopen(ccolor => '#008800') || v_texto || htf.fontclose);
      elsif v_oper = 'E' then
        htp.center(htf.fontopen(ccolor => '#FF0000') || v_texto || htf.fontclose);
      end if;
      
      template_site.pageclose;
    else
      template_site.erro(v_mensagem);
      return;
    end if;
    
  end servlet;
  
  -----------
  
  procedure carrega_enderecos_cliente
  ( p_cgccpf in number default null 
  ) is
    
    cursor cur_enderecos ( p_codclilv in number ) is
    select *
    from   web_usuarios_end
    where  codclilv = p_codclilv
    order  by codendlv;
    
    v_codclilv web_usuarios.codclilv%type;
    arr_codend util.tarray := util.tarray('' || '||' || 'Selecione');
    arr_codemp util.tarray := util.tarray('' || '||' || 'Selecione');
    
  begin
    
    select codclilv
    into   v_codclilv
    from   web_usuarios
    where  numcpf = p_cgccpf;
    
    for i in cur_enderecos (v_codclilv) loop
      arr_codend.extend;
      arr_codend(arr_codend.count) := i.codendlv || '||' || 'CEP ' || i.cep || ' ' || i.endereco || ', Nº ' || i.numero || ', BAIRRO ' || i.bairro || ', ' || i.cidade || ' / ' || i.uf;
    end loop;
    
    template.formcombo('p_codend', arr_codend, null, p_others => 'style="width: 600px;"');
    
  exception
    when others then
      template.formcombo('p_codend', arr_codemp, null, p_others => 'style="width: 600px;"');
  end carrega_enderecos_cliente;
  
  -----------
  
  procedure carrega_dados_produto
  ( p_coditprod in number default null 
  ) is
    
    n_qtcomp     number;
    v_descricao  varchar2(200);
    n_precounit  number;
    n_vldescitem number;
    
  begin
    
    if get_codproddf(p_coditprod) is not null then
      n_qtcomp     := 1;
      v_descricao  := f_ret_descricao(p_coditprod);
      n_precounit  := f_ret_precounit(400, p_coditprod);
      n_vldescitem := 0;
      
      htp.p(v_descricao || ';' || n_qtcomp || ';' || util.to_curr(n_precounit) || ';' || util.to_curr(n_vldescitem));
    end if;
    
  end carrega_dados_produto;
  
  -----------
  
  procedure startup_2 is
    
    cursor cur_forma_pagto is
    select t.tppgto, t.descricao
    from   web_plano p, web_tppgto t
    where  p.tppgto = t.tppgto
    order  by t.descricao;
    
    arr_forma_pagto util.tarray := util.tarray('' || '||' || 'Selecione');
    
    n_cont number := 0;
    
  begin
    
    for i in cur_forma_pagto loop
      arr_forma_pagto.extend;
      arr_forma_pagto(arr_forma_pagto.count) := i.tppgto || '||' || i.descricao;
    end loop;
    
    template_site.pageopen('Central de Descontos: Simulador', null, p_menu, p_link, p_dest);
    template_site.script_ajax_include;
    
    htp.script('
      function carregaEnderecosCliente() {
        var objParam        = new ajax.colombo.ParamRequest();
        objParam.url        = "pkg_web_cupom_simulador.carrega_enderecos_cliente";
        objParam.method     = "POST";
        objParam.paramPost  = "p_cgccpf=" + document.form.p_cgccpf.value;
        objParam.onFinished = function(data) {
          if (data != "") {
            document.getElementById("endcli").innerHTML = data;
          }
        }
        ajax.colombo.executeOnAjax(objParam);
      }
      
      function carregaDadosProduto(i) {
        var objPrm          = new ajax.colombo.ParamRequest();
        objPrm.url          = "pkg_web_cupom_simulador.carrega_dados_produto";
        objPrm.method       = "POST";
        objPrm.paramPost    = "p_coditprod=" + document.form.p_arr_coditprod[i].value;
        objPrm.onFinished   = function(data) {
          if (data != "") {
            var resultado = data.split(";");
            document.forms[0].p_arr_descricao[i].value  = resultado[0];
            document.forms[0].p_arr_qtcomp[i].value     = resultado[1];
            document.forms[0].p_arr_precounit[i].value  = resultado[2];
            document.forms[0].p_arr_vldescitem[i].value = resultado[3];
          }
        }
        ajax.colombo.executeOnAjax(objPrm);
      }
    ');
    
    htp.formopen('pkg_web_cupom_simulador.servlet_2', cattributes => 'name="form"');
    
    htp.tableopen(cattributes => 'align="center" border="0" cellspacing="1" cellpadding="4"');
      
      htp.tablerowopen;
        htp.tableheader('Código do Cupom: ', cattributes => 'align="left"');
        htp.tabledata(htf.formtext('p_numcupom', 20, 20, null), cattributes => 'align="left"');
      htp.tablerowclose;
      
      htp.tablerowopen;
        htp.tableheader('Forma de Pagamento: ', cattributes => 'align="left"');
        htp.tabledata(template.formcombo('p_forma_pagto', arr_forma_pagto, null), cattributes => 'align="left"');
      htp.tablerowclose;
      
      htp.tablerowopen;
        htp.tableheader('Número do CEP: ', cattributes => 'align="left"');
        htp.tabledata(template.formnumber('p_num_cep', 8, false, null), cattributes => 'align="left"');
      htp.tablerowclose;
      
      htp.tablerowopen;
        htp.tableheader('CPF/CNPJ do Cliente: ', cattributes => 'align="left"');
        htp.tabledata(template.formnumber('p_cgccpf', 14, false, null, 'onblur="carregaEnderecosCliente();"'), cattributes => 'align="left"');
      htp.tablerowclose;
      
      htp.tablerowopen;
        htp.tableheader('Endereço do Cliente: ', cattributes => 'align="left"');
        htp.tabledata('<span id="endcli"></div>', cattributes => 'align="left"');
      htp.tablerowclose;
      
    htp.tableclose;
    
    htp.br;
    
    htp.tableopen(cattributes => 'align="center" border="0" cellspacing="1" cellpadding="4"');
      
      htp.tablerowopen;
        htp.tableheader('Código Item'   , cattributes => 'align="center"');
        htp.tableheader('Descrição'     , cattributes => 'align="center"');
        htp.tableheader('Qtdade Item'   , cattributes => 'align="center"');
        htp.tableheader('R$ Unitário', cattributes => 'align="center"');
        htp.tableheader('R$ Desconto', cattributes => 'align="center"');
      htp.tablerowclose;
      
      for i in 1..5 loop
        htp.tablerowopen;
          htp.tabledata(template.formnumber('p_arr_coditprod' , 10, false, null, 'onblur="carregaDadosProduto('|| n_cont ||');"'), cattributes => 'align="center"');
          htp.tabledata(htf.formtext('p_arr_descricao', 80, 80, null, 'disabled="disabled"'), cattributes => 'align="center"');
          htp.tabledata(template.formnumber('p_arr_qtcomp'    , 10, true , null), cattributes => 'align="center"');
          htp.tabledata(template.formnumber('p_arr_precounit' , 10, true , null), cattributes => 'align="center"');
          htp.tabledata(template.formnumber('p_arr_vldescitem', 10, true , null), cattributes => 'align="center"');
        htp.tablerowclose;
        n_cont := n_cont + 1;
      end loop;
      
    htp.tableclose;
    
    htp.br;
      htp.formsubmit(null, 'Efetuar Simulação');
    htp.br;
    
    htp.formclose;
    
    template_site.pageclose;
    
    htp.script('
      carregaEnderecosCliente();
      document.form.reset();
    ');
    
  end startup_2;
  
  -----------
  
  procedure servlet_2
  ( p_numcupom       in varchar2 default null
  , p_forma_pagto    in number   default null
  , p_num_cep        in number   default null
  , p_cgccpf         in number   default null
  , p_codend         in number   default null
  , p_arr_coditprod  in owa_util.ident_arr default util.empty
  , p_arr_qtcomp     in owa_util.ident_arr default util.empty
  , p_arr_precounit  in owa_util.ident_arr default util.empty
  , p_arr_vldescitem in owa_util.ident_arr default util.empty
  ) is
    
    b_erro             boolean := false;
    v_mensagem         varchar2(300);
    
    t_cupom            web_cupom%rowtype;
    
    n_cont             number;
    n_codclilv         number;
    
    v_arr_coditprod    varchar2(300);
    v_arr_qtcomp       varchar2(300);
    v_arr_precounit    varchar2(300);
    v_arr_vldescitem   varchar2(300);
    
    v_tip_desc         varchar2(30);
    v_per_desc         number;
    v_vlr_desc         number;
    
    v_oper             char;
    v_texto            varchar2(300);
    
  begin
    
    if not b_erro and p_numcupom is null then
      b_erro := true;
      v_mensagem := 'Por favor, informe o número do cupom.';
    end if;
    
    if not b_erro then
      begin
        select * 
        into   t_cupom
        from   web_cupom
        where  codigo = p_numcupom;
      exception
        when others then
          b_erro := true;
          v_mensagem := 'Número do cupom informado é inválido.';
      end;
    end if;
    
    if not b_erro and t_cupom.status = 9 then
      b_erro := true;
      v_mensagem := 'Cupom informado está cancelado.';
    end if;
    
    if not b_erro and p_forma_pagto is null then
      b_erro := true;
      v_mensagem := 'Por favor, informe a forma de pagamento.';
    end if;
    
    if not b_erro and p_cgccpf is not null and p_codend is null then
      b_erro := true;
      v_mensagem := 'Por favor, quando você informa o CPF/CNPJ do cliente, é necessário que escolha o endereço de entrega também.';
    end if;
    
    if not b_erro and p_codend is not null and p_cgccpf is null then
      b_erro := true;
      v_mensagem := 'Por favor, quando você informa o endereço de entrega, é necessário que escolha o CPF/CNPJ do cliente também.';
    end if;
    
    -- Apenas se código do cliente for informado
    if not b_erro and p_cgccpf is not null then
      begin
        select codclilv
        into   n_codclilv
        from   web_usuarios
        where  numcpf = p_cgccpf;
      exception
        when others then
          b_erro := true;
          v_mensagem := 'Cliente informado é inválido.';
      end;
    end if;
    
    n_cont := 0;
    
    for i in p_arr_coditprod.first..p_arr_coditprod.last loop
      if get_codproddf(p_arr_coditprod(i)) is not null then
        n_cont := n_cont + 1;
        
        v_arr_coditprod  := v_arr_coditprod  || p_arr_coditprod(i)                          || '#';
        v_arr_qtcomp     := v_arr_qtcomp     || (replace(p_arr_qtcomp(i),'.','')     * 100) || '#';
        v_arr_precounit  := v_arr_precounit  || (replace(p_arr_precounit(i),'.','')  * 100) || '#';
        v_arr_vldescitem := v_arr_vldescitem || (replace(p_arr_vldescitem(i),'.','') * 100) || '#';
      end if;
    end loop;
    
    if not b_erro and n_cont = 0 then
      b_erro := true;
      v_mensagem := 'Informe o(s) produto(s) da venda.';
    end if;
    
    if not b_erro then
      template_site.pageopen('Central de Descontos: Simulador', null, p_menu, p_link, p_dest);
      
      pkg_web_cupom_simulador.busca_desconto(p_numcupom, p_forma_pagto, p_num_cep, n_codclilv, p_codend, v_arr_coditprod, v_arr_qtcomp, v_arr_precounit, v_arr_vldescitem, v_tip_desc, v_per_desc, v_vlr_desc, 'DADOS', 1);
      
      if v_tip_desc is not null then
        v_oper := 'S';
        v_texto := 'Esse cupom pôde ser aplicado ao pedido informado e gerou um desconto de ';
        
        if v_vlr_desc is not null then
          v_texto := v_texto || 'R$ ' || util.to_curr(v_vlr_desc);
        elsif v_per_desc is not null then
          v_texto := v_texto || util.to_curr(v_per_desc) || '%';
        end if;
        
        v_texto := v_texto || ' no valor do ';
        
        case v_tip_desc
          when 'DESCCARR' then v_texto := v_texto || 'carrinho.';
          when 'DESCFRET' then v_texto := v_texto || 'frete.';
        end case;
      else
        v_oper := 'E';
        v_texto := 'Esse cupom não pode ser aplicado ao pedido informado.' || htf.br || 'O pedido não atende aos requisitos dele.';
      end if;
      
      if v_oper = 'S' then
        htp.center(htf.fontopen(ccolor => '#008800') || v_texto || htf.fontclose);
      elsif v_oper = 'E' then
        htp.center(htf.fontopen(ccolor => '#FF0000') || v_texto || htf.fontclose);
      end if;
      
      template_site.pageclose;
    else
      template_site.erro(v_mensagem);
      return;
    end if;
    
  end servlet_2;
  
  -----------
  
  procedure busca_desconto
  ( p_numcupom       in varchar2
  , p_forma_pagto    in number   default null
  , p_num_cep        in number   default null
  , p_cod_cliente    in number   default null
  , p_cod_endcli     in number   default null
  , p_arr_coditprod  in varchar2 default null
  , p_arr_qtcomp     in varchar2 default null
  , p_arr_precounit  in varchar2 default null
  , p_arr_vldescitem in varchar2 default null
  , p_tip_desc      out varchar2 
  , p_per_desc      out number
  , p_vlr_desc      out number
  , p_caller         in varchar2 default null
  , p_debug          in number   default 0
  ) is
    
    cursor  cur_regras ( p_id_cupom in number ) is
    select  r.*
    ,       level
    from    web_cupom_regras r
    where   id_cupom = p_id_cupom
    start   with r.id_regra_pai is null
    connect by prior r.id_regra = r.id_regra_pai;
    
    b_erro         boolean := false;
    n_cont         number := 0;
    n_processa     number := 0;
    n_resultado    number := 0;
    n_retorno      number := 0;
    n_regra_ant    number := 0;
    n_vlmercad     number := 0;
    n_qtditens     number := 0;
    n_qtdprods     number := 0;
    n_qtdcompras   number;
    n_usd_cliente  number;
    
    v_cep          web_usuarios_end.cep%type;
    v_cidade       web_usuarios_end.cidade%type;
    v_estado       web_usuarios_end.uf%type;
    
    arr_coditprod  owa_util.ident_arr;
    arr_qtcomp     owa_util.ident_arr;
    arr_precounit  owa_util.ident_arr;
    arr_vldescitem owa_util.ident_arr;
    arr_codlinha   owa_util.ident_arr;
    arr_codfam     owa_util.ident_arr;
    arr_codgrupo   owa_util.ident_arr;
    arr_codforne   owa_util.ident_arr;
    arr_codsitprod owa_util.ident_arr;
    arr_codprod    owa_util.ident_arr;
    
    arr_regras     owa_util.ident_arr;
    
    t_cupom        web_cupom%rowtype;
    t_plano        web_plano%rowtype;
    t_cliente      web_usuarios%rowtype;
    
  begin
    
    if p_debug = 1 then
      htp.center(htf.bold('Validações')); htp.br;
    end if;
    
    if not b_erro then
      begin
        select * 
        into   t_cupom
        from   web_cupom
        where  codigo = p_numcupom;
        
        if p_debug = 1 then
          htp.center('Validando número do cupom: Cupom informado foi encontrado: OK');
        end if;
      exception
        when others then
          b_erro := true;
          if p_debug = 1 then
            htp.center('Validando número do cupom> Cupom informado não foi encontrado: ERRO');
          end if;
      end;
    end if;
    
    if not b_erro then
      if t_cupom.status = 9 then
        b_erro := true;
        if p_debug = 1 then
          htp.center('Validando status do cupom: Cupom está cancelado: ERRO');
        end if;
      else
        if p_debug = 1 then
          htp.center('Validando status do cupom: Cupom não está cancelado: OK');
        end if;
      end if;
    end if;
    
    if not b_erro then
      if t_cupom.dtvalini is not null then
        if t_cupom.dtvalini > trunc(sysdate) then
          b_erro := true;
          if p_debug = 1 then
            htp.center('Verificando validade do cupom: Validade inicial superior à data atual: ERRO');
          end if;
        else
          if p_debug = 1 then
            htp.center('Verificando validade do cupom: Validade inicial inferior à data atual: OK');
          end if;
        end if;
      end if;
    end if;
    
    if not b_erro then
      if t_cupom.dtvalfim is not null then
        if t_cupom.dtvalfim < trunc(sysdate) then
          b_erro := true;
          if p_debug = 1 then
            htp.center('Verificando validade do cupom: Validade final inferior à data atual: ERRO');
          end if;
        else
          if p_debug = 1 then
            htp.center('Verificando validade do cupom: Validade final superior à data atual: OK');
          end if;
        end if;
      end if;
    end if;
    
    if not b_erro then
      if t_cupom.limite_total <= 0 then
        b_erro := true;
        if p_debug = 1 then
          htp.center('Validando limite total do cupom: Cupom não possui limite disponível: ERRO');
        end if;
      else
        if p_debug = 1 then
          htp.center('Validando limite total do cupom: Cupom possui limite disponível: OK');
        end if;
      end if;
    end if;
    
    -- Apenas se forma de pagamento for informada
    if not b_erro and p_forma_pagto is not null then
      begin
        select * 
        into   t_plano
        from   web_plano
        where  tppgto = p_forma_pagto;
        
        if p_debug = 1 then
          htp.center('Validando forma de pagamento: Forma de pagamento encontrada: OK');
        end if;
      exception
        when others then
          b_erro := true;
          if p_debug = 1 then
            htp.center('Validando forma de pagamento: Forma de pagamento não encontrada: ERRO');
          end if;
      end;
    end if;
    
    -- Apenas se código do cliente for informado
    if not b_erro and p_cod_cliente is not null then
      begin
        select *
        into   t_cliente
        from   web_usuarios
        where  codclilv = p_cod_cliente;
        
        if p_debug = 1 then
          htp.center('Validando código do cliente: Cliente informado foi encontrado: OK');
        end if;
      exception
        when others then
          b_erro := true;
          if p_debug = 1 then
            htp.center('Validando código do cliente: Cliente informado não foi encontrado: ERRO');
          end if;
      end;
    end if;
    
    -- Apenas se código do cliente for informado
    if not b_erro and p_cod_cliente is not null then
      begin
        select cep, cidade, uf
        into   v_cep, v_cidade, v_estado
        from   web_usuarios_end
        where  codclilv = p_cod_cliente
        and    codendlv = nvl(p_cod_endcli,0);
        
        if p_debug = 1 then
          htp.center('Validando endereço do cliente: Endereço do cliente informado foi encontrado: OK');
        end if;
      exception
        when others then
          b_erro := true;
          if p_debug = 1 then
            htp.center('Validando endereço do cliente: Endereço do cliente informado não foi encontrado: OK');
          end if;
      end;
    end if;
    
    -- Apenas se número do cep for informado
    if not b_erro and p_num_cep is not null then
      begin
        select cep, local, uf
        into   v_cep, v_cidade, v_estado
        from   cad_cep
        where  cep = p_num_cep;
        
        if p_debug = 1 then
          htp.center('Validando CEP: CEP informado foi encontrado: OK');
        end if;
      exception
        when others then
          b_erro := true;
          if p_debug = 1 then
            htp.center('Validando CEP: CEP informado não foi encontrado: ERRO');
          end if;
      end;
    end if;
    
    -- Apenas se código do cliente for informado
    if not b_erro and p_cod_cliente is not null then
      begin
        select count(*)
        into   n_qtdcompras
        from   web_pedidosuser
        where  codclilv = t_cliente.codclilv
        and    dtcancela is null;
        
        if p_debug = 1 then
          htp.center('Validando histórico de compras do cliente: ' || to_char(n_qtdcompras) || ' compra(s) encontradas: OK');
        end if;
      exception
        when others then
          b_erro := true;
          if p_debug = 1 then
            htp.center('Validando histórico de compras do cliente: Não foi possível verificar as compras para o cliente: ERRO');
          end if;
      end;
    end if;
    
    -- Apenas se código do cliente for informado
    if not b_erro and p_cod_cliente is not null then
      begin
        select count(*)
        into   n_usd_cliente
        from   web_cupom_utilizacoes
        where  codigo = t_cupom.codigo
        and    codclilv = t_cliente.codclilv;
        
        if p_debug = 1 then
          htp.center('Validando quantidade de vezes que cliente utilizou este cupom de desconto: ' || n_usd_cliente || ': OK');
          htp.center('Validando limite de uso de cupom de desconto por cliente: ' || t_cupom.limite_cliente || ': OK');
        end if;
      exception
        when others then
          b_erro := true;
          if p_debug = 1 then
            htp.center('Validando quantidade de vezes que cliente utilizou este cupom de desconto: Não foi possível verificar: ERRO');
            htp.center('Validando limite de uso de cupom de desconto por cliente: ' || t_cupom.limite_cliente || ': OK');
          end if;
      end;
    end if;
    
    -- Apenas se código do cliente for informado
    if not b_erro and p_cod_cliente is not null then
      
      -- Teste feito quando simulação é feita por pedido, nesse caso não pode ser menor igual, deve ser menor, porque venda já existe
      if p_caller is not null and p_caller = 'PEDIDO' then
        
        if t_cupom.limite_cliente < n_usd_cliente then
          b_erro := true;
          if p_debug = 1 then
            htp.center('Validando limite por cliente do cupom: Cliente já atingiu o limite de uso para este cupom: ERRO');
          end if;
        else
          if p_debug = 1 then
            htp.center('Validando limite por cliente do cupom: Cliente ainda não atingiu o limite de uso para este cupom: OK');
          end if;
        end if;
        
      -- Teste feito quando simulação é feita digitando os dados da venda ou quando é feito pelo site mesmo, nesse caso deve ser menor igual, porque venda não existe
      elsif ( p_caller is not null and p_caller = 'DADOS' ) or p_caller is null then
        
        if t_cupom.limite_cliente <= n_usd_cliente then
          b_erro := true;
          if p_debug = 1 then
            htp.center('Validando limite por cliente do cupom: Cliente já atingiu o limite de uso para este cupom: ERRO');
          end if;
        else
          if p_debug = 1 then
            htp.center('Validando limite por cliente do cupom: Cliente ainda não atingiu o limite de uso para este cupom: OK');
          end if;
        end if;
        
      end if;
      
    end if;
    
    -- Apenas se array de produtos for informado
    if not b_erro and p_arr_coditprod is not null then
      
      if p_debug = 1 then
        htp.br;
        htp.center(htf.bold('Produtos'));
        htp.br;
      end if;
      
      begin
        arr_coditprod  := split(p_arr_coditprod,'#');
        arr_qtcomp     := split(p_arr_qtcomp,'#');
        arr_precounit  := split(p_arr_precounit,'#');
        arr_vldescitem := split(p_arr_vldescitem,'#');  
        
        for i in arr_coditprod.first..arr_coditprod.last loop
          select l.codlinha, f.codfam, g.codgrupo, p.codforne, i.codsitprod, p.codprod
          into   arr_codlinha(i), arr_codfam(i), arr_codgrupo(i), arr_codforne(i), arr_codsitprod(i), arr_codprod(i)
          from   web_itprod  i
          join   web_prod    p on p.codprod  = i.codprod
          join   web_grupo   g on g.codgrupo = p.codgrupo
          join   web_familia f on f.codfam   = g.codfam
          join   web_linha   l on l.codlinha = f.codlinha
          where  i.coditprod    = arr_coditprod(i);
          
          n_vlmercad := n_vlmercad + ( ( arr_precounit(i) / 100 ) - ( arr_vldescitem(i) / 100 ) ) * ( arr_qtcomp(i) / 100 );
          n_qtdprods := n_qtdprods + ( ( 1 ) );
          n_qtditens := n_qtditens + ( ( arr_qtcomp(i)    / 100 ) );
          
          if p_debug = 1 then
            htp.center('Item: ' || arr_coditprod(i) || ' Linha: ' || arr_codlinha(i) || ' Família: ' || arr_codfam(i) || ' Grupo: ' || arr_codgrupo(i) || ' Fornecedor: ' || arr_codforne(i) || ' Atributo: ' || arr_codsitprod(i) || ' Produto: ' || arr_codprod(i) || ' Qtdade: ' || (arr_qtcomp(i) / 100));
          end if;
        end loop;
        
        if p_debug = 1 then
          htp.br;
          htp.center('Valor total de mercadorias no carrinho: R$ ' || util.to_curr(n_vlmercad));
          htp.center('Quantidade total de produtos no carrinho: ' || to_char(n_qtditens));
          htp.center('Quantidade de produtos distintos no carrinho: ' || to_char(n_qtdprods));
        end if;
      exception
        when others then
          b_erro := true;
          if p_debug = 1 then
            htp.center('Validando itens da venda: ERRO - ' || sqlerrm);
          end if;
      end;
    end if;
    
    -- Se encontrou algum erro nas validações
    if b_erro then
      p_tip_desc := null;
      p_per_desc := null;
      p_vlr_desc := null;
      
      if p_debug = 1 then
        htp.br;
        htp.center(htf.bold('Resultado'));
        htp.br;
      end if;
      
      return;
    end if;
    
    -- Se não encontrou nenhum regra, começa a executar as regras
    if not b_erro then
      
      if p_debug = 1 then
        htp.br;
        htp.center(htf.bold('Regras'));
        htp.br;
      end if;
      
      for i in cur_regras (t_cupom.id) loop
        
        ---------------------------------------------------
        
        -- Quando tipo de regra mudou de CONDIÇÃO para INSTRUÇÃO
        if n_regra_ant in (0,1) and i.tipo_regra = 2 then
          n_cont := n_cont + 1;
          arr_regras(n_cont) := 'THEN';
          if p_debug = 1 then
            htp.center('TIPO DE REGRA mudou de CONDIÇÃO para INSTRUÇÃO');
          end if;
          
          -- Processa a regra
          n_processa := pkg_web_cupom_simulador.processa_regra(arr_regras);
          if p_debug = 1 then
            htp.center('Processando Regra: ' || util.test(n_processa = 1, 'PASSOU', 'NÃO PASSOU'));
          end if;
        end if;
        
        -- Quando tipo de regra mudou de INSTRUÇÃO para CONDIÇÃO
        if n_regra_ant = 2 and i.tipo_regra = 1 then
          n_cont := 0;
          arr_regras.delete;
          if p_debug = 1 then
            htp.center('TIPO DE REGRA mudou de INSTRUÇÃO para CONDIÇÃO');
          end if;
        end if;
        
        n_regra_ant := i.tipo_regra;
        
        ---------------------------------------------------
        
        -- CONDIÇÃO
        if i.tipo_regra = 1 then
          n_cont := n_cont + 1;
          arr_regras(n_cont) := i.clausula_1;
          
          case i.clausula_2
            when 'VLMERCAD' then
              n_cont := n_cont + 1;
              arr_regras(n_cont) := util.test(pkg_web_cupom_regras.ret_teste_clausula_13_number(n_vlmercad, i.clausula_3, i.clausula_4),1,0);
            when 'QTDITENS' then
              n_cont := n_cont + 1;
              arr_regras(n_cont) := util.test(pkg_web_cupom_regras.ret_teste_clausula_13_number(n_qtditens, i.clausula_3, i.clausula_4),1,0);
            when 'QTDPRODS' then
              n_cont := n_cont + 1;
              arr_regras(n_cont) := util.test(pkg_web_cupom_regras.ret_teste_clausula_13_number(n_qtdprods, i.clausula_3, i.clausula_4),1,0);
            when 'CODLINHA' then
              n_cont := n_cont + 1;
              arr_regras(n_cont) := util.test(pkg_web_cupom_regras.ret_teste_clausula_13_array(arr_codlinha, i.clausula_3, i.clausula_4),1,0);
            when 'CODFAM' then
              n_cont := n_cont + 1;
              arr_regras(n_cont) := util.test(pkg_web_cupom_regras.ret_teste_clausula_13_array(arr_codfam, i.clausula_3, i.clausula_4),1,0);
            when 'CODGRUPO' then
              n_cont := n_cont + 1;
              arr_regras(n_cont) := util.test(pkg_web_cupom_regras.ret_teste_clausula_13_array(arr_codgrupo, i.clausula_3, i.clausula_4),1,0);
            when 'CODFORNE' then
              n_cont := n_cont + 1;
              arr_regras(n_cont) := util.test(pkg_web_cupom_regras.ret_teste_clausula_13_array(arr_codforne, i.clausula_3, i.clausula_4),1,0);
            when 'CODSITPROD' then
              n_cont := n_cont + 1;
              arr_regras(n_cont) := util.test(pkg_web_cupom_regras.ret_teste_clausula_13_array(arr_codsitprod, i.clausula_3, i.clausula_4),1,0);
            when 'CODPROD' then
              n_cont := n_cont + 1;
              arr_regras(n_cont) := util.test(pkg_web_cupom_regras.ret_teste_clausula_13_array(arr_codprod, i.clausula_3, i.clausula_4),1,0);
            when 'CODITPROD' then
              n_cont := n_cont + 1;
              arr_regras(n_cont) := util.test(pkg_web_cupom_regras.ret_teste_clausula_13_array(arr_coditprod, i.clausula_3, i.clausula_4),1,0);
            when 'ESTADO' then
              n_cont := n_cont + 1;
              arr_regras(n_cont) := util.test(pkg_web_cupom_regras.ret_teste_clausula_13_varchar(v_estado, i.clausula_3, i.clausula_4),1,0);
            when 'CIDADE' then
              n_cont := n_cont + 1;
              arr_regras(n_cont) := util.test(pkg_web_cupom_regras.ret_teste_clausula_13_varchar(v_cidade, i.clausula_3, i.clausula_4),1,0);
            when 'CEP' then
              n_cont := n_cont + 1;
              arr_regras(n_cont) := util.test(pkg_web_cupom_regras.ret_teste_clausula_13_number(v_cep, i.clausula_3, i.clausula_4),1,0);
            when 'DTNASC' then
              n_cont := n_cont + 1;
              arr_regras(n_cont) := util.test(pkg_web_cupom_regras.ret_teste_clausula_13_date(t_cliente.dtnasc, i.clausula_3, to_date(i.clausula_4,'dd/mm/yyyy')),1,0);
            when 'DTCADASTRO' then
              n_cont := n_cont + 1;
              arr_regras(n_cont) := util.test(pkg_web_cupom_regras.ret_teste_clausula_13_date(t_cliente.dtcadast, i.clausula_3, to_date(i.clausula_4,'dd/mm/yyyy')),1,0);
            when 'SEXO' then
              n_cont := n_cont + 1;
              arr_regras(n_cont) := util.test(pkg_web_cupom_regras.ret_teste_clausula_13_varchar(t_cliente.sexo, i.clausula_3, i.clausula_4),1,0);
            when 'QTDCOMPRAS' then
              n_cont := n_cont + 1;
              arr_regras(n_cont) := util.test(pkg_web_cupom_regras.ret_teste_clausula_13_number(n_qtdcompras, i.clausula_3, i.clausula_4),1,0);
          end case;
          
          if p_debug = 1 then
            htp.center('Testando "' || upper(pkg_web_cupom_regras.get_desc_clausula_11(i.clausula_1)) || ' ' || lower(pkg_web_cupom_regras.get_desc_clausula_12(i.clausula_2)) || ' é ' || lower(pkg_web_cupom_regras.get_desc_clausula_13(i.clausula_3)) || ' a ' || i.clausula_4 || '": ' || util.test(arr_regras(n_cont) = 1, 'SIM', 'NÃO'));
          end if;
          
        -- CONDIÇÃO
        elsif i.tipo_regra = 2 then
          
          -- Processa a regra
          if n_processa = 1 then
            
            if i.clausula_4 is not null then
              if p_debug = 1 then
                htp.center('Testando se é feita alguma validação especial para diferentes formas de pagamento: SIM');
              end if;
              n_resultado := util.test(pkg_web_cupom_regras.ret_teste_clausula_13_number(t_plano.tppgto, '=', i.clausula_4),1,0);
              if p_debug = 1 then
                htp.center('Testando se forma de pagamento é igual a ' || i.clausula_4 || ': ' || util.test(n_resultado = 1, 'SIM', 'NÃO' || htf.br || 'Então reprocessando regra: NÃO PASSOU'));
              end if;
            else
              if p_debug = 1 then
                htp.center('Testando se é feita alguma validação especial para diferentes formas de pagamento: NÃO');
              end if;
              n_resultado := 1;
            end if;
            
            if n_resultado = 1 then
              if p_debug = 1 then
                htp.center('Fim dos testes, hora do resultado.');
              end if;
              
              if instr(i.clausula_2,',') > 0 or instr(i.clausula_2,'.') > 0 then
                n_retorno := to_number(replace(replace(i.clausula_2,',',''),'.','')) / 100;
              else
                n_retorno := to_number(i.clausula_2);
              end if;
              
              p_tip_desc := i.clausula_1;
              p_per_desc := util.test(i.clausula_3 = '%' , n_retorno, null);
              p_vlr_desc := util.test(i.clausula_3 = 'R$', n_retorno, null);
              
              if p_debug = 1 then
                htp.br;
                htp.center(htf.bold('Resultado'));
                htp.br;
                
                case p_tip_desc
                  when 'DESCCARR' then htp.center('Tipo do Desconto: no Carrinho');
                  when 'DESCFRET' then htp.center('Tipo do Desconto: no Frete');
                end case;
                
                if i.clausula_3 = '%' then
                  htp.center('Percentual de Desconto: ' || util.to_curr(n_retorno) || '%');
                end if;
                
                if i.clausula_3 = 'R$' then
                  htp.center('Valor de Desconto: R$ ' || util.to_curr(n_retorno));
                end if;
                
                htp.br;
                htp.center(htf.bold('Veredito'));
                htp.br;
              end if;
              
              return;
            end if;
            
          end if;
          
        end if;
        
      end loop;
      
    end if;
    
  end busca_desconto;
  
  -----------
  
  function processa_regra 
  ( p_arr_regras in owa_util.ident_arr 
  ) return number is
    
    n_cont number := 0;
    b_not  boolean := false;
    
    n_aux1 number ;
    n_ope  varchar2(200);
    n_aux2 number ;
    n_ret  number;
    
  begin
    
    -- Tratamento para casos de cupons sem cláusulas
    if p_arr_regras.count = 1 then
      return 1;
    end if;
    
    -- Tratamento para casos de um único teste
    if p_arr_regras.count = 3 then
      if p_arr_regras(1) like '%NOT%' then
        return util.test(p_arr_regras(2) = 0, 1, 0);
      else
        return p_arr_regras(2);
      end if;
    end if;
    
    for i in p_arr_regras.first..p_arr_regras.last loop
      
      if n_cont >= 4 then
        n_cont := 3;
        
        n_aux1 := n_ret;
        n_ope  := p_arr_regras(i);
        n_aux2 := null;
        
        if p_arr_regras(i) = 'THEN' then
          if b_not then
            return util.test(n_ret = 0, 1, 0);
          else
            return n_ret;
          end if;
        end if;
      else
        n_cont := n_cont + 1;
        
        case n_cont
        when 1 then
          if p_arr_regras(i) like '%NOT%' then
            b_not := true;
          end if;
        when 2 then
          n_aux1 := p_arr_regras(i);
        when 3 then
          n_ope := p_arr_regras(i);
        when 4 then
          n_aux2 := p_arr_regras(i);
        end case;
        
        if n_aux1 is not null and n_ope is not null and n_aux2 is not null then
          case n_ope
          when 'OR' then
            if n_aux1 = 1 or n_aux2 = 1 then
              n_ret := 1;
            else
              n_ret := 0;
            end if;
          when 'OR NOT' then
            if n_aux1 = 1 or n_aux2 = 1 then
              n_ret := 0;
            else
              n_ret := 1;
            end if;
          when 'AND' then
            if n_aux1 = 1 and n_aux2 = 1 then
              n_ret := 1;
            else
              n_ret := 0;
            end if;
          when 'AND NOT' then
            if n_aux1 = 1 and n_aux2 = 1 then
              n_ret := 0;
            else
              n_ret := 1;
            end if;
          end case;
        end if;
      end if;
      
    end loop;
    
    return util.test(b_not, 1, 0);
    
  end processa_regra;
  
  -----------
  
end pkg_web_cupom_simulador;
/
