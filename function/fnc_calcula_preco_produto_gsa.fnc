create or replace
FUNCTION           "FNC_CALCULA_PRECO_PRODUTO_GSA" (p_produto in number) RETURN number AS
  v_preco  web_prod_preco.preco%type;
BEGIN

  select nvl((select pre.preco
              from web_prod_preco pre, web_campanhas_preco cp
              where sysdate between pre.dt_inicio and pre.dt_fim
                and pre.codprod = pr.codprod
                and cp.cpr_id = pre.promocao
                and pre.cpd_flativo = 'S'
                and pre.codfil = WEBSITE.fnc_retorna_parametro('GERAIS','LOJA PADRAO')
                and cp.cpr_fl_ativo = 'S'
                and pre.dt_alteracao = (select max(dt_alteracao)
                                         from web_prod_preco pre2, web_campanhas_preco cp2
                                         where pre2.codprod = pre.codprod
                                          and pre2.promocao = cp2.cpr_id
                                          and pre2.codfil = pre.codfil
                                          and pre2.cpd_flativo = 'S'
                                          and cp2.cpr_fl_ativo = 'S'
                                          and sysdate between pre2.dt_inicio and pre2.dt_fim)),

              (select pre.preco from web_prod_preco pre
              where pre.codprod = pr.codprod
                and pre.promocao is null
                and pre.cpd_flativo = 'S'
                and pre.codfil = WEBSITE.fnc_retorna_parametro('GERAIS','LOJA PADRAO'))) as preco_boleto
              into v_preco
              from web_prod pr
             where pr.codprod = p_produto;

   return v_preco;

END FNC_CALCULA_PRECO_PRODUTO_GSA;