CREATE OR REPLACE FUNCTION fnc_ret_preco
( p_item        IN NUMBER
, p_filial      IN NUMBER
, p_margem      IN NUMBER
, p_plano       IN VARCHAR2
, p_parcelas    IN NUMBER
, p_cep         IN NUMBER
, p_desc_rebate IN NUMBER DEFAULT 0
, p_taxa        IN NUMBER DEFAULT null
) RETURN NUMBER AS
BEGIN
  return 0;
END fnc_ret_preco;
/
