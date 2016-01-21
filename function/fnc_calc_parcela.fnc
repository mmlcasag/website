create or replace FUNCTION FNC_CALC_PARCELA(p_taxa number, p_valor number, p_parcela integer) RETURN NUMBER 
AS
	v_valor_parcela number(15,4);
	v_taxa_decimal number(10,6);
	v_taxa_mais_um number(10,6);
BEGIN
	if p_parcela = 1 or p_taxa = 0 then
		v_valor_parcela := round(p_valor, 6);
	else
		v_taxa_decimal := round(p_taxa / 100, 4);
		v_taxa_mais_um := v_taxa_decimal+1;
		v_valor_parcela := round(p_valor*(power(v_taxa_mais_um, p_parcela)*v_taxa_decimal/(power(v_taxa_mais_um, p_parcela)-1)),6);
		v_valor_parcela := v_valor_parcela * p_parcela;
	end if;
	return v_valor_parcela;
END FNC_CALC_PARCELA;