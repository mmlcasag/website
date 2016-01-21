create or replace
FUNCTION           "FNC_CALCULA_PRECO_GSA" (p_codigo number default null, p_tp_produto varchar2 default 'P')
  RETURN number  IS

  cursor preco (p_produto number) is
                      select nvl((select pre.preco
                                      from web_prod_preco pre, web_campanhas_preco cp
                                      where sysdate between pre.dt_inicio and pre.dt_fim
                                        and pre.codprod = pr.codprod
                                        and cp.cpr_id = pre.promocao
                                        and pre.codfil = WEBSITE.fnc_retorna_parametro('GERAIS','LOJA PADRAO')
                                        and cp.cpr_fl_ativo = 'S'
                                        and pre.cpd_flativo = 'S'
                                        and pre.dt_alteracao = (select max(dt_alteracao)
                                                                 from web_prod_preco pre2, web_campanhas_preco cp2
                                                                 where pre2.codprod = pre.codprod
                                                                  and pre2.promocao = cp2.cpr_id
                                                                  and pre2.codfil = pre.codfil
                                                                  and cp2.cpr_fl_ativo = 'S'
                                                                  and pre2.cpd_flativo = 'S'
                                                                  and sysdate between pre2.dt_inicio and pre2.dt_fim)),

                                    (select pre.preco from web_prod_preco pre
                                    where pre.codprod = pr.codprod
                                      and pre.promocao is null
                                      and pre.cpd_flativo = 'S'
                                      and pre.codfil = WEBSITE.fnc_retorna_parametro('GERAIS','LOJA PADRAO'))) as preco_boleto
                          from web_prod pr
                         where pr.codprod = codprod;

  cursor itensAgregados (p_agregado number) is
                      select i.codprod
                      from web_itprod_venda_agregada a, web_itprod i
                      where pva_id = p_agregado
                        and a.itm_id_agregado = i.coditprod
                      union
                      select i.codprod
                      from web_prod_venda_agregada a, web_itprod i
                      where pva_id = p_agregado
                        and a.itm_id = i.coditprod;


  v_preco number := 0;

BEGIN
  if p_tp_produto = 'P' then
    v_preco := fnc_calcula_preco_produto_gsa(p_codigo);
  elsif  p_tp_produto = 'A' then
    -- busca os produtos que compoe o agregado
    select sum(fnc_calcula_preco_produto_gsa(codprod))
      into v_preco
     from ( select i.codprod
              from web_itprod_venda_agregada a, web_itprod i
              where pva_id = p_codigo
                and a.itm_id_agregado = i.coditprod
              union
              select i.codprod
              from web_prod_venda_agregada a, web_itprod i
              where pva_id = p_codigo
                and a.itm_id = i.coditprod ) agregados;

  elsif  p_tp_produto = 'B' then
      begin
       select preco into v_preco from web_itprod_brinde_parcelas where codbrinde = p_codigo and tppgto = 2 and codfil = 400;
      exception
        when no_data_found then
          v_preco := 0;
      end;
  end if;

  v_preco := nvl(v_preco,0);
  return v_preco;

END FNC_CALCULA_PRECO_GSA;