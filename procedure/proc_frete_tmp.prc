create or replace procedure proc_frete_tmp 
( p_cep              in number
, p_coditprod        in varchar2
, p_qtcomp           in varchar2
, p_vlnota           in number
, p_vlfrete         out number
, p_diasentregamin  out number
, p_diasentregamax  out number
, p_transp          out number
, p_listaCasamento   in number default null
, p_deposito         in number
, p_loja_livro       in number default null
, p_arr_vlfrete     out varchar2
, p_arr_diasmin     out varchar2
, p_arr_diasmax     out varchar2
, p_arr_transp      out varchar2
, p_arr_filiais     out varchar2
, p_retira_loja     out number
, p_vlrtelevendas    in varchar2 default null
, p_perfil           in number default 1
) is
  
  v_coditprod   varchar2(2000);
  v_qtcomp      varchar2(2000);
  arr_coditprod owa_util.ident_arr;
  arr_qtdcomp   owa_util.ident_arr;
  
  arr_vlfrete   owa_util.ident_arr;
  arr_diasmin   owa_util.ident_arr;
  arr_diasmax   owa_util.ident_arr;
  arr_transp    owa_util.ident_arr;
  arr_filiais   owa_util.ident_arr;
  
  v_aliquota    number := 0;
  v_vlrguia     number := 0;
  
  v_area_risco  cad_cep.area_risco%type;
  
begin
  
  -- temporario para nao fazer deploy e manter a aplicaÇõÇ¿o no ar sem deploy visando acompanhar problema de ClosedConnection
  
  v_coditprod := p_coditprod;
  v_qtcomp    := p_qtcomp;
  
  if nvl(p_loja_livro,0) > 0 then
    v_coditprod := '460199#';
    v_qtcomp    := '1#';
  end if;
  
  select nvl(area_risco,'N')
  into   v_area_risco
  from   cad_cep
  where  cep = p_cep;
  
  if v_area_risco = 'S' then
    raise_application_error(-20903, 'Erro, a area e de risco');
  end if;
  
  declare
    ind      number;
    v_number varchar2(50);
  begin
    ind := 0;
    loop
      v_number := util.cut(v_coditprod, '#', ind);  -- ALTERAR JUNTO COM SAIDA DO TEMPORARIO
      exit when v_number is null;
      
      arr_coditprod(arr_coditprod.count+1) := v_number;
      
      begin
        v_number := util.cut(v_qtcomp, '#', ind);
        arr_qtdcomp(arr_qtdcomp.count+1) := str2num(v_number);
      exception
        when others then
          raise_application_error(-20903, 'Erro na quantidade do item '||ind||' - '||v_number);
      end;
      
      ind := ind + 1;
    end loop;
    
    if arr_coditprod.count <> arr_qtdcomp.count then
      raise_application_error(-20903, 'Arrays de dados dos itens diferentes');
    end if;
    
    if arr_coditprod.count = 0 then
      raise_application_error(-20903, 'Array de itens em branco');
    end if;
    
  end;
  
  proc_calcula_frete_tmp(p_cep,
                     400,
                     arr_coditprod,
                     arr_qtdcomp,
                     p_vlnota,
                     p_vlfrete,
                     p_diasentregamin,
                     p_diasentregamax,
                     p_transp,
                     v_aliquota,
                     v_vlrguia,
                     p_listaCasamento,
                     p_deposito,
                     p_loja_livro,
                     false,
                     false,
                     arr_vlfrete,
                     arr_diasmin,
                     arr_diasmax,
                     arr_transp,
                     arr_filiais,
                     p_retira_loja,
                     p_vlrtelevendas,
                     p_perfil
                     );
  
  if arr_vlfrete.count > 0 then
    for i in arr_vlfrete.first..arr_vlfrete.last loop
      p_arr_vlfrete := p_arr_vlfrete || arr_vlfrete(i) || '#';
    end loop;
  end if;
  
  if arr_diasmin.count > 0 then
    for i in arr_diasmin.first..arr_diasmin.last loop
      p_arr_diasmin := p_arr_diasmin || arr_diasmin(i) || '#';
    end loop;
  end if;
  
  if arr_diasmax.count > 0 then
    for i in arr_diasmax.first..arr_diasmax.last loop
      p_arr_diasmax := p_arr_diasmax || arr_diasmax(i) || '#';
    end loop;
  end if;
  
  if arr_transp.count > 0 then
    for i in arr_transp.first..arr_transp.last loop
      p_arr_transp := p_arr_transp || arr_transp(i) || '#';
    end loop;
  end if;
  
  if arr_filiais.count > 0 then
    for i in arr_filiais.first..arr_filiais.last loop
      p_arr_filiais := p_arr_filiais || arr_filiais(i) || '#';
    end loop;
  end if;
  
  if nvl(p_listaCasamento,0) > 0 then
    p_vlfrete := 0;
  end if;
  
  if nvl(p_loja_livro, 0) > 0 then
    p_vlfrete := 0;
  end if;
  
end proc_frete_tmp;
/
