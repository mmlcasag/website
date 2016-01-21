create or replace function fnc_retorna_parametro (p_grp_param in varchar2,
                                p_param in varchar2,
                                p_perfil in varchar2 default null) return varchar2 as

  v_resposta      web_respparam.resposta%type;
begin

  select resposta
    into v_resposta
    from web_respparam resp,
         web_parametros param,
         web_grpparam  grp
   where ((param.fl_perfil = 1 and resp.perfil = p_perfil) or param.fl_perfil = 0)
     and resp.codparam = param.codparam
     and grp.fl_ativo = 1
     and param.fl_ativo = 1
     and param.codgrpparam = grp.codgrpparam
     and lower(grp.descricao) = lower(p_grp_param)
     and lower(param.descricao) = lower(p_param);

  return v_resposta;

exception
  when no_data_found then
    return null;

end fnc_retorna_parametro;
