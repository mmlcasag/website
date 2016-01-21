CREATE OR REPLACE FUNCTION fnc_valor_parcela (p_maior_parcela NUMBER, p_preco IN NUMBER, p_juros NUMBER DEFAULT 0) RETURN NUMBER IS
  v_valor_parcela NUMBER(10,4);
  v_taxa_decimal NUMBER(10,6);
  v_taxa_mais_um NUMBER(10,6);
BEGIN
  -- Apenas calcula valor da parcela. Nao valida valor minimo da parcelas
  v_valor_parcela := -1;

  IF(p_maior_parcela = 1) THEN
    v_valor_parcela := round(p_preco,6);
  ELSIF(p_juros = 0) THEN
    v_valor_parcela := round(p_preco,6);
  ELSE
    v_taxa_decimal := round(p_juros/100,4);
    v_taxa_mais_um := v_taxa_decimal+1;
    v_valor_parcela := round(p_preco*(POWER(v_taxa_mais_um,p_maior_parcela)*v_taxa_decimal/(POWER(v_taxa_mais_um,p_maior_parcela)-1)),6);
    v_valor_parcela := v_valor_parcela*p_maior_parcela;
  END IF;

  RETURN round(v_valor_parcela/p_maior_parcela,2);
END;
/
