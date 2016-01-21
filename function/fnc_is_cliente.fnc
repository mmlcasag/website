CREATE OR REPLACE FUNCTION FNC_IS_CLIENTE (p_cpf in varchar2) RETURN VARCHAR2 AS 
  cursor cadastros (v_param number) is 
      select codcli
        from cad_cliente
        where cgccpf = v_param;
        
  v_retorno     char(1) := 'N';
  
  v_qtd_compras number(4) := 0; 
  v_cpf         number(11);
  
BEGIN
  -- converte o CPF em numero
  begin
    v_cpf := to_number(replace(replace(p_cpf,'-',''),'.',''));
  exception
    when INVALID_NUMBER then
      return v_retorno;
  end;
  
  -- busca os cadastros do cliente
  for cr in cadastros (v_cpf)
    loop
      -- busca quantidade de compras por cadastro
      select count(*)
        into v_qtd_compras
        from mov_pedido
        where codcli = cr.codcli
          and status in (4,5,6,7);
          
      if (v_qtd_compras > 0) then
        v_retorno := 'S';
        exit;
      end if;          
     end loop;
    
  return v_retorno;
END FNC_IS_CLIENTE;