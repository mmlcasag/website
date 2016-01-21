CREATE OR REPLACE FUNCTION fnc_ret_margem 
( p_item        IN NUMBER
, p_filial      IN NUMBER
, p_preco       IN NUMBER
, p_plano       IN VARCHAR2
, p_parcelas    IN NUMBER
, p_cep         IN NUMBER
, p_desc_rebate IN NUMBER DEFAULT 0
, p_juros       IN NUMBER DEFAULT NULL
, p_deposito    IN NUMBER DEFAULT NULL
) RETURN NUMBER AS
BEGIN
  RETURN 0;
END fnc_ret_margem;
/
