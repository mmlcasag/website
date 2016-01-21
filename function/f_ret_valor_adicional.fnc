create or replace function f_ret_valor_adicional
( pi_uf_orig     in varchar2
, pi_uf_destino  in varchar2
, pi_vltotalnota in number
) return number  is
  
  v_aliquota  number := 0;
  v_vlrlimite number := 0;
  
begin
  
  -- Busca na tabela de parâmetros. Caminho na intranet para cadastro: Fiscal/Cadastro Diferencial Alíquota
  begin
    select nvl(aliquota,0), nvl(vlrlimite, 0)
      into v_aliquota, v_vlrlimite
      from web_imptribut_frete
     where estorig = pi_uf_orig
       and estdest = pi_uf_destino
       and dtinicial <= trunc(sysdate)
       and dtfinal is null;
  exception
    when no_data_found then
      v_aliquota  := 0;
      v_vlrlimite := 0;
  end;
  
  -- mesma regra utilizada na proc de calculo do frete.
  if v_aliquota > 0 and pi_vltotalnota >= v_vlrlimite then
    return (pi_vltotalnota - v_vlrlimite) * v_aliquota / 100;
  else
    return 0;
  end if;
  
exception
  when others then
    send_mail('site-erros@colombo.com.br',
              'site-erros@colombo.com.br',
              'Erro no calculo do adicional de frete. Função f_ret_valor_adicional',
              'Parametros: ' || chr(13) || 
              'p_uf_orig: ' || pi_uf_orig || chr(13) || 
              'p_uf_destino: ' || pi_uf_destino || chr(13) ||
              'p_vltotalnota: ' || pi_vltotalnota || chr(13) || 
              'Erro: ' || sqlcode || '-' || sqlerrm || chr(13));
end f_ret_valor_adicional;
/
