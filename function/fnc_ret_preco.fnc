create or replace
function website.fnc_ret_preco(p_item number, p_filial number, p_margem number,
                       p_plano varchar2, p_parcelas number, p_cep number,
                       p_desc_rebate number default 0, p_taxa number default null) return number as
  v_ret varchar2(500);
  v_taxabase number(15,4);
  v_taxa number(15,4);
  v_entrada web_tppgto.entrada%type;
  v_cartao varchar2(1);
  v_deposito number;
  v_preco number(15,2);
begin

  begin
    select f_deposito(p_cep) into v_deposito from dual;
  exception
    when others then
      v_deposito := null;
  end;

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
  
  -- se o juros for passado como parametro
  if (p_taxa is not null) then
     v_taxa := p_taxa;
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

  v_ret := f_ret_preco_venda_400_sy(p_item, p_filial, p_margem, v_cartao, 'N',
                                    p_parcelas, v_taxabase, v_taxa, v_entrada, v_deposito);
  v_preco := to_number(v_ret);

  return v_preco;
end;
/
