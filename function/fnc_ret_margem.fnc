create or replace
FUNCTION website.FNC_RET_MARGEM(p_item number, p_filial number, p_preco number,
                        p_plano varchar2, p_parcelas number, p_cep number,
                        p_desc_rebate number default 0,
                        p_juros number default null, p_deposito number default null) return number as
  v_ret varchar2(500);
  v_taxabase number(15,4);
  v_taxa number(15,4);
  v_entrada web_tppgto.entrada%type;
  v_cartao varchar2(1);
  v_deposito number;
  v_margem number(15,4);
begin

  begin
    select f_deposito(p_cep) into v_deposito from dual;
  exception
    when others then
      v_deposito := null;
  end;
  if (nvl(p_deposito,0) > 0 ) then
     v_deposito := p_deposito;
  end if;

  begin
    select a.taxa, b.entrada, decode(a.tppgto,1,'S','N')
      into v_taxa, v_entrada, v_cartao
      from web_plano a
     inner join web_tppgto b on a.tppgto = b.tppgto
     where a.codplano = p_plano;
  exception
    when others then
      v_taxa := 0;
      v_entrada := 'N';
      v_cartao := 'S';
  end;

  if (p_juros is not null) then
    v_taxa := p_juros;
  end if;

  begin
    select valor
      into v_taxabase
      from parametros_mensais_lojas
     where codfil = p_filial
       and cod_parametro = 201
       and mes = trunc(sysdate,'MM');
  exception
    when no_data_found then
      v_taxabase := 1;
  end;
  if p_desc_rebate > 0 and p_desc_rebate <= 1 then
    v_taxabase := v_taxabase - (v_taxabase * nvl(p_desc_rebate,0));
    v_taxa := 0; --taxa em branco senao o rebate nao funciona
  end if;

  v_ret := f_ret_margem_400_sy(p_item, p_filial, p_preco, v_cartao, 'N',
                                        p_parcelas, v_taxabase, v_taxa, v_entrada, v_deposito);
  v_margem := round(to_number(v_ret) * 100 / p_preco, 2);


  return v_margem;
end;
/
