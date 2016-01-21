create or replace
FUNCTION WEB_PRECO_ATIVO_PARCELA(p_codprod number default null, p_cpr_id number default null, p_portal number default null, p_origem number default 1, p_plano in varchar default null)
  RETURN tp_web_preco_ativo_parcela_tb PIPELINED IS

  cursor c1 is
    select ativos.codprod, ativos.preco_antigo, pl.codplano, pl.preco, pl.maior_parcela, pl.juros, pla.vlminparc
      from table(web_preco_ativo(p_codprod,p_cpr_id,p_portal,p_origem)) ativos, web_prod_preco_plano pl, web_plano pla
     where ativos.codigo = pl.prod_preco
       and pla.codplano = pl.codplano
       and (p_plano is null or pl.codplano = p_plano);

  v_codprod web_prod_preco.codprod%type;
  v_codplano web_prod_preco_plano.codplano%type;
  v_preco_antigo web_prod_preco.preco_antigo%type;
  v_preco    web_prod_preco_plano.preco%type;
  v_maior_parcela web_prod_preco_plano.maior_parcela%type;
  v_juros web_prod_preco_plano.juros%type;
  v_vlminparc web_plano.vlminparc%type;

  v_valor_parcela number(10,4);
  v_taxa_decimal number(10,6);
  v_taxa_mais_um number(10,6);
  out_rec tp_web_preco_ativo_parcela;
BEGIN
  open c1;
  loop
    fetch c1 into v_codprod, v_preco_antigo, v_codplano, v_preco, v_maior_parcela, v_juros, v_vlminparc;
    exit when c1%notfound;

    for numparcela in 1..v_maior_parcela loop
      v_valor_parcela := -1;

      if(numparcela = 1) then
        v_valor_parcela := round(v_preco,6);
      elsif(v_juros = 0) then
        v_valor_parcela := round(v_preco,6);
      else
        v_taxa_decimal := round(v_juros/100,4);
        v_taxa_mais_um := v_taxa_decimal+1;
        v_valor_parcela := round(v_preco*(power(v_taxa_mais_um,numparcela)*v_taxa_decimal/(power(v_taxa_mais_um,numparcela)-1)),6);
        v_valor_parcela := v_valor_parcela*numparcela;
      end if;
      if  ( numparcela > 1 and v_vlminparc > round(v_valor_parcela/numparcela,2) ) then
        return;
      end if;
      out_rec := tp_web_preco_ativo_parcela(v_codprod, v_codplano, numparcela,
          round(v_valor_parcela/numparcela,2), v_preco, round(v_valor_parcela,2), v_preco_antigo, v_juros);
      pipe row(out_rec);
    end loop;

  end loop;
  close c1;
END WEB_PRECO_ATIVO_PARCELA;