CREATE OR REPLACE PACKAGE BODY "UTIL"  as
  
  -- 27/08/2003 - Enor - Pacote com funcoes padrao para a intranet
  -- 04/06/2004 - Lucas - tipos criados ident_long e ident_extend e ident_arr com tamanho aumentado para 1000
  -- 15/06/2004 - Luca - novo parametro na funcao "to_curr", nvl, para exibir ou n?o valor para campo nulo
  
  /*********************************************************************************************************************/
  /* Variaveis globais para otimizar as func?es */
  v_user   varchar2(10) := null;
  v_codfil number       := null;
  /*********************************************************************************************************************/
  
  function cut(p_string varchar2, p_delimit varchar2, p_posicao number default 0) return varchar2 is
  begin
    if instr(p_string, p_delimit) = 0 then
      begin
        if p_posicao = 0 then
          return p_string;
        else
          return '';
        end if;
      end;
    elsif p_posicao < 0 then
      return substr(p_string, 1, instr(p_string, p_delimit, p_posicao));
    elsif p_posicao = 0 then
      return substr(p_string, 1, instr(p_string, p_delimit) - 1);
    else
      return cut(substr(p_string, instr(p_string, p_delimit) + length(p_delimit)), p_delimit, p_posicao - 1);
    end if;
  end;
  
  /*********************************************************************************************************************/
  
  function to_curr(p_valor number, do_nvl boolean default true) return varchar2 is
  begin
    if not do_nvl and p_valor is null then
      return null;
    else
      return trim(to_char(nvl(p_valor, 0), '999G999G999G990D00'));
    end if;
  end;

  /*********************************************************************************************************************/

  function to_number(p_valor number, do_nvl boolean default true) return varchar2 is
  begin
    if not do_nvl and p_valor is null then
      return null;
    else
      return trim(to_char(nvl(p_valor, 0), '999999999990D00'));
    end if;
  end;

  /*********************************************************************************************************************/

  function datediff(data1 date, data2 date) return varchar2 is
    days    number;
    hours   number;
    minutes number;
    seconds number;
    diff    number;
  begin
    diff    := data2 - data1;
    days    := floor(diff);
    diff    := mod(diff, 1);
    hours   := floor(diff * 24);
    diff    := mod(diff * 24, 1);
    minutes := floor(diff * 60);
    diff    := mod(diff * 60, 1);
    seconds := floor(diff * 60);
    return test(days > 0, days || ' dia(s) ') || trim(to_char(hours, '00')) || ':' || trim(to_char(minutes, '00')) || ':' || trim(to_char(seconds,
                                                                                                                                          '00'));
  end;

  /*********************************************************************************************************************/

  function test(condicion boolean, iftrue varchar2, iffalse varchar2 default null) return varchar2 is
  begin
    if condicion then
      return iftrue;
    else
      return iffalse;
    end if;
  end;

  /*********************************************************************************************************************/

  function test(condicion boolean, iftrue number, iffalse number default null) return number is
  begin
    if condicion then
      return iftrue;
    else
      return iffalse;
    end if;
  end;

  /*********************************************************************************************************************/

  function test(v_value varchar2, v_values util.tarray) return varchar2 is
  begin
    for li in v_values.first .. v_values.last loop
      if cut(v_values(li), '||', 0) = v_value or cut(v_values(li), '||', 0) is null and v_value is null then
        return cut(v_values(li), '||', 1);
        exit;
      end if;
    end loop;
    return null;
  end;
  
  /*********************************************************************************************************************/

  /* retorna true se o valor está preenchido conforme o tipo solicitado 
  * tipo:
  * 'num' verifica se o valor é um número válido, podendo conter dígitos, '.', ',', ignorando espaços
  * 'int' verifica se o valor é um inteiro válido, podendo conter somente dígitos, ignorando espaços
  * 'text' verifica se o valor tem algum texto informado, ignorando espaços
  */
  function testFill(tipo varchar2, vlr varchar2, permiteNull boolean default false) return boolean
  is
  saida boolean := false;
  begin
  if vlr is null then
    saida := permiteNull;
  else
    if 'num' = lower(substr(tipo, 1, 3)) then
      saida := owa_pattern.match(vlr, '^\s*\-?[0-9.,]+\s*$');
    elsif 'int' = lower(substr(tipo, 1, 3)) then
      saida := owa_pattern.match(vlr, '^\s*\-?\d+\s*$');
    elsif 'text' = lower(substr(tipo, 1, 4)) then
      saida := owa_pattern.match(vlr, '\S+');
    end if;
  end if;
  return saida;
  end;

  /*********************************************************************************************************************/

  -- localiza o índice de um determinado valor na lista. Retorna null se não encontrado
  function listIndex(v_vlr varchar2, v_lista owa_util.ident_arr) return number
  is
  saida number;
  begin
  if v_lista is not null then
    for i in v_lista.first .. v_lista.last loop
      if v_vlr = v_lista(i) then
        saida := i;
        exit;
      end if;
    end loop;
  end if;
  return saida;
  end;


  function listFind(v_vlr varchar2, v_lista owa_util.ident_arr) return boolean
  is
  begin
  return listIndex(v_vlr, v_lista) is not null;
  end;
  
  
  function listConcat(p_lista owa_util.ident_arr, p_sep varchar2 default ',', p_use_aspas boolean default false) return varchar2
  is
  saida varchar2(10000);
  begin
  if p_lista is not null then
    for i in p_lista.first .. p_lista.last loop
      if testFill('text', p_lista(i)) then
        if saida is null then
          saida := '';
        else
          saida := saida || p_sep;
        end if;
        if p_use_aspas then
          saida := saida || '''' || replace(p_lista(i), '''', '''''') || '''';
        else
          saida := saida || p_lista(i);
        end if;
      end if;
    end loop;
  end if;
  return saida;
  end;
  

  /*********************************************************************************************************************/

  function nl2br(p_string varchar2) return varchar2 is
  begin
    return replace(p_string, chr(13) || chr(10), htf.br);
  end;
  
  /*********************************************************************************************************************/

  function dayofweek(p_day char, p_extenso boolean default false) return varchar2 is
    days util.tarray := util.tarray('Domingo', 'Segunda', 'Terca', 'Quarta', 'Quinta', 'Sexta', 'Sabado');
  begin
    if p_day between '1' and '7' then
      return days(p_day) || util.test(p_extenso, '-Feira');
    else
      return null;
    end if;
  end;

  /*********************************************************************************************************************/

  function dayofweek(p_date date, p_extenso boolean default false) return varchar2 is
  begin
    return dayofweek(to_char(p_date, 'D'), p_extenso);
  end;

  /*********************************************************************************************************************/

  function val_acesso_user(p_tran_codigo in number) return boolean is
    v_aux number(1);
  begin
    /*
    if p_tran_codigo is null then
      return true;
    else
      select count(usu_username)
        into v_aux
        from classes_acessam_transacoes c, usuarios_pertencem_classes u
       where c.tran_codigo = p_tran_codigo and u.clus_nome = c.clus_nome and usu_username = util.get_user;
      return v_aux <> 0;
    end if;
  */
  return true;
  exception
    when others then
      return false;
  end;

  /*********************************************************************************************************************/

  function get_user return varchar2 is
    v_cookie owa_cookie.cookie;
  begin
    if v_user is null then
      v_cookie := owa_cookie.get('WEB_USERNAME');
      if v_cookie.num_vals > 0 then
        return upper(v_cookie.vals(1));
      else
        return null;
      end if;
    else
      return v_user;
    end if;
  exception
    when others then
      return null;
  end;


function get_user_ext return varchar2 
is
  v_user varchar2(255);
begin
  /*
  begin
    select nome into v_user from usuarios_sy where fun_pront = to_number(get_user);
  exception 
    when others then null;
  end;
  */
  v_user := get_user || test(v_user is null, '', ' - ' || v_user);
  return v_user;
end;


  /*********************************************************************************************************************/

  function add(old tarray, new tarray) return util.tarray is
    ret util.tarray := old;
  begin
    for li in 1..new.count loop
      ret.extend;
      ret(ret.count) := new(li);
    end loop;
    return ret;
  end;
  
  /* Retorna a descrição de um produto ou item produto */
  function get_prod_desc(p_cod_prod number default null, p_cod_itprod number default null) return varchar2 
  as
    saida varchar2(200) := '';
    d1 varchar2(100);
    d2 varchar2(100);
  begin
    if p_cod_itprod is not null then
      select trim(p.descricao), trim(it.especific), trim(it.cor)
        into saida, d1, d2
        from web_itprod it  inner join web_prod p on it.codprod = p.codprod
        where it.coditprod = p_cod_itprod;
      saida := trim(trim(saida || ' ' || d1) || ' ' || d2);
    elsif p_cod_prod is not null then
      select trim(p.descricao)
        into saida
        from web_prod p where p.codprod = p_cod_prod;
    end if;
    return saida;
  end;
  
  /* returna número se o texto informado for numero válido, senão retorna null */
  function num(txt varchar2) return number
  is
    saida number(12,4) := null;
  begin
    if testFill('num', txt) then
      saida := to_number(txt);
    end if;
    return saida;
  end;
  
end util;
/
